import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:http/http.dart';

import '../components/message.dart';

class ChatService extends ChangeNotifier {

  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessagePush(String receiverId) async {

    DocumentReference userDocRef = _fireStore.collection('users').doc(receiverId);

    final String currentUserId = _firebaseAuth.currentUser!.uid;
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
                "title": username,
                "body": "New message"
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



  //Send Message
  Future<void> sendMessage(String receiverId, Encrypted encryptedData) async {
    // get current user information
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
        senderId: currentUserId,
        receiverId: receiverId,
        timestamp: timestamp,
        message: encryptedData.base64,
        isFile: 0
    );

    // construct chat room id from current user id and receiver id (damit einzigartig)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); //damit es immer die gleiche ID ist, für alle Chatpartner
    String chatRoomId = ids.join("_"); //kombiniert die IDs


    // add new message to database
    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage
        .toMap());

    updateNewMessageCounter(chatRoomId, receiverId);

    final DocumentReference chatroomDocRef = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId);


    // 'receiverId'-Dokument existiert nicht, es erstellen mit newMessageCounter = 0
    chatroomDocRef.update({
      'lastContact': Timestamp.now(),
    });

    sendMessagePush(receiverId);

  }

  Future<void> sendFileMessage(String receiverId, String url) async {
    // get current user information
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    // construct the URL for the file in Firebase Storage
    String sendUrl = await getImgUrl(url);

    // create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      receiverId: receiverId,
      timestamp: timestamp,
      message: sendUrl,
      isFile: 1,
    );

    // construct chat room id from current user id and receiver id (damit einzigartig)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); //damit es immer die gleiche ID ist, für alle Chatpartner
    String chatRoomId = ids.join("_"); //kombiniert die IDs


    // add new message to database
    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage
        .toMap());

    updateNewMessageCounter(chatRoomId, receiverId);

    final DocumentReference chatroomDocRef = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId);


    // 'receiverId'-Dokument existiert nicht, es erstellen mit newMessageCounter = 0
    chatroomDocRef.update({
      'lastContact': Timestamp.now(),
    });


    sendMessagePush(receiverId);

  }


  // Get Message
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    //construct chat room id from user ids
    List<String> ids = [userId, otherUserId];
    ids.sort(); //damit es immer die gleiche ID ist, für alle Chatpartner
    String chatRoomId = ids.join("_"); //kombiniert die IDs

    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }


  void updateNewMessageCounter(String chatRoomId, String receiverId) {
    final CollectionReference counterCollection = FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('counter');

    final DocumentReference receiverDocRef = counterCollection.doc(receiverId);

    receiverDocRef.get().then((receiverSnapshot) {
      if (!receiverSnapshot.exists) {
        // 'receiverId'-Dokument existiert nicht, es erstellen mit newMessageCounter = 0
        receiverDocRef.set({'newMessageCounter': 1});
      } else {
        // 'receiverId'-Dokument existiert, aktuellen newMessageCounter-Wert abrufen
        Map<String, dynamic>? data = receiverSnapshot.data() as Map<
            String,
            dynamic>?;

        int currentCounter = data?['newMessageCounter'] ?? 0;

        // newMessageCounter um 1 erhöhen
        int newCounterValue = currentCounter + 1;

        // Den aktualisierten newMessageCounter-Wert im Dokument speichern
        receiverDocRef.update({'newMessageCounter': newCounterValue}).then((_) {
          print('newMessageCounter erfolgreich aktualisiert!');
        }).catchError((error) {
          print('Fehler beim Aktualisieren des newMessageCounter: $error');
        });
      }
    }).catchError((error) {
      print('Fehler beim Lesen des Dokuments: $error');
    });
  }


  Future getImgUrl(String name) async {
    final spaceRef = FirebaseStorage.instance.ref("chat").child(name);
    var str = await spaceRef.getDownloadURL();
    return str ?? ""; // if empty return ""
  }


  Future<String> uploadFile(File? photo) async {
    if (photo == null) return '';

    try {
      String fileName = getRandomString(20);
      final ref = FirebaseStorage.instance.ref("chat/$fileName");
      await ref.putFile(photo).whenComplete(() => null);
      return fileName;
    } catch (e) {
      print('There is an error $e');
      return '';
    }
  }

  String getRandomString(int len) {
    var r = Random();
    String characters = "abcdefghijklmnopqrstuvwxyz0123456789";
    return String.fromCharCodes(
      List.generate(
          len, (index) => characters.codeUnitAt(r.nextInt(characters.length))),
    );
  }

  Future<String> getContentTypeFromUrl(String url) async {
    final spaceRef = FirebaseStorage.instance.refFromURL(url);
    final metadata = await spaceRef.getMetadata();
    return metadata.contentType!;
  }
}




