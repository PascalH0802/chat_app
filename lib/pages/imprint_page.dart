import 'package:anonymous_chat/pages/about_us_page.dart';
import 'package:anonymous_chat/pages/change_password_page.dart';
import 'package:anonymous_chat/pages/home_page.dart';
import 'package:flutter/material.dart';

class ImprintPage extends StatelessWidget {
  final void Function()? onTap;
   ImprintPage({super.key, required this.onTap});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey, // Weisen Sie dem Scaffold die GlobalKey zu
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          title: Text('Imprint')
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
            'Imprint',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Responsible for the content:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Pascal Helmetag',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Nelkenstr. 3\n34549 Edertal',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            'Contact:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Mobile: +49 176 60300506',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'E-Mail: pascal.helmetag@gmx.net',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            'Registry Court:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Not yet available',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Register number:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Not yet available',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUsPage(onTap: () {})),
                    );
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
              _scaffoldKey.currentState?.openEndDrawer(); // Schließen Sie den Drawer
            },
          ),
        ],
      ),
    );
  }
}