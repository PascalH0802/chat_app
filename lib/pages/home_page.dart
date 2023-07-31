import 'package:anonymous_chat/pages/add_contact_page.dart';
import 'package:anonymous_chat/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chat_page.dart';

class User implements Comparable<User> {
  String username;
  String uid;
  DateTime lastContact;

  User(this.username, this.uid, this.lastContact);

  @override
  int compareTo(User other) => other.lastContact.compareTo(lastContact);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  void initState()  {
    initMessaging();
    super.initState();
  }

  Future<void> initMessaging() async {
    await FirebaseMessaging.instance.requestPermission();
    final String currentUserId = _auth.currentUser!.uid;

    await _fireStore.collection('users').doc(currentUserId).update({
      'token': await FirebaseMessaging.instance.getToken()
    });
  }

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  Widget _buildUserList() {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        final List<String> contactList = List<String>.from(snapshot.data!.get('contactList') ?? []);

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

            List<User> users = userDocs.map((doc) {
              Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
              Timestamp? lastContactTimestamp = data['lastContact'] as Timestamp?;
              DateTime lastContactDateTime = lastContactTimestamp?.toDate() ?? DateTime(1900);
              return User(data['username'], data['uid'], lastContactDateTime);
            }).toList();

            users.sort();

            return ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.deepPurple,
                height: 1,
              ),
              itemCount: users.length,
              itemBuilder: (context, index) => _buildUserListItem(users[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildUserListItem(User user) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    String tempUsername = user.username.toLowerCase();
    String tempEmail = '$tempUsername@fake.mail';
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    String newMessage = '';

    List<String> ids = [currentUserId, user.uid];
    ids.sort();
    String chatRoomId = ids.join("_");

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading..');
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          var lastContactTimestamp = snapshot.data!.get('lastContact') as Timestamp?;
          var lastContact = lastContactTimestamp != null
              ? DateFormat('dd.MM.yyyy, HH:mm').format(lastContactTimestamp.toDate())
              : '';

          return ListTile(
            title: Text(user.username),
            trailing: StreamBuilder<DocumentSnapshot>(
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

                  if (newMessageCount > 0) {
                    if (newMessageCount == 1) {
                      newMessage = ' new message';
                    } else {
                      newMessage = ' new messages';
                    }
                    return Text('$newMessageCount$newMessage');
                  }
                }

                return Container();
              },
            ),
            subtitle: Text('Last interaction: $lastContact'), // Timestamp wird hier angezeigt
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverUserEmail: user.username,
                    receiverUserID: user.uid,
                  ),
                ),
              );
            },
          );
        } else {
          return ListTile(
            title: Text(user.username),
            trailing: StreamBuilder<DocumentSnapshot>(
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

                  if (newMessageCount > 0) {
                    if (newMessageCount == 1) {
                      newMessage = ' new message';
                    } else {
                      newMessage = ' new messages';
                    }
                    return Text('$newMessageCount$newMessage');
                  }
                }

                return Container();
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverUserEmail: user.username,
                    receiverUserID: user.uid,
                  ),
                ),
              );
            },
          );
        }
      },
    );
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
                MaterialPageRoute(builder: (context) => AddContactPage(onTap: () {})),
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
}
