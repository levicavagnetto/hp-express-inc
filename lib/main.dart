import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_screen.dart';
import 'config.dart';

void main() {
  runApp(const HPExpressApp());
}

class HPExpressApp extends StatelessWidget {
  const HPExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.companyName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
