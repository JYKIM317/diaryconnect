import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diaryconnect/main.dart';
import 'EditEvent_model.dart';

class EditEventPage extends ConsumerStatefulWidget {
  final DateTime date;
  final String detail;
  const EditEventPage({super.key, required this.date, required this.detail});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditEventPageState();
}

class _EditEventPageState extends ConsumerState<EditEventPage> {
  late DateTime selectedDate;
  late int hour, minute;
  late String detail;
  TextEditingController eventDetailController = TextEditingController();
  bool editState = false;

  int? changeHour, changeMinute;
  String? changeDetail;

  @override
  void initState() {
    selectedDate = widget.date;
    detail = widget.detail;
    hour = selectedDate.hour;
    minute = selectedDate.minute;
    changeHour = hour;
    changeMinute = minute;
    eventDetailController.text = detail;
    super.initState();
  }

  @override
  void dispose() {
    eventDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(themeLang);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10.w, 47.h, 10.w, 34.h),
                child: Column(
                  children: [
                    //detail
                    Container(
                      width: double.infinity - 10.w,
                      height: 240.h,
                      alignment: Alignment.center,
                      padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 20.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.sp),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12.sp,
                            offset: Offset(8.w, 10.h),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${lang.title} :',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 24.sp,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: eventDetailController,
                              readOnly: !editState,
                              minLines: 3,
                              maxLines: null,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 24.sp,
                              ),
                              decoration: const InputDecoration(
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onChanged: (value) {
                                changeDetail = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity - 10.w,
                      height: 240.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.sp),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12.sp,
                            offset: Offset(8.w, 10.h),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //scheudle icon
                          Icon(
                            Icons.schedule,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 36.sp,
                          ),
                          //hour spinner
                          SizedBox(
                            width: 120.w,
                            height: 200.h,
                            child: PageView.builder(
                              scrollDirection: Axis.vertical,
                              controller: PageController(
                                  initialPage: changeHour!,
                                  viewportFraction: 0.3),
                              pageSnapping: true,
                              physics: editState
                                  ? const ClampingScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              onPageChanged: (int index) => setState(() {
                                int numberIndex;
                                numberIndex = index ~/ 24;
                                changeHour = index - numberIndex * 24;
                              }),
                              itemBuilder: (BuildContext context, int index) {
                                int numberIndex;
                                numberIndex = index ~/ 24;
                                return Transform.scale(
                                  scale: index - numberIndex * 24 == changeHour
                                      ? 1.4
                                      : 0.7,
                                  child: SizedBox(
                                      width: 120.w,
                                      height: 200.h,
                                      child: Center(
                                        child: Text(
                                          (index - numberIndex * 24)
                                              .toString()
                                              .padLeft(2, '0'),
                                          style: TextStyle(
                                            color:
                                                index - numberIndex * 24 ==
                                                        changeHour
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(0.6),
                                            fontSize: 28.sp,
                                          ),
                                        ),
                                      )),
                                );
                              },
                            ),
                          ),
                          //minute spinner
                          Text(
                            ':',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            width: 120.w,
                            height: 200.h,
                            child: PageView.builder(
                              scrollDirection: Axis.vertical,
                              controller: PageController(
                                  initialPage: changeMinute!,
                                  viewportFraction: 0.3),
                              pageSnapping: true,
                              physics: editState
                                  ? const ClampingScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              onPageChanged: (int index) => setState(() {
                                int numberIndex;
                                numberIndex = index ~/ 60;
                                changeMinute = index - numberIndex * 60;
                              }),
                              itemBuilder: (BuildContext context, int index) {
                                int numberIndex;
                                numberIndex = index ~/ 60;
                                return Transform.scale(
                                  scale:
                                      index - numberIndex * 60 == changeMinute
                                          ? 1.4
                                          : 0.7,
                                  child: SizedBox(
                                      width: 120.w,
                                      height: 200.h,
                                      child: Center(
                                        child: Text(
                                          (index - numberIndex * 60)
                                              .toString()
                                              .padLeft(2, '0'),
                                          style: TextStyle(
                                            color: index - numberIndex * 60 ==
                                                    changeMinute
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.6),
                                            fontSize: 28.sp,
                                          ),
                                        ),
                                      )),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: editState
            ? BottomAppBar(
                height: 80.h,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            editState = false;
                          });
                        },
                        icon: Text(
                          lang.cancel,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1.w,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () async {
                          // edit event save logic
                          int selectedYear = selectedDate.year;
                          int selectedMonth = selectedDate.month;
                          int selectedDay = selectedDate.day;
                          DateTime eventDate = DateTime(
                            selectedYear,
                            selectedMonth,
                            selectedDay,
                            hour,
                            minute,
                          );
                          DateTime changeEventDate = DateTime(
                            selectedYear,
                            selectedMonth,
                            selectedDay,
                            changeHour!,
                            changeMinute!,
                          );
                          await editEvent(
                            initialDate: eventDate,
                            initialDetail: detail,
                            changeDate: changeEventDate,
                            changeDetail: changeDetail!,
                          );
                          Future.microtask(() => Navigator.pop(context));
                        },
                        icon: Text(
                          lang.save,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : BottomAppBar(
                height: 80.h,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () async {
                          //delete event logic
                          int selectedYear = selectedDate.year;
                          int selectedMonth = selectedDate.month;
                          int selectedDay = selectedDate.day;
                          DateTime eventDate = DateTime(
                            selectedYear,
                            selectedMonth,
                            selectedDay,
                            hour,
                            minute,
                          );
                          await deleteEvent(date: eventDate, detail: detail);
                          Future.microtask(() => Navigator.pop(context));
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 32.sp,
                        ),
                      ),
                    ),
                    Container(
                      width: 1.w,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () async {
                          setState(() {
                            editState = true;
                          });
                        },
                        icon: Icon(
                          Icons.border_color_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 32.sp,
                        ),
                      ),
                    ),
                    Container(
                      width: 1.w,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () async {
                          // share event logic
                        },
                        icon: Icon(
                          Icons.share,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 32.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
