import 'package:flutter/material.dart';

import '../../constants/global.dart';

class ModalDialog extends StatefulWidget {
  const ModalDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<ModalDialog> createState() => _ModalDialogState();
}

class _ModalDialogState extends State<ModalDialog> {
  final ipController = TextEditingController();
  final portController = TextEditingController();

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Configure parameters",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("ip"),
          TextField(
            controller: ipController,
          ),
          const Text("port"),
          TextField(
            controller: portController,
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              ip = ipController.text;
              port = portController.text;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
          ),
          child: const Text('OK'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
          ),
          child: const Text('Cancel'),
        )
      ],
    );
  }
}
