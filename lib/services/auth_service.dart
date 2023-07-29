import 'package:anonymous_chat/services/encrypt_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier{
  //instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final EncryptService _encryptService = EncryptService();

  //instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //sign in
  Future<UserCredential> signInWithUsernameAndPassword(
      String username,
      String password
      ) async {
    try{
      String email = '$username@fake.mail';
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: _encryptService.encrypt(password).base64
      );





      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //create a new user
  Future<UserCredential> signUpWithUsernameAndPassword(
      String username,
      String password,
      ) async {
    try{
      String email = '$username@fake.mail';
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: _encryptService.encrypt(password).base64
      );

      //create new doc for user in collection
      _fireStore.collection('users').doc(userCredential.user!.uid).set({
        'uid' : userCredential.user!.uid,
        'username' : username,
        'pendingContacts' : [],
        'sentContactRequests' : [],
        'contactList' : [],
        'token': ''
      }, SetOptions(merge: true));

      return userCredential;
    }on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign out
Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
}

}
