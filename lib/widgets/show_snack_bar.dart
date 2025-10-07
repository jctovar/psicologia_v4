import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, [Color? color]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      duration: const Duration(seconds: 1),
      content: Text(message),
    ),
  );
}
