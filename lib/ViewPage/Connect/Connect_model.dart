import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:diaryconnect/CustomIcon.dart';

/* 
  User? user = FirebaseAuth.instance.currentUser;
  String? userUID = user!.uid;
*/

/* Diary model data 
 <String>year.month.day_time(ex: 2023.9.1_14:24) : <Map<String, dynamic>>{key:value} //dayKey : entry

  <Map<String, dynamic>>entry {
    'weather' : 'sun' // etc) rain, clouds, cloud_sun, snow, 
    'mood' : 'good' // etc) not_bad, bad, suprised, angry, cry
    'date' : '2023.11.8 0:30:28' //DateTime.now().toString()
    'detail' : 'brr brr~ brr' 
    'image' : 'base64Encode data' //String base64Image = base64Encode(imageBytes) / int8List bytes = base64Decode(prefs.getString("image"));
  }
*/

/* Calendar model data
  //Map<String, dynamic>'eventList' : {'2023.11.7' : [], '2023.11.21' : []} //all events user setup
  //List<Map<String, dynamic>> year.month.day(ex: 2023.11.7) : [event, event..]// several events

  Map<String, dynamic> event = {
    'date' : DateTime().toString
    'detail' : String
  }
*/

//-- calendar model part --//

Future<List<Map<String, dynamic>>> getSelectedDayEvent(
    DateTime selectedDay) async {
  List<Map<String, dynamic>>? events = [];
  final String eventDayKey =
      '${selectedDay.year}.${selectedDay.month}.${selectedDay.day}';

  User? user = FirebaseAuth.instance.currentUser;
  String? userUID = user!.uid;
  final eventFromFirebase = await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Calendar')
      .doc(eventDayKey)
      .get();
  Map<String, dynamic>? eventData = eventFromFirebase.data();
  List<dynamic>? eventList = eventData!['Events'];
  if (eventList != null) {
    for (String event in eventList) {
      //String to Map (jsonDecode)
      Map<String, dynamic> eventIndex = jsonDecode(event);
      DateTime stringToDate = DateTime.parse(eventIndex['date']);
      eventIndex['date'] = stringToDate;
      events.add(eventIndex);
    }
    if (events.length > 1) {
      events.sort((a, b) => a['date'].compareTo(b['date']));
    }
  }
  return events;
}

Future<Map<String, dynamic>> getEventCount() async {
  Map<String, dynamic> eventList = {};
  User? user = FirebaseAuth.instance.currentUser;
  String? userUID = user!.uid;
  final eventListFromFirebase = await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Calendar')
      .doc('EventList')
      .get();
  Map<String, dynamic>? eventListData = eventListFromFirebase.data();
  if (eventListData != null) {
    eventList.addAll(eventListData);
  }
  return eventList;
}

//-- diarys model part --//

Future<List<Map<String, dynamic>>> getEntries() async {
  List<Map<String, dynamic>> myDiarys = [];

  User? user = FirebaseAuth.instance.currentUser;
  String? userUID = user!.uid;
  //Firestore diary data list 를 date 기준 내림차순으로 가져오기
  var diaryListFromFirebase = await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Diary')
      .orderBy('date', descending: true)
      .get();
  List<DocumentSnapshot> diaryList = diaryListFromFirebase.docs.toList();
  for (DocumentSnapshot diary in diaryList) {
    var diarySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUID)
        .collection('Diary')
        .doc(diary.id)
        .get();
    Map<String, dynamic>? diaryData = diarySnapshot.data();
    DateTime thisDiaryDate = diaryData!['date'].toDate();
    diaryData['date'] = thisDiaryDate.toString();
    //myDiarys 첫번째에 monthFlag 생성
    if (myDiarys.isEmpty) {
      Map<String, dynamic> flagData = {
        'date': thisDiaryDate,
        'monthFlag': thisDiaryDate.month.toString(),
        'yearFlag': thisDiaryDate.year.toString(),
      };
      myDiarys.add(flagData);
    } else {
      //첫번째 엔트리 앞을 제외한 나머지 엔트리에서 전 엔트리와 비교해 month가 다를 경우 date flag 생성
      DateTime beforeDataDate = DateTime.parse(myDiarys.last['date']);
      if (beforeDataDate.month != thisDiaryDate.month) {
        Map<String, dynamic> flagData = {
          'date': thisDiaryDate,
          'monthFlag': thisDiaryDate.month.toString(),
          'yearFlag': thisDiaryDate.year.toString(),
        };
        myDiarys.add(flagData);
      }
    }
    myDiarys.add(diaryData);
  }

  return myDiarys;
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
