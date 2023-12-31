import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import 'DiaryWrite_model.dart';
import 'package:diaryconnect/main.dart';
import 'package:diaryconnect/CustomIcon.dart';
import 'package:diaryconnect/imoticon.dart';
import 'package:diaryconnect/ViewPage/Connect/MyPage/MyPage_model.dart';
import 'package:diaryconnect/Admob_adversting.dart';

/*
 받아오는 data
 Map<String, dynamic> entryData = {
    'weather': resWeather, //IconData
    'mood': resMood, //IconData
    'date': resDate, //DateTime
    'detail': resDetail, //String
    'dayOfWeek': resDayOfWeek, //String
    'image': resImage, //String
  }; 
*/

/*
  반환하는 data
  Map<String, dynamic> entryData = {
    'weather': resWeather, //String
    'mood': resMood, //String
    'date': resDate, //String
    'detail': resDetail, //String
    'image': resImage, //String
  }
*/

class DiaryWritePage extends ConsumerStatefulWidget {
  final Map<String, dynamic> entryData;
  const DiaryWritePage({super.key, required this.entryData});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends ConsumerState<DiaryWritePage> {
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

  late IconData weather, mood;
  late DateTime date;
  late String detail, dayOfWeek, image;
  final TextEditingController editingController = TextEditingController();

  OverlayEntry? overlayEntry;
  final LayerLink weatherlayerLink = LayerLink();
  final LayerLink moodlayerLink = LayerLink();

  final double _dropdownWidth = 48.w;
  final double _dropdownHeight = 60.h;

  BottomDrawerController imoController = BottomDrawerController();
  Map<String, String> emoIndex = emoticon().emo1;

  ScrollController scrollController = ScrollController();

  //imoticon bottom Drawer
  Widget imoticonDrawer(BuildContext context) {
    List<Map<String, String>> emoList = [
      emoticon().emo1,
      emoticon().emo2,
      emoticon().emo3,
      emoticon().emo4,
      emoticon().emo5,
      emoticon().emo6,
      emoticon().emo7,
      emoticon().emo8,
      emoticon().emo9,
      emoticon().emo10,
      emoticon().emo11,
    ];
    return BottomDrawer(
      header: const SizedBox(height: 0),
      cornerRadius: 40,
      body: Column(
        children: [
          // emoticon array
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(40.sp),
              ),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            padding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 0),
            height: 120.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        emoIndex = emoList[index];
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 84.w,
                      child: Text(
                        '${emoList[index]['1']}',
                        style: TextStyle(
                          color: '${emoIndex['1']}' == '${emoList[index]['1']}'
                              ? Colors.black
                              : Theme.of(context).colorScheme.secondary,
                          fontSize: 14.sp,
                          fontWeight:
                              '${emoIndex['1']}' == '${emoList[index]['1']}'
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                          fontFamily: 'null',
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Container(
                    alignment: Alignment.center,
                    height: 10.h,
                    width: 1.w,
                    color: Colors.black45,
                  ),
                );
              },
              itemCount: emoList.length,
            ),
          ),
          //imoticon list
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: emoIndex.length,
              itemBuilder: (BuildContext contex, int index) {
                //imoticon button
                return TextButton(
                  onPressed: () async {
                    detail = '$detail ${emoIndex['${index + 1}']}';
                    editingController.text = detail;
                    //데이터 저장
                    await entrySave(
                        weather: weather,
                        mood: mood,
                        date: date,
                        detail: detail,
                        image: image);
                    setState(() {});
                    imoController.close();
                  },
                  child: Text(
                    '${emoIndex['${index + 1}']}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'null',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      headerHeight: 0.h,
      drawerHeight: 512.h,
      controller: imoController,
    );
  }

  void weatherDropdown() {
    if (overlayEntry == null) {
      overlayEntry = weatherOverlay();
      Overlay.of(context).insert(overlayEntry!);
    }
  }

  List<IconData> weatherList = [
    CustomIcon.sun,
    CustomIcon.cloud_sun_1,
    CustomIcon.clouds,
    CustomIcon.rain,
    CustomIcon.hail,
  ];

  //weather dropdown overlay
  OverlayEntry weatherOverlay() {
    return OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        width: _dropdownWidth,
        child: CompositedTransformFollower(
          link: weatherlayerLink,
          offset: Offset(0, _dropdownHeight),
          child: Material(
            color: Colors.white,
            child: Container(
              height: 210.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.sp),
              ),
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 6.h),
                itemCount: weatherList.length,
                itemBuilder: (context, index) {
                  return IconButton(
                      onPressed: () async {
                        weather = weatherList.elementAt(index);
                        //데이터 저장
                        await entrySave(
                            weather: weather,
                            mood: mood,
                            date: date,
                            detail: detail,
                            image: image);
                        setState(() {});
                        _removeOverlay();
                      },
                      icon: Icon(
                        weatherList.elementAt(index),
                        color: Theme.of(context).colorScheme.secondary,
                        size: 28.sp,
                      ));
                },
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.h),
                    child: Divider(
                      color: Colors.grey,
                      height: 4.h,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void moodDropdown() {
    if (overlayEntry == null) {
      overlayEntry = moodOverlay();
      Overlay.of(context).insert(overlayEntry!);
    }
  }

  List<IconData> moodList = [
    CustomIcon.emo_happy,
    CustomIcon.emo_sleep,
    CustomIcon.emo_unhappy,
    CustomIcon.emo_surprised,
    CustomIcon.emo_angry,
    CustomIcon.emo_cry,
  ];

  //mood dropdown overlay
  OverlayEntry moodOverlay() {
    return OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        width: _dropdownWidth,
        child: CompositedTransformFollower(
          link: moodlayerLink,
          offset: Offset(0, _dropdownHeight),
          child: Material(
            color: Colors.white,
            child: Container(
              height: 210.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.sp),
              ),
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 6.h),
                itemCount: moodList.length,
                itemBuilder: (context, index) {
                  return IconButton(
                      onPressed: () async {
                        mood = moodList.elementAt(index);
                        //데이터 저장
                        await entrySave(
                            weather: weather,
                            mood: mood,
                            date: date,
                            detail: detail,
                            image: image);
                        setState(() {});
                        _removeOverlay();
                      },
                      icon: Icon(
                        moodList.elementAt(index),
                        color: Theme.of(context).colorScheme.secondary,
                        size: 18.sp,
                      ));
                },
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.h),
                    child: Divider(
                      color: Colors.grey,
                      height: 4.h,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  double scrolloffset = 0.0;
  bool isDateShow = true;
  void onScroll() {
    if (scrolloffset == 0.0 && scrollController.offset != 0.0) {
      setState(() {
        isDateShow = false;
        scrolloffset = scrollController.offset;
      });
    } else if (scrolloffset >= 0.1 && scrollController.offset == 0.0) {
      setState(() {
        isDateShow = true;
        scrolloffset = scrollController.offset;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    weather = widget.entryData['weather'];
    mood = widget.entryData['mood'];
    date = widget.entryData['date'];
    detail = widget.entryData['detail'];
    dayOfWeek = widget.entryData['dayOfWeek'];
    image = widget.entryData['image'];
    editingController.text = detail;
    scrollController.addListener(() {
      onScroll();
    });
    interstitialAd();

    super.initState();
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    scrollController.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(themeLang);
    return GestureDetector(
      onTap: () {
        _removeOverlay();
        FocusScope.of(context).unfocus();
        imoController.close();
      },
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: true,
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
                                "${date.year}.${date.month}.${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}\n${lang.cautionDelete}",
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
                                  child: Text(lang.delete,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14.sp,
                                      )),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await deleteEntry(date);
                                    await Future.microtask(
                                        () => Navigator.pop(context));
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
                title: Text(
                  '${date.year}.${date.month}.${date.day} $dayOfWeek. ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: isDateShow ? 0 : 18.sp,
                  ),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    //scroll offset 0.0 date Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      width: double.infinity,
                      height: isDateShow ? 240.h : 0,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${date.year}.${date.month}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18.sp,
                              ),
                            ),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 78.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '$dayOfWeek. ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //weather, mood overlay button
                    Container(
                      alignment: Alignment.centerRight,
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(0, 24.h, 10.w, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CompositedTransformTarget(
                            link: weatherlayerLink,
                            child: IconButton(
                              onPressed: () {
                                _removeOverlay();
                                weatherDropdown();
                              },
                              icon: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    weather,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 28.sp,
                                  ),
                                  Icon(
                                    Icons.expand_more,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 16.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          CompositedTransformTarget(
                            link: moodlayerLink,
                            child: IconButton(
                              onPressed: () {
                                _removeOverlay();
                                moodDropdown();
                              },
                              icon: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    mood,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 18.sp,
                                  ),
                                  Icon(
                                    Icons.expand_more,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 16.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //detail text
                    Container(
                      padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 24.h),
                      child: TextField(
                        controller: editingController,
                        //이미지가 있으면 textfield minline 5 else 20
                        minLines: image == 'null' ? 20 : 5,
                        maxLines: null,
                        style: const TextStyle(
                          fontFamily: 'null',
                        ),
                        decoration: const InputDecoration(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onChanged: (value) async {
                          detail = value;
                          //데이터 저장
                          await entrySave(
                              weather: weather,
                              mood: mood,
                              date: date,
                              detail: detail,
                              image: image);
                        },
                      ),
                    ),
                    if (image != 'null')
                      Container(
                        padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Image.memory(base64Decode(image)),
                            IconButton(
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6.sp),
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
                                              child: Text(lang.delete,
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 14.sp,
                                                  )),
                                              onPressed: () async {
                                                image = 'null';
                                                await entrySave(
                                                    weather: weather,
                                                    mood: mood,
                                                    date: date,
                                                    detail: detail,
                                                    image: image);
                                                setState(() {});
                                                await Future.microtask(() =>
                                                    Navigator.pop(context));
                                              },
                                            ),
                                          ]);
                                    });
                              },
                              icon: Icon(
                                Icons.highlight_off,
                                size: 28.sp,
                                color: Colors.black45,
                              ),
                            )
                          ],
                        ),
                      )
                  ],
                ),
              ),
              bottomNavigationBar: BottomAppBar(
                height: 80.h,
                padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        _removeOverlay();
                        imoController.close();
                        final String pickedImage = await getImage();
                        if (pickedImage != 'null') {
                          image = pickedImage;
                          await entrySave(
                              weather: weather,
                              mood: mood,
                              date: date,
                              detail: detail,
                              image: image);
                          setState(() {});
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 32.sp,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _removeOverlay();
                        imoController.open();
                      },
                      icon: Icon(
                        Icons.cruelty_free,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 32.sp,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        _removeOverlay();
                        imoController.close();
                        //Alert 띄워서 친구 선택하고 share
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                              child: ListView.separated(
                                                shrinkWrap: true,
                                                physics:
                                                    const ClampingScrollPhysics(),
                                                itemCount: friendList.length,
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
                                                      firendInfo['HashCode'] ??
                                                          '#error';
                                                  String? friendUID =
                                                      firendInfo['uid'];
                                                  return IconButton(
                                                    onPressed: () async {
                                                      if (friendUID != null) {
                                                        //전면광고 게재
                                                        if (_interstitialAd !=
                                                            null) {
                                                          _interstitialAd
                                                              ?.show();
                                                        }
                                                        //다이어리 공유
                                                        await shareDiary(
                                                          weather: weather,
                                                          mood: mood,
                                                          date: date,
                                                          detail: detail,
                                                          image: image,
                                                          uid: friendUID,
                                                        );
                                                        Future.microtask(() {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Center(
                                                                child: Text(
                                                                  lang.shareComplete,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSecondary,
                                                                  ),
                                                                ),
                                                              ),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                              backgroundColor:
                                                                  Theme.of(
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
                                                      width: double.infinity,
                                                      height: 120.h,
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              10.w,
                                                              19.h,
                                                              10.w,
                                                              19.h),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    12.sp),
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .background,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                Colors.black26,
                                                            blurRadius: 12.sp,
                                                            offset: Offset(
                                                                8.w, 10.h),
                                                          ),
                                                        ],
                                                      ),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text.rich(
                                                        TextSpan(
                                                            text: friendName,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary,
                                                              fontSize: 18.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                            children: [
                                                              const TextSpan(
                                                                  text: ' '),
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
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                separatorBuilder:
                                                    (context, index) {
                                                  return SizedBox(height: 14.h);
                                                },
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
                  ],
                ),
              ),
            ),
          ),
          imoticonDrawer(context),
        ],
      ),
    );
  }
}
