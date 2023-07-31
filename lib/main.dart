import 'package:anonymous_chat/firebase_options.dart';
import 'package:anonymous_chat/pages/login_page.dart';
import 'package:anonymous_chat/services/auth_service.dart';
import 'package:anonymous_chat/services/login_or_register.dart';
import 'package:anonymous_chat/services/notification_serive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'pages/register_page.dart';
import 'services/auth_gate.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  print('App ist zu');
}


//@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  await NotificationService().initNotification();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return const MaterialApp(
     debugShowCheckedModeBanner: false,
     home: AuthGate(),
   );
  }
}



