import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'dart:typed_data';


//AES verschlüsselung!



class EncryptService  {

String keyString = 'PqokAO1BQBHyJVKv';


  String decrypt(String encryptedDataString) {

    List<int> encryptedDataBytes = base64.decode(encryptedDataString);
    Uint8List uint8List = Uint8List.fromList(encryptedDataBytes);
    Encrypted encryptedData = Encrypted(uint8List);

    final key = Key.fromUtf8(keyString);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(keyString.substring(0, 16));
    return encrypter.decrypt(encryptedData, iv: initVector);
  }

  Encrypted encrypt(String plainText) {
    final key = Key.fromUtf8(keyString);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(keyString.substring(0, 16));
    Encrypted encryptedData = encrypter.encrypt(plainText, iv: initVector);
    return encryptedData;
  }




}






