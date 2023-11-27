import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Connect_model.dart';
import 'package:diaryconnect/main.dart';
import 'package:diaryconnect/CustomIcon.dart';
import 'package:diaryconnect/Theme/ThemeLanguage.dart';
import 'MyPage/MyPage_view.dart';
import 'Calendar/Connect_Event_view.dart';
import 'Diary/Connect_Diary_view.dart';

class ConnectPage extends ConsumerStatefulWidget {
  const ConnectPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConnectPageState();
}

class _ConnectPageState extends ConsumerState<ConnectPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  String? userUID = FirebaseAuth.instance.currentUser!.uid;

  bool pageState = true;
  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(themeLang);
    String selectedLocale = getLangagueCode(lang);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPage(),
                  ),
                );
              },
              icon: Row(
                children: [
                  Text(
                    lang.myPage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.person,
                    size: 32.sp,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
              highlightColor: Theme.of(context).colorScheme.background,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 10.h),
            alignment: Alignment.bottomCenter,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (!pageState) {
                        setState(() {
                          pageState = true;
                        });
                      }
                    },
                    child: Container(
                      height: 68.h,
                      alignment: Alignment.center,
                      color: pageState
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        lang.calendar,
                        style: TextStyle(
                          color: pageState
                              ? Theme.of(context).colorScheme.onSecondary
                              : Theme.of(context).colorScheme.secondary,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (pageState) {
                        setState(() {
                          pageState = false;
                        });
                      }
                    },
                    child: Container(
                      height: 68.h,
                      alignment: Alignment.center,
                      color: !pageState
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        lang.entries,
                        style: TextStyle(
                          color: !pageState
                              ? Theme.of(context).colorScheme.onSecondary
                              : Theme.of(context).colorScheme.secondary,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          pageState
              //Calendar!!!
              ? Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          FutureBuilder(
                            future: getEventCount(),
                            initialData: const {
                              //event initial data no reason
                              'initialData': ['initialData'],
                            },
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              //load EventList
                              Map<String, dynamic>? eventDataLoad =
                                  snapshot.data;
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  headerMargin: EdgeInsets.only(bottom: 20.h),
                                  titleTextStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 18.sp,
                                  ),
                                ),
                                calendarStyle: CalendarStyle(
                                  selectedDecoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  todayDecoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  markerDecoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer),
                                  markersAlignment: Alignment.bottomCenter,
                                  markersMaxCount: 5,
                                ),
                                eventLoader: (day) =>
                                    eventDataLoad?[
                                        '${day.year}.${day.month}.${day.day}'] ??
                                    [],
                              );
                            },
                          ),
                          //divide calender and event
                          Container(
                            width: double.infinity,
                            height: 2.h,
                            margin: EdgeInsets.only(top: 10.h),
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          SizedBox(height: 30.h),
                          //show event
                          Container(
                            padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 34.h),
                            child: FutureBuilder(
                              future: getSelectedDayEvent(_selectedDay),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                List<Map<String, dynamic>>? selectedDayEvent =
                                    snapshot.data;
                                //선택한 날짜에 이벤트가 없을 시
                                if (selectedDayEvent == null ||
                                    selectedDayEvent.isEmpty) {
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Map<String, dynamic> event =
                                        selectedDayEvent[index];
                                    DateTime date = event['date'];
                                    String detail = event['detail'];
                                    String uid = event['uid'];
                                    return IconButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewConnectEventPage(
                                              date: date,
                                              detail: detail,
                                              uid: uid,
                                            ),
                                          ),
                                        );
                                        await Future.microtask(() {
                                          setState(() {});
                                        });
                                      },
                                      icon: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.fromLTRB(
                                            10.w, 10.h, 10.w, 10.h),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(right: 14.w),
                                              child: Icon(
                                                Icons.edit_calendar,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                size: 34.sp,
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          detail,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary,
                                                            fontSize: 18.sp,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      if (userUID == uid)
                                                        Text(
                                                          lang.me,
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .tertiaryContainer,
                                                            fontSize: 18.sp,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        )
                                                    ],
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
                    ),
                  ),
                )
              //Diary!!!
              : Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          FutureBuilder(
                            //Get Entries Data from Entries_model
                            future: getEntries(),
                            initialData: const [],
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('');
                              }
                              List<Map<String, dynamic>> myEntries =
                                  snapshot.data.toList();
                              if (myEntries.isEmpty) {
                                return Center(
                                  heightFactor: 6,
                                  child: Text(
                                    'NO Entries',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 56.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              }
                              //Entries Page show widget
                              return ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: myEntries.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Map<String, dynamic> thisEntry =
                                      myEntries[index];
                                  bool imageExist = false;

                                  //current index가 date flag인 경우 return
                                  if (thisEntry['monthFlag'] != null) {
                                    return SizedBox(
                                      height: 200.h,
                                      width: double.infinity,
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${thisEntry['yearFlag']}.',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                fontSize: 18.sp,
                                              ),
                                            ),
                                            Text(
                                              thisEntry['monthFlag'],
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                fontSize: 80.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  final IconData weather =
                                      weatherIconData(thisEntry['weather']);
                                  final IconData mood =
                                      moodIconData(thisEntry['mood']);
                                  final DateTime date =
                                      DateTime.parse(thisEntry['date']);
                                  final String detail = thisEntry['detail'];
                                  final String dayOfWeek =
                                      DateFormat('E', 'en_US').format(date);
                                  final String image = thisEntry['image'];
                                  final String uid = thisEntry['uid'];
                                  //Image image = Image.memory(base64Decode(thisEntry['image']));
                                  if (image != 'null') {
                                    imageExist = true;
                                  }
                                  Map<String, dynamic> entryData = {
                                    'weather': weather,
                                    'mood': mood,
                                    'date': date,
                                    'detail': detail,
                                    'dayOfWeek': dayOfWeek,
                                    'image': image,
                                  };
                                  return InkWell(
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewConnectDiaryPage(
                                            entryData: entryData,
                                            uid: uid,
                                          ),
                                        ),
                                      );
                                      await Future.microtask(() {
                                        setState(() {});
                                      });
                                    },
                                    child: Padding(
                                      //entry side padding
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: Container(
                                        width: double.infinity,
                                        height: 140.h,
                                        padding: EdgeInsets.fromLTRB(
                                            10.w, 19.h, 10.w, 19.h),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.sp),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 12.sp,
                                              offset: Offset(8.w, 10.h),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    //일
                                                    Text(
                                                      '${date.day}',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                        fontSize: 42.sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    //요일
                                                    Text(
                                                      '$dayOfWeek.',
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
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                alignment: Alignment.topLeft,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    //시간
                                                    Text.rich(
                                                      TextSpan(
                                                          text:
                                                              '${date.hour}:${date.minute.toString().padLeft(2, '0')}  ',
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary,
                                                            fontSize: 12.sp,
                                                          ),
                                                          children: [
                                                            if (userUID == uid)
                                                              TextSpan(
                                                                text: lang.me,
                                                                style:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .tertiaryContainer,
                                                                  fontSize:
                                                                      12.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              )
                                                          ]),
                                                    ),
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                        minHeight: 70.h,
                                                      ),
                                                      child: Text(
                                                        detail,
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 16.sp,
                                                          fontFamily: 'null',
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    )
                                                    //내용
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                alignment: Alignment.topCenter,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        //날씨
                                                        Icon(
                                                          weather,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          size: 28.sp,
                                                        ),
                                                        //기분
                                                        Icon(
                                                          mood,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          size: 18.sp,
                                                        ),
                                                      ],
                                                    ),
                                                    //사진 있을 시 파일
                                                    if (imageExist)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0,
                                                                0,
                                                                12.w,
                                                                6.h),
                                                        child: Icon(
                                                          CustomIcon.attach,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          size: 24.sp,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 20.h);
                                },
                              );
                            },
                          ),
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
