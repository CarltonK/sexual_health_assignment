import 'dart:async';
// Only show Timestamp
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sexual_health_assignment/models/models.dart';
import 'package:sexual_health_assignment/provider/provider.dart';
import 'package:sexual_health_assignment/utilities/utilities.dart';
import 'package:sexual_health_assignment/widgets/widgets.dart';

class SignUpForm extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  SignUpForm({Key? key, required this.scaffoldKey}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _signUpFormKey = GlobalKey<FormState>();

  UserModel? user;

  String? email, fullName, password, confirmPassword, gender, genitalia;
  Timestamp? _dob;

  dynamic _registrationResult;

  final List<String> errors = [];

  final _focusPassword = FocusNode();
  final _focusConfirmPassword = FocusNode();
  final _focusEmail = FocusNode();

  TextEditingController? passwordTextController;
  TextEditingController? confirmPasswordTextController;

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

  TextFormField buildFullNameField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      onSaved: (newValue) => fullName = newValue!.trim(),
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: Constants.kNamelNullError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: Constants.kNamelNullError);
          return '';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_focusEmail);
      },
      decoration: InputDecoration(
        labelText: 'Full Name',
        hintText: 'Enter your full name',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(Icons.person),
      ),
    );
  }

  TextFormField buildEmailField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      focusNode: _focusEmail,
      onSaved: (newValue) => email = newValue!.trim(),
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: Constants.kInvalidEmailError);
        } else if (Constants.emailValidatorRegExp.hasMatch(value)) {
          removeError(error: Constants.kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: Constants.kInvalidEmailError);
          return '';
        } else if (!Constants.emailValidatorRegExp.hasMatch(value)) {
          addError(error: Constants.kInvalidEmailError);
          return '';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_focusPassword);
      },
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(Icons.email),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      controller: passwordTextController,
      focusNode: _focusPassword,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_focusConfirmPassword);
      },
      onSaved: (newValue) => password = newValue!.trim(),
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

  TextFormField buildConfirmPasswordFormField() {
    return TextFormField(
      obscureText: true,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.text,
      controller: confirmPasswordTextController,
      focusNode: _focusConfirmPassword,
      onFieldSubmitted: (value) {
        KeyboardUtil.hideKeyboard(context);
        registrationButtonPressed();
      },
      onSaved: (newValue) => confirmPassword = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: Constants.kPassNullError);
        } else if (value.length < 6) {
          removeError(error: Constants.kShortPassError);
        } else if (value != passwordTextController!.text) {
          removeError(error: Constants.kMatchPassError);
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
        } else if (value != passwordTextController!.text) {
          addError(error: Constants.kMatchPassError);
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Enter your password again',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Icon(Icons.vpn_key),
      ),
    );
  }

  Widget buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date of Birth',
          ),
          Container(
            height: 200,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (DateTime newDateTime) {
                _dob = Timestamp.fromDate(newDateTime);
              },
            ),
          ),
        ],
      ),
    );
  }

  buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.only(top: 15),
      child: DropdownButton<String>(
        value: gender,
        onChanged: _genderChanged,
        icon: Icon(Icons.arrow_downward, color: Theme.of(context).accentColor),
        hint: Text('Gender'),
        items: Constants.gender
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        isExpanded: true,
        isDense: false,
        underline: Container(color: Colors.transparent),
      ),
    );
  }

  _genderChanged(String? value) {
    gender = value;
  }

  buildGenitaliaSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.only(top: 15),
      child: DropdownButton<String>(
        value: genitalia,
        onChanged: _genitaliaChanged,
        icon: Icon(Icons.arrow_downward, color: Theme.of(context).accentColor),
        hint: Text('Genitalia'),
        items: Constants.genitalia
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        isExpanded: true,
        isDense: false,
        underline: Container(color: Colors.transparent),
      ),
    );
  }

  _genitaliaChanged(String? value) {
    genitalia = value;
  }

  Future<bool> _regHandler(UserModel user) async {
    _registrationResult = await context.read<AuthProvider>().createUser(user);

    if (_registrationResult.runtimeType == String) {
      return false;
    } else {
      user.uid = _registrationResult.uid;
      return true;
    }
  }

  registrationButtonPressed() {
    if (_dob == null) {
      Timer(Duration(milliseconds: 200), () async {
        await showInfoDialog(
          widget.scaffoldKey.currentContext!,
          'Please select the date of birth',
        );
      });
    } else if (gender == null) {
      Timer(Duration(milliseconds: 200), () async {
        await showInfoDialog(
          widget.scaffoldKey.currentContext!,
          'Please select your gender',
        );
      });
    }
    if (genitalia == null) {
      Timer(Duration(milliseconds: 200), () async {
        await showInfoDialog(
          widget.scaffoldKey.currentContext!,
          'Please select your genitalia',
        );
      });
    } else {
      final FormState _formState = _signUpFormKey.currentState!;
      if (_formState.validate()) {
        _formState.save();

        KeyboardUtil.hideKeyboard(context);

        user = UserModel(
          email: email,
          name: fullName,
          password: confirmPassword,
          dob: _dob,
          gender: gender,
          genitalia: genitalia,
        );

        _regHandler(user!).then((value) {
          if (!value) {
            Timer(Duration(milliseconds: 500), () async {
              await showInfoDialog(
                widget.scaffoldKey.currentContext!,
                _registrationResult,
              );
            });
          } else {
            Navigator.of(context).pop();
          }
        }).catchError((error) {
          Timer(Duration(milliseconds: 500), () async {
            await showInfoDialog(
              widget.scaffoldKey.currentContext!,
              error.toString(),
            );
          });
        });
      }
    }
  }

  @override
  void initState() {
    passwordTextController = TextEditingController();
    confirmPasswordTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    passwordTextController!.dispose();
    confirmPasswordTextController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        children: [
          buildFullNameField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildEmailField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildDateSelector(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildGenderSelector(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildGenitaliaSelector(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildConfirmPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),
          GlobalActionButton(
            action: 'Register',
            onPressed: registrationButtonPressed,
          ),
          SizedBox(height: DeviceConfig.screenHeight! * 0.01),
        ],
      ),
    );
  }
}
