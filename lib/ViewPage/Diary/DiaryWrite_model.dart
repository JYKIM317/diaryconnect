import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'Diarys_model.dart';
import 'package:diaryconnect/CustomIcon.dart';

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
    //해당 년도에 작성 된 다이어리가 있지만 해당 달에 작성 된 다이어리가 하나도 없다면
    if (monthKeyCheck == null) {
      List<String> yearData = prefs.getStringList(yearKey)!;
      yearData.add(monthKey);
      await prefs.setStringList(yearKey, yearData);
      await prefs.setStringList(monthKey, [
        dayKey,
      ]);
      await prefs.setString(dayKey, entry);
    } else {
      //해당 달에 작성된 다이어리가 있을 때
      List<String> monthData = prefs.getStringList(monthKey)!;
      monthData.add(dayKey);
      await prefs.setStringList(monthKey, monthData);
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

Future<void> deleteEntry(DateTime date) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String yearKey = date.year.toString();
  final String monthKey = '$yearKey.${date.month}';
  final String dayKey = '$monthKey.${date.day}_${date.hour}:${date.minute}';

  String? entryDate = prefs.getString(dayKey);
  //entry가 실제로 storage에 있을 때 동작
  if (entryDate != null) {
    //entry 삭제
    await prefs.remove(dayKey);
    //monthKey List에서 entry remove 후
    List<String> monthEntries = prefs.getStringList(monthKey)!;
    monthEntries.remove(dayKey);
    //해당 달에 작성 된 entry가 남아있을 경우 그냥 업데이트
    if (monthEntries.isNotEmpty) {
      await prefs.setStringList(monthKey, monthEntries);
    } else {
      //해당 달에 작성 된 entry가 남아있지 않은 경우 monthKey 삭제 후  yearKey List에서 monthKey remove 한 뒤 업데이트
      await prefs.remove(monthKey);
      List<String> yearEntries = prefs.getStringList(yearKey)!;
      yearEntries.remove(monthKey);
      //해당 년도 다른 달에 작성 된 entry가 남아있을 경우 그냥 업데이트
      if (yearEntries.isNotEmpty) {
        await prefs.setStringList(yearKey, yearEntries);
      } else {
        //해당 년도에 작성 된 entry가 없을 경우 yearKey remove
        await prefs.remove(yearKey);
      }
    }
  }
}

String weatherToString(IconData weatherIcon) {
  late String weatherToString;
  switch (weatherIcon) {
    case CustomIcon.sun:
      weatherToString = 'sun';
      break;
    case CustomIcon.cloud_sun_1:
      weatherToString = 'cloud_sun';
      break;
    case CustomIcon.clouds:
      weatherToString = 'clouds';
      break;
    case CustomIcon.rain:
      weatherToString = 'rain';
      break;
    case CustomIcon.hail:
      weatherToString = 'snow';
      break;
  }
  return weatherToString;
}

String moodToString(IconData moodIcon) {
  late String moodToString;
  switch (moodIcon) {
    case CustomIcon.emo_happy:
      moodToString = 'good';
      break;
    case CustomIcon.emo_sleep:
      moodToString = 'not_bad';
      break;
    case CustomIcon.emo_unhappy:
      moodToString = 'bad';
      break;
    case CustomIcon.emo_surprised:
      moodToString = 'suprised';
      break;
    case CustomIcon.emo_angry:
      moodToString = 'angry';
      break;
    case CustomIcon.emo_cry:
      moodToString = 'cry';
      break;
  }
  return moodToString;
}

Future<void> entrySave({
  required IconData weather,
  required IconData mood,
  required DateTime date,
  required String detail,
  required String image,
}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String weatherString = weatherToString(weather);
  final String moodString = moodToString(mood);
  final String dateString = date.toString();
  final String entryName =
      '${date.year}.${date.month}.${date.day}_${date.hour}:${date.minute}';
  Map<String, dynamic> responseData = {
    'weather': weatherString, //String
    'mood': moodString, //String
    'date': dateString, //String
    'detail': detail, //String
    'image': image, //String
  };
  final String entryData = jsonEncode(responseData);
  await prefs.setString(entryName, entryData);
}

Future<String> getImage() async {
  String image = 'null';
  XFile? pickedImage;
  final ImagePicker picker = ImagePicker();
  pickedImage = await picker.pickImage(source: ImageSource.gallery);
  if (pickedImage != null) {
    image = pickedImage.path;
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: image);
    if (croppedImage != null) {
      List<int> imageBytes = await File(croppedImage.path).readAsBytesSync();
      String base64Image = base64Encode(imageBytes);
      image = base64Image;
    } else {
      image = 'null';
    }
  } else {
    image = 'null';
  }

  return image;
}
