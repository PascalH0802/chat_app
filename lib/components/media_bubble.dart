import 'package:flutter/material.dart';

class MediaBubble extends StatelessWidget {
  final Widget content;
  final String secondMessage; // Der zusätzliche Text
  final bool myMessage;
  const MediaBubble({
    Key? key, // Du hast hier "super.key" geschrieben, aber es sollte "Key? key" sein
    required this.content,
    required this.secondMessage,
    required this.myMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: myMessage ? Colors.blue : Colors.purpleAccent, // Bubble-Hintergrundfarbe abhängig von der Absenderseite
        border: Border.all(color: Colors.deepPurple, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          content,
          const SizedBox(height: 4), // Ein Abstand zwischen den Texten
          Text(
            secondMessage,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
