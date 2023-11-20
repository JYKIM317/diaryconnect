import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:diaryconnect/main.dart';
import 'package:diaryconnect/Theme/ThemeLangauge.dart';
import 'Calendar_model.dart';
import 'AddEvent_view.dart';
import 'EditEvent_view.dart';
import 'package:diaryconnect/Theme/ChangeTheme_view.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(themeLang);
    String selectedLocale = getLangagueCode(lang);
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          //Menu button
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: EdgeInsets.fromLTRB(12.w, 47.h, 0, 0),
            alignment: Alignment.centerLeft,
            width: double.infinity,
            child: IconButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) {
                    //Theme/ChangeTheme_view.dart
                    return ChangeThemePage();
                  },
                );
              },
              icon: Icon(
                Icons.menu,
                color: Theme.of(context).colorScheme.secondary,
                size: 28.sp,
              ),
            ),
          ),
          //Calendar
          FutureBuilder(
              future: getEventCount(),
              initialData: const {
                //event initial data no reason
                'initialData': ['initialData'],
              },
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                //load EventList
                Map<String, dynamic>? eventDataLoad = snapshot.data;
                //실제 Calendar 부분
                return TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2000, 1, 1),
                  lastDay: DateTime(2099, 12, 31),
                  calendarFormat: _calendarFormat,
                  locale: selectedLocale,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: ((selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }),
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  daysOfWeekHeight: 24.h,
                  availableCalendarFormats: const {
                    CalendarFormat.month: "Month"
                  },
                  headerStyle: HeaderStyle(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    headerMargin: EdgeInsets.only(bottom: 20.h),
                    titleTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 18.sp,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    markerDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer),
                    markersAlignment: Alignment.bottomCenter,
                    markersMaxCount: 5,
                  ),
                  eventLoader: (day) =>
                      eventDataLoad?['${day.year}.${day.month}.${day.day}'] ??
                      [],
                );
              }),
          //divide calender and event
          Container(
            width: double.infinity,
            height: 2.h,
            margin: EdgeInsets.only(top: 10.h),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          //add event
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 10.w),
            child: IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEventPage(
                      date: _selectedDay,
                    ),
                  ),
                );
                setState(() {});
              },
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_selectedDay.month}.${_selectedDay.day} ',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    lang.addEvent,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 22.sp,
                  ),
                ],
              ),
            ),
          ),
          //show event
          Container(
            padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 34.h),
            child: FutureBuilder(
              future: getSelectedDayEvent(_selectedDay),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                /*if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('');
                }*/
                List<Map<String, dynamic>>? selectedDayEvent = snapshot.data;
                //선택한 날짜에 이벤트가 없을 시
                if (selectedDayEvent == null || selectedDayEvent.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 10.w),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      lang.noEvent,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5),
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: selectedDayEvent.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> event = selectedDayEvent[index];
                    DateTime date = event['date'];
                    String detail = event['detail'];
                    return IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditEventPage(
                              date: date,
                              detail: detail,
                            ),
                          ),
                        );
                        Future.microtask(() => setState(() {}));
                      },
                      icon: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 14.w),
                              child: Icon(
                                Icons.edit_calendar,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 34.sp,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detail,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 18.sp,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${date.hour}:${date.minute < 10 ? 0.toString() + date.minute.toString() : date.minute}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 10.h,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
