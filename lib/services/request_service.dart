import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';




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


}