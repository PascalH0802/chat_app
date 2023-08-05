import 'package:anonymous_chat/pages/about_us_page.dart';
import 'package:anonymous_chat/pages/home_page.dart';
import 'package:anonymous_chat/pages/imprint_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final void Function()? onTap;
  const ChangePasswordPage({super.key, required this.onTap});



  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey, // Weisen Sie dem Scaffold die GlobalKey zu
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            title: Text('Change Password')
        ),
        drawer: buildDrawer(context), // Verwenden Sie die Funktion, um den Drawer zu erstellen
        body: SafeArea(
            child: Center(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Icon(
                          Icons.message, //später ändern!
                          size: 100,
                          color: Colors.grey[800],
                        ),

                        const SizedBox(height: 50),

                        const Text(
                          "Here you can change your Password",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 25),

                        MyTextField(
                            controller: oldPasswordController,
                            hintText: 'Current Password',
                            obscureText: true
                        ),

                        const SizedBox(height: 10),

                        MyTextField(
                            controller: newPasswordController,
                            hintText: 'New Password',
                            obscureText: true
                        ),

                        const SizedBox(height: 10),

                        MyTextField(
                            controller: confirmNewPasswordController,
                            hintText: 'Confirm new Password',
                            obscureText: true
                        ),

                        const SizedBox(height: 25),

                        MyButton(
                            onTap: changePassword,
                            text: 'Change password'
                        ),
                      ],
                    )
                )

            )

        ),
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
                    _scaffoldKey.currentState?.openEndDrawer(); // Schließen Sie den Drawer
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


  Future<void> changePassword() async {
    final authService = Provider.of<AuthService>(context, listen: false);


      if(newPasswordController.text == confirmNewPasswordController.text){
        if(newPasswordController.text != oldPasswordController.text){
          await authService.changePassword(newPasswordController.text, oldPasswordController.text);
        }else{
          Fluttertoast.showToast(
            msg: 'Your new password cannot be your old password',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }else{
        Fluttertoast.showToast(
          msg: 'Both new passwords need to be the same',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }

      newPasswordController.clear();
      confirmNewPasswordController.clear();
      oldPasswordController.clear();


  }
}
