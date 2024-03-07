import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool onlyNumbers;

  const CustomTextField({super.key, 
    required this.controller,
    required this.hintText,
    this.onlyNumbers = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: controller,
        inputFormatters: onlyNumbers
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))]
            : null,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 2.0, color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey[300],
        ),
      ),
    );
  }
}
