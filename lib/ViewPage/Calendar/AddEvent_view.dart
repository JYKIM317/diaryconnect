import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diaryconnect/main.dart';
import 'AddEvent_model.dart';

class AddEventPage extends ConsumerStatefulWidget {
  final DateTime date;
  const AddEventPage({super.key, required this.date});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddEventPageState();
}

class _AddEventPageState extends ConsumerState<AddEventPage> {
  DateTime? selectedDate;
  int hour = 12, minute = 30;
  String detail = '';
  TextEditingController eventDetailController = TextEditingController();
  @override
  void initState() {
    selectedDate = widget.date;
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
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          leading: Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 28.sp,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
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
                        color: Theme.of(context).colorScheme.background,
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
                                detail = value;
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
                        color: Theme.of(context).colorScheme.background,
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
                                  initialPage: hour, viewportFraction: 0.3),
                              pageSnapping: true,
                              onPageChanged: (int index) => setState(() {
                                int numberIndex;
                                numberIndex = index ~/ 24;
                                hour = index - numberIndex * 24;
                              }),
                              itemBuilder: (BuildContext context, int index) {
                                int numberIndex;
                                numberIndex = index ~/ 24;
                                return Transform.scale(
                                  scale: index - numberIndex * 24 == hour
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
                                                index - numberIndex * 24 == hour
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
                                  initialPage: minute, viewportFraction: 0.3),
                              pageSnapping: true,
                              onPageChanged: (int index) => setState(() {
                                int numberIndex;
                                numberIndex = index ~/ 60;
                                minute = index - numberIndex * 60;
                              }),
                              itemBuilder: (BuildContext context, int index) {
                                int numberIndex;
                                numberIndex = index ~/ 60;
                                return Transform.scale(
                                  scale: index - numberIndex * 60 == minute
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
                                                    minute
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
        bottomNavigationBar: BottomAppBar(
          height: 80.h,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
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
                    // save event logic
                    int selectedYear = selectedDate!.year;
                    int selectedMonth = selectedDate!.month;
                    int selectedDay = selectedDate!.day;
                    DateTime eventDate = DateTime(
                        selectedYear, selectedMonth, selectedDay, hour, minute);
                    await saveEvent(date: eventDate, detail: detail);
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
        ),
      ),
    );
  }
}
