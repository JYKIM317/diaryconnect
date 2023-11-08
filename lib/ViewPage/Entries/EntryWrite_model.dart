import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'Entries_model.dart';

//Image image = Image.memory(base64Decode(thisEntry['image']));
/*Map<String, dynamic> entryData = {
                  'weather': weather,
                  'mood': mood,
                  'date': date,
                  'detail': detail,
                  'dayOfWeek': dayOfWeek,
                  'image': image,
                };*/

Future<Map<String, dynamic>> makeEntryCase() async {
  final DateTime today = DateTime.now();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String date = today.toString();
  const String mood = 'good', weather = 'sun', detail = '', image = 'null';
  Map<String, dynamic> newEntry = {
    'weather': weather,
    'mood': mood,
    'date': date,
    'detail': detail,
    'image': image,
  };
  final String dayOfWeek = DateFormat('E', 'en_US').format(today);

  final String yearKey = today.year.toString();
  final String monthKey = '$yearKey.${today.month}';
  final String dayKey = '$monthKey.${today.day}_${today.hour}:${today.minute}';

  final List<String>? yearKeyCheck = prefs.getStringList(yearKey);
  final String entry = jsonEncode(newEntry);
  //해당 년도에 작성 된 다이어리가 하나도 없다면
  if (yearKeyCheck == null) {
    await prefs.setStringList(yearKey, [
      monthKey,
    ]);
    await prefs.setStringList(monthKey, [
      dayKey,
    ]);
    await prefs.setString(dayKey, entry);
  } else {
    final List<String>? monthKeyCheck = prefs.getStringList(monthKey);
    //해당 달에 작성 된 다이어리가 하나도 없다면
    if (monthKeyCheck == null) {
      await prefs.setStringList(monthKey, [
        dayKey,
      ]);
      await prefs.setString(dayKey, entry);
    } else {
      await prefs.setString(dayKey, entry);
    }
  }

  final IconData resWeather = weatherIconData(weather);
  final IconData resMood = moodIconData(mood);
  final DateTime resDate = DateTime.parse(date);
  const String resDetail = detail;
  final String resDayOfWeek = DateFormat('E', 'en_US').format(resDate);
  const String resImage = image;

  Map<String, dynamic> responseEntryData = {
    'weather': resWeather,
    'mood': resMood,
    'date': resDate,
    'detail': resDetail,
    'dayOfWeek': resDayOfWeek,
    'image': resImage,
  };

  return responseEntryData;
}
