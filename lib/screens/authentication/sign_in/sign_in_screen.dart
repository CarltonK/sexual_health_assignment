import 'package:flutter/material.dart';
import 'package:sexual_health_assignment/screens/screens.dart';

final GlobalKey<ScaffoldState> _scaffoldLoginKey = GlobalKey<ScaffoldState>();

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldLoginKey,
      appBar: AppBar(
        title: Text(
          'Sign In',
        ),
      ),
      body: SignInBody(scaffoldKey: _scaffoldLoginKey),
    );
  }
}
