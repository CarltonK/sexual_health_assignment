import 'package:flutter/material.dart';
import 'package:sexual_health_assignment/utilities/utilities.dart';

class FormError extends StatelessWidget {
  const FormError({
    Key? key,
    required this.errors,
  }) : super(key: key);

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        errors.length,
        (index) => formErrorText(error: errors[index]),
      ),
    );
  }

  Padding formErrorText({String? error}) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        children: [
          Icon(Icons.error),
          SizedBox(width: getProportionateScreenWidth(10)),
          Text(error!),
        ],
      ),
    );
  }
}
