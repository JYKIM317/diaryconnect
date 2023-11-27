import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> editEvent({
  required DateTime initialDate,
  required String initialDetail,
  required DateTime changeDate,
  required String changeDetail,
}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String eventName =
      '${initialDate.year}.${initialDate.month}.${initialDate.day}';
  //기존 데이터
  String initialDateToString = initialDate.toString();
  Map<String, dynamic> initialEvent = {
    'date': initialDateToString,
    'detail': initialDetail,
  };
  String initialEventData = jsonEncode(initialEvent);

  //변경 데이터
  String changeDateToString = changeDate.toString();
  Map<String, dynamic> changeEvent = {
    'date': changeDateToString,
    'detail': changeDetail,
  };
  String changeEventData = jsonEncode(changeEvent);

  //해당 날짜 이벤트 리스트에 기존 데이터 삭제 후 추가해서 업데이트
  List<String> thisDayEvents = prefs.getStringList(eventName)!;
  thisDayEvents.remove(initialEventData);
  thisDayEvents.add(changeEventData);
  await prefs.setStringList(eventName, thisDayEvents);
}

Future<void> deleteEvent(
    {required DateTime date, required String detail}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String eventName = '${date.year}.${date.month}.${date.day}';
  //기존 데이터
  String dateToString = date.toString();
  Map<String, dynamic> initialEvent = {
    'date': dateToString,
    'detail': detail,
  };
  String eventData = jsonEncode(initialEvent);
  //해당 날짜 데이터 불러와서 삭제 후 업데이트
  List<String> thisDayEvents = prefs.getStringList(eventName)!;
  thisDayEvents.remove(eventData);
  if (thisDayEvents.isEmpty) {
    //해당 날짜 다른 데이터 없을 시 키값 삭제
    await prefs.remove(eventName);
  } else {
    //해당 날짜 다른 데이터 있을 시 삭제 요청 데이터만 삭제 후 업데이트
    await prefs.setStringList(eventName, thisDayEvents);
  }

  //전체 이벤트 리스트 불러와서 요소1개 삭제 후 업데이트
  String eventList = prefs.getString('eventList')!;
  Map<String, dynamic> events = jsonDecode(eventList);
  List<dynamic> thisDayEventList = events[eventName];
  //해당 날짜에서 요소 1개 삭제
  thisDayEventList.removeAt(0);
  //eventList에서 해당 날짜 데이터 삭제 후
  events.remove(eventName);
  if (thisDayEventList.isNotEmpty) {
    //해당 날짜에 event가 남은 경우에만 eventList에 다시 추가
    events.addAll({eventName: thisDayEventList});
  }
  String eventListData = jsonEncode(events);
  await prefs.setString('eventList', eventListData);
}

Future<void> shareEvent({
  required DateTime date,
  required String detail,
  required String uid,
}) async {
  String? userUID = FirebaseAuth.instance.currentUser!.uid;
  String eventName = '${date.year}.${date.month}.${date.day}';

  String dateToString = date.toString();
  Map<String, dynamic> event = {
    'date': dateToString,
    'detail': detail,
    'uid': userUID,
  };
  //업데이트 할 event
  String eventData = jsonEncode(event);

  //상대에게 이벤트 추가
  final eventAdress = await FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .collection('Calendar')
      .doc(eventName)
      .get();
  Map<String, dynamic>? events = eventAdress.data() ?? {};
  List<dynamic> eventList = events['Events'] ?? [];
  eventList.add(eventData);
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .collection('Calendar')
      .doc(eventName)
      .set({'Events': eventList});

  //상대 이벤트 카운트 추가
  final eventCountAdress = await FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .collection('Calendar')
      .doc('EventList')
      .get();
  Map<String, dynamic>? eventCount = eventCountAdress.data() ?? {};
  List<dynamic> eventCountList = eventCount[eventName] ?? [];
  eventCountList.add('event');
  eventCount[eventName] = eventCountList;
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .collection('Calendar')
      .doc('EventList')
      .set(eventCount);

  //나에게 이벤트 추가
  final myEventAdress = await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Calendar')
      .doc(eventName)
      .get();
  Map<String, dynamic>? myEvents = myEventAdress.data() ?? {};
  List<dynamic> myEventList = myEvents['Events'] ?? [];
  myEventList.add(eventData);
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Calendar')
      .doc(eventName)
      .set({'Events': myEventList});

  //내 이벤트 카운트 추가
  final myEventCountAdress = await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Calendar')
      .doc('EventList')
      .get();
  Map<String, dynamic>? myEventCount = myEventCountAdress.data() ?? {};
  List<dynamic> myEventCountList = myEventCount[eventName] ?? [];
  myEventCountList.add('event');
  myEventCount[eventName] = myEventCountList;
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Calendar')
      .doc('EventList')
      .set(myEventCount);
}
