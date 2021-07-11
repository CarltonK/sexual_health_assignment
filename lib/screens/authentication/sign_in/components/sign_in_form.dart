import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sexual_health_assignment/models/models.dart';
import 'package:sexual_health_assignment/provider/provider.dart';
import 'package:sexual_health_assignment/screens/screens.dart';
import 'package:sexual_health_assignment/utilities/utilities.dart';
import 'package:sexual_health_assignment/widgets/widgets.dart';

class SignInForm extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  SignInForm({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _signInFormKey = GlobalKey<FormState>();

  UserModel? user;
  String? email, password;
  final List<String> errors = [];

  final _focusPassword = FocusNode();

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error!);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  TextFormField buildEmailField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: Constants.kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: Constants.kInvalidEmailError);
          return '';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_focusPassword);
      },
      decoration: InputDecoration(
        labelText: 'Email Address',
        hintText: 'Enter your email',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(Icons.email),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.text,
      focusNode: _focusPassword,
      onFieldSubmitted: (value) {
        KeyboardUtil.hideKeyboard(context);
        loginButtonPressed();
      },
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: Constants.kPassNullError);
        } else if (value.length < 6) {
          removeError(error: Constants.kShortPassError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: Constants.kPassNullError);
          return '';
        } else if (value.length < 6) {
          addError(error: Constants.kShortPassError);
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(Icons.vpn_key),
      ),
    );
  }

  Future loginHandler(UserModel user) async {
    return await context.read<AuthProvider>().signInEmailPass(user);
  }

  loginButtonPressed() {
    final FormState _formState = _signInFormKey.currentState!;
    if (_formState.validate()) {
      _formState.save();

      KeyboardUtil.hideKeyboard(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signInFormKey,
      child: Column(
        children: [
          buildEmailField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),
          GlobalActionButton(
            action: 'Login',
            onPressed: loginButtonPressed,
          ),
          SizedBox(height: DeviceConfig.screenHeight! * 0.01),
        ],
      ),
    );
  }
}
