import 'package:diaryconnect/ViewPage/Connect/Calendar/Connect_Event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:diaryconnect/main.dart';

class ViewConnectEventPage extends ConsumerStatefulWidget {
  final DateTime date;
  final String detail;
  final String uid;

  const ViewConnectEventPage({
    super.key,
    required this.date,
    required this.detail,
    required this.uid,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewConnectEventPageState();
}

class _ViewConnectEventPageState extends ConsumerState<ViewConnectEventPage> {
  late DateTime selectedDate;
  late int hour, minute;
  late String detail, uid;

  String? userUID = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController eventDetailController = TextEditingController();

  int? changeHour, changeMinute;
  String? changeDetail;

  @override
  void initState() {
    selectedDate = widget.date;
    detail = widget.detail;
    hour = selectedDate.hour;
    minute = selectedDate.minute;
    uid = widget.uid;
    changeHour = hour;
    changeMinute = minute;
    changeDetail = detail;
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
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: IconButton(
              onPressed: () async {
                //삭제 경고문구
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.sp),
                      ),
                      content: Text(
                        lang.cautionDelete,
                        style: TextStyle(fontSize: 18.sp),
                      ),
                      actions: [
                        TextButton(
                          child: Text(lang.cancel,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              )),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(
                            lang.delete,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.sp,
                            ),
                          ),
                          onPressed: () async {
                            //커넥트 이벤트 삭제 로직
                            await deleteConnectEvent(
                              date: selectedDate,
                              detail: detail,
                              uid: uid,
                            );
                            Future.microtask(() {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
                // delete Entry.. EntryWrite_model logic
              },
              icon: Icon(
                Icons.delete,
                size: 28.sp,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          )
        ],
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
                            readOnly: true,
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
                                initialPage: changeHour!,
                                viewportFraction: 0.3),
                            pageSnapping: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                            physics: const NeverScrollableScrollPhysics(),
                            onPageChanged: (int index) => setState(() {
                              int numberIndex;
                              numberIndex = index ~/ 60;
                              changeMinute = index - numberIndex * 60;
                            }),
                            itemBuilder: (BuildContext context, int index) {
                              int numberIndex;
                              numberIndex = index ~/ 60;
                              return Transform.scale(
                                scale: index - numberIndex * 60 == changeMinute
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
    );
  }
}
