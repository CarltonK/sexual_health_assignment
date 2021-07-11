import 'package:flutter/material.dart';
import 'package:sexual_health_assignment/screens/screens.dart';

final GlobalKey<ScaffoldState> _scaffoldRegKey = GlobalKey<ScaffoldState>();

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldRegKey,
      appBar: AppBar(
        title: Text(
          'Sign Up',
        ),
      ),
      body: SignUpBody(scaffoldKey: _scaffoldRegKey),
    );
  }
}
