import 'package:anonymous_chat/pages/add_contact_page.dart';
import 'package:anonymous_chat/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //sign user out
  void signOut(){
    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text('My Chats'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddContactPage(onTap: () {  },)),
              );
            },
            icon: const Icon(Icons.add_rounded),
          ),
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout))
        ],
      ),
      body: _buildUserList(),
    );
  }



  Widget _buildUserList() {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        final List<String> contactList =
        List<String>.from(snapshot.data!.get('contactList') ?? []);

        if (contactList.isEmpty) {
          return const Text('No contacts');
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('uid', whereIn: contactList)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading..');
            }

            final List<DocumentSnapshot> userDocs = snapshot.data!.docs;

            if (userDocs.isEmpty) {
              return const Text('No contacts');
            }

            return ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.deepPurple, // Farbe der Trennlinie
                height: 1, // Höhe der Trennlinie
              ),
              itemCount: userDocs.length,
              itemBuilder: (context, index) => _buildUserListItem(userDocs[index]),
            );
          },
        );
      },
    );
  }


  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    String tempUsername = data['username'].toString().toLowerCase();
    String tempEmail = '$tempUsername@fake.mail';
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    String newMessage = '';

    List<String> ids = [currentUserId, data['uid']];
    ids.sort(); // damit es immer die gleiche ID ist, für alle Chatpartner
    String chatRoomId = ids.join("_"); // kombiniert die IDs

    // Display all users except the current user
    if (_auth.currentUser!.email.toString() != tempEmail) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('counter')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading..');
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            int newMessageCount = snapshot.data!.get('newMessageCounter') ?? 0;

            // Zeige den Counter nur an, wenn er größer als 0 ist
            if (newMessageCount > 0) {
              if (newMessageCount == 1) {
                newMessage = ' new message';
              } else {
                newMessage = ' new messages';
              }
              return ListTile(
                tileColor: Colors.deepPurple.shade200, // Hintergrundfarbe ändern
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                title: Text(
                  data['username'],
                  style: TextStyle(fontSize: 18.0),
                ),
                subtitle: Text(
                  '$newMessageCount$newMessage',
                  style: TextStyle(fontSize: 14.0, color: Colors.white),
                ),
                onTap: () {
                  // pass the clicked user's UID to the chat page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverUserEmail: data['username'],
                        receiverUserID: data['uid'],
                      ),
                    ),
                  );
                },
              );
            }
          }

          // Zeige nur den Benutzernamen ohne den Counter
          return ListTile(
            tileColor: Colors.deepPurple.shade200, // Hintergrundfarbe ändern
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              data['username'],
              style: TextStyle(fontSize: 18.0),
            ),
            onTap: () {
              // pass the clicked user's UID to the chat page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverUserEmail: data['username'],
                    receiverUserID: data['uid'],
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      // Return an empty container
      return Container();
    }
  }


}

