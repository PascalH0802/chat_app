
import 'package:anonymous_chat/services/encrypt_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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



  Future<void> changePassword(String newPassword, String currentPassword) async {

    try {
      User? user = _firebaseAuth.currentUser;

      if (user != null) {
        // Erstelle eine Anmeldebescheinigung mit der aktuellen E-Mail und dem aktuellen Passwort
        AuthCredential credential =
        EmailAuthProvider.credential(email: user.email!, password: _encryptService.encrypt(currentPassword).base64);

        // Reauthentifiziere den Benutzer mit der Anmeldebescheinigung
        await user.reauthenticateWithCredential(credential);

        // Wenn die Reauthentifizierung erfolgreich war, ändere das Passwort
        await user.updatePassword(_encryptService.encrypt(newPassword).base64);

        Fluttertoast.showToast(
          msg: 'Password changed successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        signOut();

      } else {
        Fluttertoast.showToast(
          msg: 'An error has occurred',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Password is wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
