import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MyAppBar({required this.title});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.deepPurple, // Hintergrundfarbe
      elevation: 0, // Schatten entfernen
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Colors.white, // Icon-Farbe
        onPressed: () {
          Navigator.pop(context); // Zurücknavigation
        },
      ),
      title: Text(
        title, // Dynamischer Titel
        style: TextStyle(
          color: Colors.white, // Textfarbe
          fontSize: 20, // Schriftgröße
          fontWeight: FontWeight.bold, // Schriftgewicht
        ),
      ),
    );
  }
}
