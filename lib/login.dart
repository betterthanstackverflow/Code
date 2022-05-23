import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login/flutter_login.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  Future<String?> _authUser(LoginData data) async {
    // debugPrint('Name: ${data.name}, Password: ${data.password}');
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: data.name, password: data.password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
      return 'Unexpected error :(';
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    if (data.name == null || data.password == null) {
      return 'Both fields must be filled';
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: data.name!, password: data.password!);
      await userCredential.user!.updateDisplayName(
        data.additionalSignupData!['Username'],
      );
      await userCredential.user!.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.code;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return 'Unexpected error :(';
  }

  Future<String?> _recoverPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyLoginPage object that was created by
        // the App.build method, and use it to set our appbar title.
        centerTitle: true,
        title: const Text(
          'LOGIN PAGE',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        leading: IconButton(
          icon: const Icon(Icons.house),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FlutterLogin(
          title: ('BetterThanStackOverflow'),
          onLogin: _authUser,
          onSignup: _signupUser,
          onRecoverPassword: _recoverPassword,
          additionalSignupFields: const [
            UserFormField(keyName: 'Username'),
          ],
          onSubmitAnimationCompleted: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          theme: LoginTheme(
            titleStyle: TextStyle(color: Colors.blueGrey[700]),
            primaryColor: Colors.blueGrey[200],
            accentColor: Colors.blueGrey[600],
            buttonTheme:
                LoginButtonTheme(backgroundColor: Colors.blueGrey[600]),
            switchAuthTextColor: Colors.blueGrey[600],
          ),
        ),
      ),
    );
  }
}
