import 'package:anonymous_chat/components/my_button.dart';
import 'package:anonymous_chat/components/my_text_field.dart';
import 'package:anonymous_chat/services/auth_service.dart';
import 'package:anonymous_chat/services/request_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AddContactPage extends StatefulWidget {
  final void Function()? onTap;
  const AddContactPage({super.key, required this.onTap});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {



  //textController
  final TextEditingController _usernameSearchController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  final RequestService _requestService = RequestService();

  void addContact() async {

    if (_usernameSearchController.text.isNotEmpty) {

      String name = _usernameSearchController.text;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: _usernameSearchController.text)
          .get();


      if (querySnapshot.docs.isNotEmpty) {

          String uid = querySnapshot.docs.first.id;
          await _requestService.sendRequest(uid);

          Fluttertoast.showToast(
            msg: 'Request sent to $name',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );


      } else {

        Fluttertoast.showToast(
          msg: 'No user with that username found',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }

      _usernameSearchController.clear();
    }
  }
  
  void acceptContact(String otherUserId) async {
    await _requestService.acceptRequest(otherUserId);
  }
  
  void declineContact(String otherUserId) async {
    await _requestService.declineRequest(otherUserId);
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text('Add Contacts'),),
      body: SafeArea(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Icon(
                        Icons.message, //später ändern!
                        size: 100,
                        color: Colors.grey[800],
                      ),

                      const SizedBox(height: 50),

                      const Text(
                        "Welcome back",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 25),

                      MyTextField(
                          controller: _usernameSearchController,
                          hintText: 'Username',
                          obscureText: false
                      ),

                      const SizedBox(height: 25),

                      MyButton(
                          onTap: addContact,
                          text: 'Add Contact'
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "Incoming requests",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Expanded(
                        child: _buildIncomingRequestsList(),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "Outgoing requests",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Expanded(
                        child: _buildOutgoingRequestsList(),
                      ),

                    ],
                  )
              )

          )

      ),
    );
  }


  //build a list of users except for the current logged in user || noch ändern zu anfragen unser mit denen man chattet
  Widget _buildIncomingRequestsList() {
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

        final List<String> pendingContacts =
        List<String>.from(snapshot.data!.get('pendingContacts') ?? []);

        if (pendingContacts.isEmpty) {
          return const Text('No pending contacts');
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('uid', whereIn: pendingContacts)
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
              return const Text('No incoming requests');
            }

            return ListView(
              children: userDocs
                  .map<Widget>((doc) => _buildIncomingRequestsListItem(doc))
                  .toList(),
            );
          },
        );
      },
    );
  }


  Widget _buildIncomingRequestsListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    String tempUsername = data['username'].toString().toLowerCase();
    String tempEmail= '$tempUsername@fake.mail';

    //display all users except the current user
    if(_firebaseAuth.currentUser!.email.toString() != tempEmail){
      return ListTile(
        title: Text(data['username']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                acceptContact(document.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                declineContact(document.id);
              },
            ),
          ],
        ),
      );
    } else {
      //return empty container
      return Container();
    }
  }

  //build a list of users except for the current logged in user || noch ändern zu anfragen unser mit denen man chattet
  Widget _buildOutgoingRequestsList() {
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

        final List<String> sentContactRequests =
        List<String>.from(snapshot.data!.get('sentContactRequests') ?? []);

        if (sentContactRequests.isEmpty) {
          return const Text('No sent Requests');
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('uid', whereIn: sentContactRequests)
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
              return const Text('No outgoing requests');
            }

            return ListView(
              children: userDocs
                  .map<Widget>((doc) => _buildOutgoingRequestsListItem(doc))
                  .toList(),
            );
          },
        );
      },
    );
  }


  Widget _buildOutgoingRequestsListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    String tempUsername = data['username'].toString().toLowerCase();
    String tempEmail= '$tempUsername@fake.mail';

    //display all users except the current user
    if(_firebaseAuth.currentUser!.email.toString() != tempEmail){
      return ListTile(
        title: Text(data['username']),

      );
    } else {
      //return empty container
      return Container();
    }
  }





}
