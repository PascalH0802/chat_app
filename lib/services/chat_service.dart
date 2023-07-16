import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/message.dart';

class ChatService extends ChangeNotifier {

  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;



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
      message: encryptedData.base64
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
  }


  // Get Message
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId){
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
        Map<String, dynamic>? data = receiverSnapshot.data() as Map<String, dynamic>?;

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
  }




