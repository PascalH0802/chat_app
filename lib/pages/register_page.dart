import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  //textControllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp() async {
    if(passwordController.text != confirmPasswordController.text){
        Fluttertoast.showToast(
          msg: "Passwords don't match",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
    }

    // get the auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    try{
      await authService.signUpWithUsernameAndPassword(usernameController.text, passwordController.text);
    }catch (e) {
      Fluttertoast.showToast(
        msg: "Username already in use",
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
                        "Let's create an account!",
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

                      const SizedBox(height: 10),

                      MyTextField(
                          controller: confirmPasswordController,
                          hintText: 'Confirm Password',
                          obscureText: true
                      ),

                      const SizedBox(height: 25),

                      MyButton(
                          onTap: signUp,
                          text: 'Sign Up'
                      ),

                      const SizedBox(height: 25),

                       Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already a member?'),
                           SizedBox(width: 4),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: const Text(
                              'Login now',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          )

                        ],
                      )
                    ],
                  )
              )

          )

      ),
    );
  }
}

