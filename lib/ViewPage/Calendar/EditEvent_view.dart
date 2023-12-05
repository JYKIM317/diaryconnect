import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import 'package:diaryconnect/main.dart';
import 'EditEvent_model.dart';
import 'package:diaryconnect/ViewPage/Connect/MyPage/MyPage_model.dart';
import 'package:diaryconnect/Admob_adversting.dart';

class EditEventPage extends ConsumerStatefulWidget {
  final DateTime date;
  final String detail;
  const EditEventPage({super.key, required this.date, required this.detail});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditEventPageState();
}

class _EditEventPageState extends ConsumerState<EditEventPage> {
  InterstitialAd? _interstitialAd;
  void interstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? InterstitialAdId().android
          : InterstitialAdId().ios,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('$error');
        },
      ),
    );
  }

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
    changeDetail = detail;
    eventDetailController.text = detail;
    interstitialAd();
    super.initState();
  }

  @override
  void dispose() {
    eventDetailController.dispose();
    _interstitialAd?.dispose();
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
                          int selectedYear = selectedDate.year;
                          int selectedMonth = selectedDate.month;
                          int selectedDay = selectedDate.day;
                          DateTime eventDate = DateTime(
                            selectedYear,
                            selectedMonth,
                            selectedDay,
                            changeHour!,
                            changeMinute!,
                          );
                          // share event logic
                          await getFriendList().then(
                            (value) {
                              List<dynamic> friendList = value;
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    content: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10.w, 10.h, 0, 10.h),
                                          child: Text(
                                            lang.friend,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        friendList.isEmpty
                                            ? SizedBox(
                                                height: 200.h,
                                                width: double.infinity,
                                                child: Center(
                                                  child: Text(
                                                    lang.empty,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                          .withOpacity(0.6),
                                                      fontSize: 56.sp,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox(
                                                height: 400.h,
                                                width: 300.w,
                                                child: Expanded(
                                                  child: ListView.separated(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const ClampingScrollPhysics(),
                                                    itemCount:
                                                        friendList.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      Map<String, dynamic>
                                                          firendInfo =
                                                          friendList[index];
                                                      String friendName =
                                                          firendInfo['Name'] ??
                                                              'anonymous';
                                                      String friendHashCode =
                                                          firendInfo[
                                                                  'HashCode'] ??
                                                              '#error';
                                                      String? friendUID =
                                                          firendInfo['uid'];
                                                      return IconButton(
                                                        onPressed: () async {
                                                          if (friendUID !=
                                                              null) {
                                                            //전면광고 게재
                                                            if (_interstitialAd !=
                                                                null) {
                                                              _interstitialAd
                                                                  ?.show();
                                                            }
                                                            //이벤트 공유
                                                            await shareEvent(
                                                              date: eventDate,
                                                              detail:
                                                                  changeDetail!,
                                                              uid: friendUID,
                                                            );
                                                            Future.microtask(
                                                                () {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content:
                                                                      Center(
                                                                    child: Text(
                                                                      lang.shareComplete,
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .onSecondary,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  duration:
                                                                      const Duration(
                                                                          seconds:
                                                                              2),
                                                                  backgroundColor: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary,
                                                                ),
                                                              );
                                                              Navigator.pop(
                                                                  context);
                                                            });
                                                          }
                                                        },
                                                        icon: Container(
                                                          width:
                                                              double.infinity,
                                                          height: 120.h,
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  10.w,
                                                                  19.h,
                                                                  10.w,
                                                                  19.h),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.sp),
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .background,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black26,
                                                                blurRadius:
                                                                    12.sp,
                                                                offset: Offset(
                                                                    8.w, 10.h),
                                                              ),
                                                            ],
                                                          ),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text.rich(
                                                            TextSpan(
                                                                text:
                                                                    friendName,
                                                                style:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary,
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                                children: [
                                                                  const TextSpan(
                                                                      text:
                                                                          ' '),
                                                                  TextSpan(
                                                                    text:
                                                                        friendHashCode,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .secondary,
                                                                      fontSize:
                                                                          18.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                  )
                                                                ]),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (context, index) {
                                                      return SizedBox(
                                                          height: 20.h);
                                                    },
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
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
