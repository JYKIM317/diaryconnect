import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteConnectEvent({
  required DateTime date,
  required String detail,
  required String uid,
}) async {
  String? userUID = FirebaseAuth.instance.currentUser!.uid;
  String eventName = "${date.year}.${date.month}.${date.day}";

  Map<String, dynamic> onDayEvent = {
    'date': date.toString(),
    'detail': detail,
    'uid': uid
  };
  String eventToString = jsonEncode(onDayEvent);
  //해당 날짜 동일 이벤트 제거
  final dayEvent = await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Calendar')
      .doc(eventName)
      .get();
  Map<String, dynamic>? events = dayEvent.data();
  List<dynamic> eventList = events!['Events'];
  eventList.remove(eventToString);
  if (eventList.isNotEmpty) {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUID)
        .collection('Calendar')
        .doc(eventName)
        .set({'Events': eventList});
  } else {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userUID)
        .collection('Calendar')
        .doc(eventName)
        .delete();
  }

  //Event Count 해당 날짜 요소 1개 제거 후 업데이트
  final eventCountList = await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Calendar')
      .doc('EventList')
      .get();
  Map<String, dynamic>? eventCount = eventCountList.data();
  List<dynamic> eventDayCount = eventCount![eventName];
  eventDayCount.removeAt(0);
  if (eventDayCount.isNotEmpty) {
    eventCount[eventName] = eventDayCount;
  } else {
    eventCount.remove(eventName);
  }

  await FirebaseFirestore.instance
      .collection('Users')
      .doc(userUID)
      .collection('Calendar')
      .doc('EventList')
      .set(eventCount);
}
