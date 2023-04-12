import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String response;

  const CustomAlertDialog({
    Key? key,
    required this.response,
  }) : super(key: key);

  static void show(
    String text, {
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertDialog(response: text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        response,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
          ),
          child: const Text('OK'),
        )
      ],
    );
  }
}
