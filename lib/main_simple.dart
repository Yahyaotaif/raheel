import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final logger = Logger();

void main() {
  logger.i('=== SIMPLE MAIN STARTING ===');
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text(
          'Hello, This is a test!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    ),
  ));
  logger.i('=== SIMPLE MAIN ENDED ===');
}
