import 'package:anonymous_chat/pages/login_page.dart';
import 'package:anonymous_chat/services/login_or_register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/home_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          //user is logged in
          if(snapshot.hasData){
            return const HomePage();
          }else{
            return const LoginOrRegister();
          }

          //user is not logged in
        },
      ),
    );
  }
}
