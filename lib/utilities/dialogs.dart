import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sexual_health_assignment/widgets/widgets.dart';

Future dialogExitApp(BuildContext context, Function yesClick) {
  return showCupertinoModalPopup(
    context: context,
    builder: (context) => LogOutDialog(yesClick: yesClick),
  );
}

Future showInfoDialog(BuildContext context, String message) {
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      content: GlobalInfoDialog(message: message),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
