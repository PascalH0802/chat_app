import 'package:anonymous_chat/components/my_button.dart';
import 'package:anonymous_chat/components/my_text_field.dart';
import 'package:anonymous_chat/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //textControllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    // get the auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try{
      await authService.signInWithUsernameAndPassword(usernameController.text, passwordController.text);
    }catch (e) {
      Fluttertoast.showToast(
        msg: 'Password or username incorrect',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
                    "Welcome back",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 25),

                  MyTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false
                  ),

                  const SizedBox(height: 10),

                  MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true
                  ),

                  const SizedBox(height: 25),

                  MyButton(
                      onTap: signIn,
                      text: 'Sign In'
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Not a member?'),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                          child: const Text(
                        'Register now',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                        ),
                      ),
                      )

                    ],
                  ),

                ],
              )
          )

        )

      ),
    );
  }
}
