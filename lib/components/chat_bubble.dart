import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String secondMessage; // Der zusätzliche Text
  final bool myMessage;
  const ChatBubble({
    Key? key, // Du hast hier "super.key" geschrieben, aber es sollte "Key? key" sein
    required this.message,
    required this.secondMessage,
    required this.myMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.purpleAccent,
        border: Border.all(color: Colors.deepPurple, width: 2.0)
      ),
      child: Column(
        crossAxisAlignment: myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8), // Ein Abstand zwischen den Texten
          Text(
            secondMessage,
            style: const TextStyle(fontSize: 12), // Kleinerer Schriftgrad für den zweiten Text

          ),
        ],
      ),
    );
  }
}
