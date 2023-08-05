import 'package:anonymous_chat/pages/change_password_page.dart';
import 'package:anonymous_chat/pages/home_page.dart';
import 'package:anonymous_chat/pages/imprint_page.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  final void Function()? onTap;
  AboutUsPage({super.key, required this.onTap});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey, // Weisen Sie dem Scaffold die GlobalKey zu
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            title: Text('About Us')
        ),
        drawer: buildDrawer(context), // Verwenden Sie die Funktion, um den Drawer zu erstellen
        body: _buildImprint(),
      ),
    );
  }

  Widget _buildImprint(){
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Us',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Pascal Helmetag',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                const DrawerHeader(
                  child: Text('Header des Drawers'),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('My Chats'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(onTap: () {})),
                    );

                    // Hier können Sie die gewünschte Aktion für die Startseite ausführen
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Change password'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangePasswordPage(onTap: () {})),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outlined),
                  title: Text('About Us'),
                  onTap: () {
                    _scaffoldKey.currentState?.openEndDrawer(); // Schließen Sie den Drawer
                  },
                ),
              ],
            ),
          ),
          // Option ganz unten im Drawer
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Imprint'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImprintPage(onTap: () {})),
              );
            },
          ),
        ],
      ),
    );
  }
}