import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:anonymous_chat/components/chat_bubble.dart';
import 'package:anonymous_chat/services/chat_service.dart';
import 'package:anonymous_chat/services/encrypt_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:file_picker/file_picker.dart';


import '../components/media_bubble.dart';
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
  String? _uploadedFileName; // Klasseigenschaft zum Speichern des Dateinamens

  File? _photo;
  final FilePicker _picker = FilePicker.platform;

  Future fileFromGallery() async {
    final pickedFiles = await _picker.pickFiles(
      allowMultiple: true,
    );
    if (pickedFiles != null) {
      // Loop through the selected files and upload them
      for (PlatformFile file in pickedFiles.files) {

          String fileName = await _chatService.uploadFile(File(file.path!));
          if (fileName.isNotEmpty) {
            _uploadedFileName = fileName;
            await _chatService.sendFileMessage(widget.receiverUserID, _uploadedFileName!);
          }

      }
    } else {
      print('No files selected');
    }
  }

  Future<void> imgFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      String fileName = await _chatService.uploadFile(File(pickedFile.path));
      if (fileName.isNotEmpty) {
        _uploadedFileName = fileName;
        await _chatService.sendFileMessage(widget.receiverUserID, _uploadedFileName!);
      }
    }
  }

  void sendFileMessage() async {
    if (_uploadedFileName != null) {
      await _chatService.sendFileMessage(widget.receiverUserID, _uploadedFileName!);
      _uploadedFileName = null; // Nach dem Versenden der Datei zurücksetzen
    }
  }



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
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    Timestamp timestamp = data['timestamp'];
    int isFile = data['isFile'];
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    List<Widget> children = [];

    // Check if the message is a file (0: text message, 1: file message)
    if (isFile == 0) {
      children.add(ChatBubble(
        message: _encryptService.decrypt(data['message']),
        secondMessage: timestamp.toDate().toString().substring(11, 16),
        myMessage: data['senderId'] == _firebaseAuth.currentUser!.uid,
      ));
    } else if (isFile == 1) {
      String url = data['message'];
      Timestamp uneditedTimestamp = data['timestamp'];
      String tempTimestamp = uneditedTimestamp.toDate().toString().substring(11, 16);

      children.add(
        FutureBuilder<String>(
          future: _chatService.getContentTypeFromUrl(url),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                String contentType = snapshot.data!;
                if (contentType.startsWith('image/')) {
                  return _buildImageBubble(url, alignment, tempTimestamp);
                } else if (contentType.startsWith('video/')) {
                  return _buildVideoBubble(url, alignment, tempTimestamp);
                } else {
                  // Unsupported file type, you can handle it accordingly
                  return Text('Unsupported file type');
                }
              } else if (snapshot.hasError) {
                // Handle error
                return Text('Error loading file');
              } else {
                // Future completed, but no data or error
                return Text('No data available');
              }
            }
            // The future has not completed, return an empty container or a placeholder widget.
            return Container();
          },
        ),
      );
    }

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: children,
      ),
    );
  }








  // build message input
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(2),
      child: Stack(
        children: [
          Row(
            children: [
              // IconButton links
              IconButton(
                  icon: Icon(Icons.camera),
                  iconSize: 30,
                  onPressed: () => _showPicker(context)
                // Aktion für den linken IconButton
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
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
                      contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageBubble(String imageUrl, Alignment alignment, String timestamp) {
    return MediaBubble(
      content: Container(
        constraints: BoxConstraints(maxWidth: 200),
        child: Image.network(imageUrl),
        alignment: alignment,
      ),
      secondMessage: timestamp,
      myMessage: alignment == Alignment.centerRight,
    );
  }

  Widget _buildVideoBubble(String videoUrl, Alignment alignment, String timestamp) {
    return MediaBubble(
      content: Container(
        constraints: BoxConstraints(maxWidth: 200),
        child: Chewie(
          controller: ChewieController(
            videoPlayerController: VideoPlayerController.network(videoUrl),
            autoPlay: false,
            looping: false,
          ),
        ),
        alignment: alignment,
      ),
      secondMessage: timestamp,
      myMessage: alignment == Alignment.centerRight,
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



  void _showPicker(context){
    showModalBottomSheet(context: context, builder: (BuildContext bc){
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Gallery"),
                onTap: () {fileFromGallery();
                Navigator.pop(context);}

            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text("Camera"),
              onTap: () {imgFromCamera();
                Navigator.pop(context);}
            )
          ],
        ),
      );
    });
  }
}