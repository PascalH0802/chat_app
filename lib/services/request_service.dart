import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';




class RequestService extends ChangeNotifier {

  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  

  // Send Request
  Future<void> sendRequest(String receiverId) async {



    // get current user information
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    if(receiverId != currentUserId){
      //add other user to current users pending friends list
      await _fireStore.collection('users').doc(receiverId).update({
        'pendingContacts': FieldValue.arrayUnion([currentUserId]),
      });

      //add current user to other users friend requests list
      await _fireStore.collection('users').doc(currentUserId).update({
        'sentContactRequests': FieldValue.arrayUnion([receiverId]),
      });
    }

    sendRequestPush(receiverId, currentUserId);


  }

  Future<void> acceptRequest(String otherUserId) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    //add current user to other users friends and the other way around
    await _fireStore.collection('users').doc(otherUserId).update({
       'contactList': FieldValue.arrayUnion([currentUserId])
      });

    await _fireStore.collection('users').doc(currentUserId).update({
      'contactList': FieldValue.arrayUnion([otherUserId])
    });

    //delete other user from current users pending friends
    await _fireStore.collection('users').doc(currentUserId).update({
      'pendingContacts': FieldValue.arrayRemove([otherUserId])
    });
    
    //delete current user from other users friend requestst
    await _fireStore.collection('users').doc(otherUserId).update({
      'sentContactRequests': FieldValue.arrayRemove([currentUserId])
    });

    List<String> ids = [currentUserId, otherUserId];
    ids.sort(); //damit es immer die gleiche ID ist, für alle Chatpartner
    String chatRoomId = ids.join("_"); //kombiniert die IDs

    final DocumentReference chatroomDocRef = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId);


        // 'receiverId'-Dokument existiert nicht, es erstellen mit newMessageCounter = 0
    chatroomDocRef.set({
      'lastContact': Timestamp.now(),
    });


  }

  Future<void> declineRequest(String otherUserId) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    //delete other user from current users pending friends
    await _fireStore.collection('users').doc(currentUserId).update({
      'pendingContacts': FieldValue.arrayRemove([otherUserId])
    });

    //delete current user from other users friend requestst
    await _fireStore.collection('users').doc(otherUserId).update({
      'sentContactRequests': FieldValue.arrayRemove([currentUserId])
    });
  }

  Future<void> deleteChat(String otherUserId) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;


    await _fireStore.collection('users').doc(otherUserId).update({
      'contactList': FieldValue.arrayRemove([currentUserId])
    });

    await _fireStore.collection('users').doc(currentUserId).update({
      'contactList': FieldValue.arrayRemove([otherUserId])
    });
  }


  Future<void> sendRequestPush(String receiverId, String currentUserId) async {

    DocumentReference userDocRef = _fireStore.collection('users').doc(receiverId);

    DocumentReference currentUserDocRef = _fireStore.collection('users').doc(currentUserId);


    try {
      final docSnapshot = await userDocRef.get();
      final currentUserDocSnapshot = await currentUserDocRef.get();
      if (docSnapshot.exists && currentUserDocSnapshot.exists) {
        //userdata exists
        Map<String, dynamic>? userData = docSnapshot.data() as Map<String, dynamic>?;
        Map<String, dynamic>? currentUserData = currentUserDocSnapshot.data() as Map<String, dynamic>?;
        if (userData != null && currentUserData != null) {
          String token = userData['token'];
          String username = currentUserData['username'];
          try{
            final body = {
              "to" : token,
              "notification": {
                "title": "New contact request",
                "body": "You have received a new contact request from $username!"
              }
            };

            var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                headers: {
                  HttpHeaders.contentTypeHeader: 'application/json',
                  HttpHeaders.authorizationHeader: 'key=AAAAdAKkJ1w:APA91bHlQCyTNHqYkKlkIWGD9GJUbsFY6oP1fdU4iDdrJhykwIuZKWEkmHBTNk91zgzoB04TcAgUIzsS0HvwTuJNJQBV9D_BwZYZimgMLE5SkYDkRN4NASq4zCJWImBTDE-LjqkLUzY-'
                },
                body: jsonEncode(body));
            print('Response status: ${res.statusCode}');
            print('Response body: ${res.body}');
          }
          catch(e){
            print('\nsendPushNotificationE: $e');
          }



        } else {
          print("userData is null.");
        }
      } else {
        print("Document does not exist for receiverId: $receiverId");
      }
    } catch (e) {
      print("Error while sending FCM message: $e");
    }
  }

}