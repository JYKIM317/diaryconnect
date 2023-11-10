import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diaryconnect/CustomIcon.dart';

/*
  Data roles //key:value
  <String>year(ex: 2023) : <List<String>>['2023.09','2023.10'] //yearKey : monthKey
  <String>year.month(ex: 2023.09) : <List<String>>['2023.09.01_11:24','2023.09.10_09:53'] //monthKey : dayKey
  <String>year.month.day(ex: 2023.09.01_11:24) : <Map<String, dynamic>>{key:value} //dayKey : entry

  <Map<String, dynamic>>entry {
    'weather' : 'sun' // etc) rain, clouds, cloud_sun, snow, 
    'mood' : 'good' // etc) not_bad, bad, suprised, angry, cry
    'date' : '2023-11-08 00:30:28' //DateTime.now().toString()
    'detail' : 'brr brr~ brr' 
    'image' : 'base64Encode data' //String base64Image = base64Encode(imageBytes) / int8List bytes = base64Decode(prefs.getString("image"));
  }
*/

Future<List<Map<String, dynamic>>> getEntries() async {
  List<Map<String, dynamic>> myEntries = [];
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  int thisYear = DateTime.now().year.toInt();
  int firstLoginYear = prefs.getInt('firstLoginYear') ?? thisYear;
  //thisYear부터 firstLoginYear까지 감소하는 for문
  for (thisYear; thisYear >= firstLoginYear; thisYear--) {
    String yearKey = thisYear.toString();
    List<String>? monthList = prefs.getStringList(yearKey);
    if (monthList != null) {
      monthList = monthList.reversed.toList();
      //해당 년도에 해당 월에 작성 된 data가 있으면 정확한 날짜 get
      for (String monthIndex in monthList) {
        String monthKey = monthIndex;
        List<String>? dayList = prefs.getStringList(monthKey);
        if (dayList != null) {
          dayList = dayList.reversed.toList();
          //정확한 날짜명 (key 값)으로 entry 내용 확인 후 map타입으로 변환해서 list로 저장
          for (String dayIndex in dayList) {
            String dayKey = dayIndex;
            String? entry = prefs.getString(dayKey);
            if (entry != null) {
              Map<String, dynamic> entriesData = jsonDecode(entry);

              //첫번째 엔트리 앞에 date flag 생성
              if (myEntries.isEmpty) {
                DateTime firstDataDate = DateTime.parse(entriesData['date']);
                Map<String, dynamic> flagData = {
                  'date': firstDataDate,
                  'monthFlag': firstDataDate.month.toString(),
                  'yearFlag': firstDataDate.year.toString(),
                };
                myEntries.add(flagData);
              } else {
                //첫번째 엔트리 앞을 제외한 나머지 엔트리에서 전 엔트리와 비교해 month가 다를 경우 date flag 생성
                DateTime beforeDataDate =
                    DateTime.parse(myEntries.last['date']);
                DateTime currentDataDate = DateTime.parse(entriesData['date']);
                if (beforeDataDate.month != currentDataDate.month) {
                  Map<String, dynamic> flagData = {
                    'date': currentDataDate,
                    'monthFlag': currentDataDate.month.toString(),
                    'yearFlag': currentDataDate.year.toString(),
                  };
                  myEntries.add(flagData);
                }
              }
              //엔트리 add
              myEntries.add(entriesData);
            }
          }
        }
      }
    }
  }
  return myEntries;
}

IconData weatherIconData(String weather) {
  late IconData loadIconData;
  switch (weather) {
    case 'sun':
      loadIconData = CustomIcon.sun;
      break;
    case 'cloud_sun':
      loadIconData = CustomIcon.cloud_sun_1;
      break;
    case 'clouds':
      loadIconData = CustomIcon.clouds;
      break;
    case 'rain':
      loadIconData = CustomIcon.rain;
      break;
    case 'snow':
      loadIconData = CustomIcon.hail;
      break;
    default:
      loadIconData = CustomIcon.sun;
  }
  return loadIconData;
}

IconData moodIconData(String mood) {
  late IconData loadIconData;
  switch (mood) {
    case 'good':
      loadIconData = CustomIcon.emo_happy;
      break;
    case 'not_bad':
      loadIconData = CustomIcon.emo_sleep;
      break;
    case 'bad':
      loadIconData = CustomIcon.emo_unhappy;
      break;
    case 'suprised':
      loadIconData = CustomIcon.emo_surprised;
      break;
    case 'angry':
      loadIconData = CustomIcon.emo_angry;
      break;
    case 'cry':
      loadIconData = CustomIcon.emo_cry;
      break;
    default:
      loadIconData = CustomIcon.emo_happy;
  }
  return loadIconData;
}
