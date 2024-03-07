import 'package:flutter/material.dart';

void showSnackBarNotification(
    BuildContext context, String message, Color color) {
  final snackBar = SnackBar(
    backgroundColor: color,
    content: Text(message),
    duration: const Duration(milliseconds: 1000), // Adjust the duration
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
