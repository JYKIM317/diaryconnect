import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'AddEvent_model.dart';

class AddEventPage extends ConsumerStatefulWidget {
  final DateTime date;
  const AddEventPage({super.key, required this.date});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddEventPageState();
}

class _AddEventPageState extends ConsumerState<AddEventPage> {
  DateTime? selectedDate;
  DateTime? spinnerDate;
  int hour = 8, minute = 0;
  @override
  void initState() {
    selectedDate = widget.date;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.w, 47.h, 10.w, 34.h),
          child: Column(
            children: [
              //detail
              Container(
                height: 100.h,
              ),
              Container(
                width: 355.w,
                height: 240.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
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
                          int saeat;
                          saeat = index ~/ 24;
                          hour = index - saeat * 24;
                        }),
                        itemBuilder: (BuildContext context, int index) {
                          int saeat;
                          saeat = index ~/ 24;
                          print('$saeat, $index, $hour');
                          return Transform.scale(
                            scale: index - saeat * 24 == hour ? 1.3 : 0.7,
                            child: SizedBox(
                                width: 120.w,
                                height: 200.h,
                                child: Center(
                                  child: Text(
                                    (index - saeat * 24)
                                        .toString()
                                        .padLeft(2, '0'),
                                    style: TextStyle(
                                      color: index - saeat * 24 == hour
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
                          int saeat;
                          saeat = index ~/ 60;
                          minute = index - saeat * 60;
                        }),
                        itemBuilder: (BuildContext context, int index) {
                          int saeat;
                          saeat = index ~/ 60;
                          print('$saeat, $index, $minute');
                          return Transform.scale(
                            scale: index - saeat * 60 == minute ? 1.3 : 0.7,
                            child: SizedBox(
                                width: 120.w,
                                height: 200.h,
                                child: Center(
                                  child: Text(
                                    (index - saeat * 60)
                                        .toString()
                                        .padLeft(2, '0'),
                                    style: TextStyle(
                                      color: index - saeat * 60 == minute
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
      bottomNavigationBar: BottomAppBar(
        height: 90.h,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () {},
                icon: Text(
                  '취소',
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
                onPressed: () {},
                icon: Text(
                  '저장',
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
    );
  }
}
