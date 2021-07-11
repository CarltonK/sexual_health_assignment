import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LogOutDialog extends StatelessWidget {
  final Function yesClick;
  const LogOutDialog({
    Key? key,
    required this.yesClick,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('EXIT'),
      content: Text('Are you sure ? '),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('NO'),
        ),
        TextButton(
          onPressed: () {
            // Pop the dialog first
            Navigator.of(context).pop();
            // Perform the action
            yesClick();
          },
          child: Text('YES'),
        )
      ],
    );
  }
}
