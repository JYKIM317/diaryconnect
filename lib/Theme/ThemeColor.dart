import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

Color themeColorData = Colors.indigo;

class ThemeNotifier extends StateNotifier<Color> {
  ThemeNotifier() : super(themeColorData);
  lightGreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', 'lightGreen');
    state = Colors.lightGreen;
  }

  indigo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', 'indigo');
    state = Colors.indigo;
  }

  brown() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', 'brown');
    state = Colors.brown;
  }

  lightBlue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', 'lightBlue');
    state = Colors.lightBlue;
  }
}
