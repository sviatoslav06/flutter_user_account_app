import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.blue,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14),
    ),
  );
}
