import 'dart:convert';
import 'dart:math';

import 'package:anonymous_chat/components/chat_bubble.dart';
import 'package:anonymous_chat/services/chat_service.dart';
import 'package:anonymous_chat/services/encrypt_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/my_chat_text_field.dart';



class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage({super.key, required this.receiverUserEmail, required this.receiverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}



class _ChatPageState extends State<ChatPage> {

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final EncryptService _encryptService = EncryptService();



  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      Encrypted message = _encryptService.encrypt(_messageController.text);

      await _chatService.sendMessage(widget.receiverUserID, message);
      //clear controller after sending the message
      _messageController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    // Setze den Counter auf 0, wenn die ChatPage geöffnet wird
    resetCounter();
  }

  @override
  void dispose() {
    // Setze den Counter auf 0, wenn die ChatPage geschlossen wird
    resetCounter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text(widget.receiverUserEmail),),
      body: Column(
        children: [
          //messages
          Expanded(
            child: _buildMessageList(),
          ),
          //user input
          _buildMessageInput(),
        ],
      ),
    );
  }

  // build message list
  Widget _buildMessageList(){
    return StreamBuilder(
      stream: _chatService.getMessages(
          _firebaseAuth.currentUser!.uid, widget.receiverUserID
      ),
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return Text('Error${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading..');
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );

      },
    ); //maybe tauschen
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    Timestamp timestamp = data['timestamp'];

    // align the messages to the right if the sender is the current user, otherwise to the left
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid )
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment:
        (data['senderId'] == _firebaseAuth.currentUser!.uid )
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment:
        (data['senderId'] == _firebaseAuth.currentUser!.uid )
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,

        children: [
          ChatBubble(message: _encryptService.decrypt(data['message']), secondMessage: timestamp.toDate().toString().substring(11,16 ), myMessage: data['senderId'] == _firebaseAuth.currentUser!.uid,),


        ],
      ),
    );
  }

  // build message input
  Widget _buildMessageInput(){
    return Row(

      children: [
        const Padding(padding: EdgeInsets.all(2)),
        // textfield
        Expanded(
            child:

            Container(
              padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0), // Abstand von allen Seiten
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Enter your text',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    iconSize: 30,
                    onPressed: sendMessage,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0), // Kein zusätzliches Padding im TextField
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0), // Runde Ecken
                  ),
                ),
              ),
            )


        ),

      ],
    );
  }

  void resetCounter() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    List<String> ids = [currentUserId, widget.receiverUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('counter')
        .doc(currentUserId)
        .set({'newMessageCounter': 0});
  }
}