import 'package:flutter/material.dart';

void showAlertDialog(BuildContext context, String message, String confirm) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              confirm,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      );
    },
  );
}
