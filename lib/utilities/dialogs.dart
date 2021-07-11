import 'package:flutter/cupertino.dart';
import 'package:sexual_health_assignment/widgets/widgets.dart';

Future dialogExitApp(BuildContext context, Function yesClick) {
  return showCupertinoModalPopup(
    context: context,
    builder: (context) => LogOutDialog(yesClick: yesClick),
  );
}
