import 'package:anonymous_chat/pages/add_contact_page.dart';
import 'package:anonymous_chat/pages/imprint_page.dart';
import 'package:anonymous_chat/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'about_us_page.dart';
import 'change_password_page.dart';
import 'chat_page.dart';

class User implements Comparable<User> {
  final String username;
  final String uid;
  final DateTime lastContact;

  User(this.username, this.uid, this.lastContact);

  @override
  int compareTo(User other) {
    if (lastContact.isBefore(other.lastContact)) {
      return -1;
    } else if (lastContact.isAfter(other.lastContact)) {
      return 1;
    } else {
      return 0;
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onTap});

  final void Function()? onTap;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  //instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  late Future<bool> markerFuture;

  @override
  void initState()  {
    initMessaging();
    super.initState();
    markerFuture = showMarker();
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

 Future<bool> showMarker()  async {

   final String currentUserId = _auth.currentUser!.uid;
   DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
       .collection('users')
       .doc(currentUserId)
       .get();

    if (snapshot.exists) {
      Map<String, dynamic> userData = snapshot.data()!;
      if(List.from(userData['pendingContacts']).isNotEmpty){
        return true;
      }else{
        return false;
      }

    } else {
      return false;
    }
  }


  Widget _buildUserList() {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUserId).get(),
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

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where('uid', whereIn: contactList)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error');
            }

            final List<DocumentSnapshot> userDocs = snapshot.data!.docs;

            if (userDocs.isEmpty) {
              return const Text('No contacts');
            }

            List<Future<User>> userFutures = userDocs.map((doc) async {
              Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

              List<String> ids = [currentUserId, data['uid']];
              ids.sort();
              String chatRoomId = ids.join("_");
              DocumentReference chatRoomRef = FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId);

              DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();
              Map<String, dynamic> chatRoomData = chatRoomSnapshot.data() as Map<String, dynamic>;
              Timestamp lastContactTimestamp = chatRoomData['lastContact'] as Timestamp;

              DateTime lastContactDateTime = lastContactTimestamp.toDate();
              return User(data['username'], data['uid'], lastContactDateTime);
            }).toList();

            return FutureBuilder<List<User>>(
              future: Future.wait(userFutures),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                }

                List<User> usersUnsorted = snapshot.data!;
                List<User> users = [];

                while (usersUnsorted.isNotEmpty) {
                  User latestUser = usersUnsorted.reduce((a, b) => a.lastContact.isAfter(b.lastContact) ? a : b);
                  users.add(latestUser);
                  usersUnsorted.remove(latestUser);
                }

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
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          titleSpacing: 0,
          title: const Row(
            children: [
              SizedBox(width: 40),
              Expanded(
                child: Center(
                  child: Text('My Chats'),
                ),
              ),
            ],
          ),
          actions: [
            FutureBuilder<bool>(
              future: markerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(); // Hier kannst du einen Ladeindikator anzeigen, wenn noch keine Daten verfügbar sind
                }

                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddContactPage(onTap: () {})),
                    );
                  },
                  icon: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Icon(Icons.add_rounded),
                      if (snapshot.data == true)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.yellow,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              onPressed: signOut,
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        drawer: buildDrawer(context),
        body: _buildUserList(),
      ),
    );
  }

  // Funktion zum Erstellen des Drawers
  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Text('Header des Drawers'),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('My Chats'),
            onTap: () {
              // Aktion, die ausgeführt wird, wenn der Startseite-Eintrag geklickt wird
              _scaffoldKey.currentState?.openEndDrawer(); // Schließen Sie den Drawer
              // Hier können Sie die gewünschte Aktion für die Startseite ausführen
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Change password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage(onTap: () {})),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outlined),
            title: Text('About Us'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage(onTap: () {})),
              );
            },
          ),
        ],
      ),
          ),
          // Option ganz unten im Drawer
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Imprint'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImprintPage(onTap: () {})),
              );
            },
          ),
        ],
      ),
    );
  }

}
