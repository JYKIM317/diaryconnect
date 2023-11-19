import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

//Map<String, dynamic>'eventList' : {'2023.11.7' : [], '2023.11.21' : []} //all events user setup
//List<Map<String, dynamic>> year.month.day(ex: 2023.11.7) : [event, event..]// several events
/*
  Map<String, dynamic> event = {
    'date' : DateTime().toString
    'detail' : String
  }
*/

Future<void> saveEvent({required DateTime date, required String detail}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String eventName = '${date.year}.${date.month}.${date.day}';
  String dateToString = date.toString();
  Map<String, dynamic> event = {
    'date': dateToString,
    'detail': detail,
  };
  String eventData = jsonEncode(event);

  //해당 날짜 이벤트 리스트에 추가해서 업데이트
  List<String>? thisDayEvents = prefs.getStringList(eventName) ?? [];
  thisDayEvents.add(eventData);
  await prefs.setStringList(eventName, thisDayEvents);

  //전체 이벤트 리스트 불러와서 추가 후 업데이트
  String eventList = prefs.getString('eventList') ?? '{}';
  Map<String, dynamic> events = jsonDecode(eventList);
  List<dynamic> thisDayEventList = events[eventName] ?? [];
  thisDayEventList.add('event');
  events.remove(eventName);
  events.addAll({eventName: thisDayEventList});
  String eventListData = jsonEncode(events);
  await prefs.setString('eventList', eventListData);
}
