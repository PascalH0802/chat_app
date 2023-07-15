import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus {accept, decline, idle}

class Request {
  final String senderId;
  final String receiverId;
  final Timestamp timestamp;
  final RequestStatus requestStatus;

  Request({
    required this.timestamp,
    required this.receiverId,
    required this.senderId,
    required this.requestStatus,
  });

  //convert to a map, da informationen in firebase so gespeichert werden
  Map<String, dynamic> toMap (){
    return{
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp
    };
  }

}