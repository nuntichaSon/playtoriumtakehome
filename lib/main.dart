import 'package:flutter/material.dart';
import 'widgets/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discount Calculator',
      theme: ThemeData(
        primaryColor: Colors.deepPurple[700],  // Darker shade of purple for primary color
        hintColor: Colors.purple[300],  // Soft purple background color
        scaffoldBackgroundColor: Colors.purple[50],  // Background color of scaffold
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple[700],  // Deep purple for AppBar background
          foregroundColor: Colors.white,  // White text in AppBar
        ),
        
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.deepPurple[500],  // Purple color for buttons
          textTheme: ButtonTextTheme.primary,  // Text color in buttons
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple[300]!),  // Border color of inputs
            borderRadius: BorderRadius.circular(12),
          ),
        ), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple).copyWith(background: Colors.purple[50]),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
