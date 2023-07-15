

import 'package:flutter/material.dart';

class MyChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  const MyChatTextField({super.key, required this.controller, required this.hintText, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200)
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color:  Colors.white),
        ),
        fillColor: Colors.grey[200],
        filled: true,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey)
      ),
    );
  }
}
