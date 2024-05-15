import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'crntpg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.orange,
              Colors.amber,
            ],
          ),
        ),
        child: _page(),
      ),
    );
  }

  Widget _page() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _icon(),
            const SizedBox(height: 50),
            _inputField("Username", emailController),
            const SizedBox(height: 20), // Reduced SizedBox height
            _inputField("Password", passController, isPassword: true),
            const SizedBox(height: 20), // Reduced SizedBox height
            Text(
              errorMessage,
              style: const TextStyle(fontWeight: FontWeight.bold , color: Colors.red),
            ),
            const SizedBox(height: 20),
            _loginBtn(),
          ],
        ),
      ),
    );
  }

  Widget _icon() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 120),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.brown),
    );

    return TextField(
      style: const TextStyle(color: Colors.brown),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
        enabledBorder: border,
        focusedBorder: border,
      ),
      obscureText: isPassword,
    );
  }

  Widget _loginBtn() {
    return ElevatedButton(
      onPressed: () async {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text,
            password: passController.text,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Crntpg()),
          );
        } catch (e) {
          setState(() {
            errorMessage = 'Email or password is incorrect.';
          });
        }
      },
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          "Log in",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blue,
        shape: const StadiumBorder(),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
