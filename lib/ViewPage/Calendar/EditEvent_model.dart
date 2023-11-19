import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
