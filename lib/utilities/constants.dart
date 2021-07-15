import 'package:flutter/material.dart';

class Constants {
  // Constructor
  Constants.empty();

  // Genitalia
  static const List<String> genitalia = ['male', 'female', 'other'];

  // Genders
  static const List<String> gender = [
    'lesbian',
    'gay',
    'bisexual',
    'transgender',
    'questioning',
    'queer',
    'intersex',
    'pansexual',
    'two-spirit',
    'androgynous',
    'asexual'
  ];

  /*
  TEXT STYLES
  */
  static const TextStyle boldHeadlineStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 30,
  );

  static const TextStyle whiteBoldSubheadlineStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle blackBoldNormal = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle boldSubheadlineStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  /*
  BORDERS
  */
  static const InputBorder blackInputBorder = UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
  );

  static RoundedRectangleBorder curvedRectBorder =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

  /*
  REGEX
  */
  static RegExp emailValidatorRegExp =
      RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  /*
  FORM ERRORS
  */
  static const String kInvalidEmailError = 'Please enter a valid Email';
  static const String kPassNullError = 'Please enter your password';
  static const String kShortPassError = 'Password is too short';
  static const String kMatchPassError = 'Passwords don\'t match';
  static const String kNamelNullError = 'Please enter your name';

  // Sizing
  static const double padding = 20;
  static const double avatarRadius = 45;
}
