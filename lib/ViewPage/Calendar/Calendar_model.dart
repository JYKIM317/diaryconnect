import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

//List<String> 'eventList' : ['2023.11.7', '2023.11.21',] //all events user setup
//List<Map<String, dynamic>> year.month.day(ex: 2023.11.7) : [event, event..]// several events
/*
  Map<String, dynamic> event = {
    'date' : DateTime()
    'detail' : String
  }
*/

Future<List<Map<String, dynamic>>> getSelectedDayEvent(
    DateTime selectedDay) async {
  List<Map<String, dynamic>>? events = [];
  final String eventDayKey =
      '${selectedDay.year}.${selectedDay.month}.${selectedDay.day}';
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final List<String>? dayEvents = prefs.getStringList(eventDayKey);
  if (dayEvents != null) {
    for (String event in dayEvents) {
      //String to Map (jsonDecode)
      Map<String, dynamic> eventIndex = jsonDecode(event);
      events.add(eventIndex);
    }
  }
  return events;
}

Future<Map<String, List<dynamic>>> getEventCount() async {
  Map<String, List<dynamic>> eventList = {};
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? events = prefs.getString('eventList');
  if (events != null) {
    eventList = jsonDecode(events);
  }
  return eventList;
}
