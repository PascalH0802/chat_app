import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;


  Message({
    required this.timestamp,
    required this.message,
    required this.receiverId,
    required this.senderId,
  });

  //convert to a map, da informationen in firebase so gespeichert werden
  Map<String, dynamic> toMap (){
    return{
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp
    };
  }

}