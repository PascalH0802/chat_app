import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

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


  // Funktion, um Links in TextSpan umzuwandeln
  List<TextSpan> _convertToTextSpans(String message) {
    List<TextSpan> textSpans = [];
    List<String> words = message.split(' ');

    for (String word in words) {
      if (Uri.tryParse(word)?.isAbsolute ?? false) {
        // Wenn das Wort ein Link ist, füge es als anklickbaren TextSpan hinzu
        textSpans.add(TextSpan(
          text: '$word ',
          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()..onTap = () => _launchURL(word),
        ));
      } else {
        // Wenn das Wort kein Link ist, füge es einfach als normalen TextSpan hinzu
        textSpans.add(TextSpan(text: '$word '));
      }
    }

    return textSpans;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: myMessage ? Colors.blue : Colors.purpleAccent,
        border: Border.all(color: Colors.deepPurple, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 16, color: Colors.black),
              children: _convertToTextSpans(message),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            secondMessage,
            style: const TextStyle(fontSize: 12),
          ),

        ],
      ),
    );
  }
  // Funktion zum Öffnen des Links in einem Webbrowser
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
