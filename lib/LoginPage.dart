import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'Config.dart';
import 'Gmaps.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    signInOption: SignInOption.standard,
    clientId: config.googleClientId,
    scopes: ['email'],
  );
  GoogleSignInAccount? _currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
body: Center(
  child:ElevatedButton(onPressed: ()async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        _currentUser = googleUser;
        print("User ${_currentUser!.email}");
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final String? idToken = googleAuth.idToken;
        if (kDebugMode) {
          print("Token Id $idToken");
        }


        final String? email = _currentUser!.email;
        final String? name = _currentUser!.displayName;
        Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>GoogleMapsPage()));

      }
    } catch (error) {
      if (kDebugMode) {
        print("Error $error");
      }
      Fluttertoast.showToast(
        msg: "Sign-in failed: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    }

  }, child: Text("Login with google"),

  )
),

    );
  }
}
