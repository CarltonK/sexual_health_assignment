import 'package:flutter/material.dart';
import 'package:sexual_health_assignment/utilities/utilities.dart';

class GlobalActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String action;

  GlobalActionButton({
    Key? key,
    required this.action,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: getProportionateScreenHeight(56),
      child: MaterialButton(
        shape: Constants.curvedRectBorder,
        color: Theme.of(context).primaryColor,
        onPressed: onPressed,
        child: Text(
          action,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(18),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
