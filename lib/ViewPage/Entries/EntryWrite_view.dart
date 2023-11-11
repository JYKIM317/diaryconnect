import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bottom_drawer/bottom_drawer.dart';

import 'EntryWrite_model.dart';
import 'package:diaryconnect/main.dart';
import 'package:diaryconnect/CustomIcon.dart';
import 'package:diaryconnect/imoticon.dart';

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
//Image image = Image.memory(base64Decode(thisEntry['image']));

/// create a bottom drawer controller to control the drawer.

class EntryWrite extends ConsumerStatefulWidget {
  final Map<String, dynamic> entryData;
  const EntryWrite({super.key, required this.entryData});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EntryWriteState();
}

class _EntryWriteState extends ConsumerState<EntryWrite> {
  late IconData weather, mood;
  late DateTime date;
  late String detail, dayOfWeek, image;
  final TextEditingController editingController = TextEditingController();

  OverlayEntry? _overlayEntry;
  final LayerLink weatherlayerLink = LayerLink();
  final LayerLink moodlayerLink = LayerLink();

  final double _dropdownWidth = 48.w;
  final double _dropdownHeight = 60.h;

  BottomDrawerController imoController = BottomDrawerController();
  Map<String, String> emoIndex = emoticon().emo1;

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
                            color:
                                '${emoIndex['1']}' == '${emoList[index]['1']}'
                                    ? Colors.black
                                    : Theme.of(context).colorScheme.secondary,
                            fontSize: 14.sp,
                            fontWeight:
                                '${emoIndex['1']}' == '${emoList[index]['1']}'
                                    ? FontWeight.w700
                                    : FontWeight.w500),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  height: 10.h,
                  width: 1.w,
                  //color: Colors.black,
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

                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    final String weatherString = weatherToString(weather);
                    final String moodString = moodToString(mood);
                    final String dateString = date.toString();
                    final String entryName =
                        '${date.year}.${date.month}.${date.day}_${date.hour}:${date.minute}';
                    Map<String, dynamic> responseData = {
                      'weather': weatherString, //String
                      'mood': moodString, //String
                      'date': dateString, //String
                      'detail': detail, //String
                      'image': image, //String
                    };
                    final String entryData = jsonEncode(responseData);
                    await prefs.setString(entryName, entryData);

                    setState(() {});
                    imoController.close();
                  },
                  child: Text(
                    '${emoIndex['${index + 1}']}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 20.sp,
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
    if (_overlayEntry == null) {
      _overlayEntry = weatherOverlay();
      Overlay.of(context).insert(_overlayEntry!);
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

                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final String weatherString = weatherToString(weather);
                        final String moodString = moodToString(mood);
                        final String dateString = date.toString();
                        final String entryName =
                            '${date.year}.${date.month}.${date.day}_${date.hour}:${date.minute}';
                        Map<String, dynamic> responseData = {
                          'weather': weatherString, //String
                          'mood': moodString, //String
                          'date': dateString, //String
                          'detail': detail, //String
                          'image': image, //String
                        };
                        final String entryData = jsonEncode(responseData);
                        await prefs.setString(entryName, entryData);

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
    if (_overlayEntry == null) {
      _overlayEntry = moodOverlay();
      Overlay.of(context).insert(_overlayEntry!);
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

                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final String weatherString = weatherToString(weather);
                        final String moodString = moodToString(mood);
                        final String dateString = date.toString();
                        final String entryName =
                            '${date.year}.${date.month}.${date.day}_${date.hour}:${date.minute}';
                        Map<String, dynamic> responseData = {
                          'weather': weatherString, //String
                          'mood': moodString, //String
                          'date': dateString, //String
                          'detail': detail, //String
                          'image': image, //String
                        };
                        final String entryData = jsonEncode(responseData);
                        await prefs.setString(entryName, entryData);

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
    _overlayEntry?.remove();
    _overlayEntry = null;
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
    super.initState();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
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
                                    borderRadius: BorderRadius.circular(6.sp)),
                                content: Text(
                                  "${date.year}.${date.month}.${date.day} ${date.hour}:${date.minute < 10 ? 0.toString() + date.minute.toString() : date.minute}\n${lang.cautionDelete}",
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
                                      }),
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
                                      }),
                                ]);
                          });

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
            body: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    width: double.infinity,
                    height: 240.h,
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
                          '${dayOfWeek}. ${date.hour}:${date.minute}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(0, 10.h, 10.w, 0),
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
                  Container(
                    padding: EdgeInsets.fromLTRB(28.w, 24.h, 28.w, 24.h),
                    child: TextField(
                      controller: editingController,
                      minLines: 14,
                      maxLines: null,
                      decoration: const InputDecoration(
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: (value) async {
                        detail = value;

                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        final String weatherString = weatherToString(weather);
                        final String moodString = moodToString(mood);
                        final String dateString = date.toString();
                        final String entryName =
                            '${date.year}.${date.month}.${date.day}_${date.hour}:${date.minute}';
                        Map<String, dynamic> responseData = {
                          'weather': weatherString, //String
                          'mood': moodString, //String
                          'date': dateString, //String
                          'detail': detail, //String
                          'image': image, //String
                        };
                        final String entryData = jsonEncode(responseData);
                        await prefs.setString(entryName, entryData);
                      },
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              height: 90.h,
              padding: EdgeInsets.fromLTRB(30.w, 0, 30.w, 0),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.image,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 32.sp,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
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
                    onPressed: () {},
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
          imoticonDrawer(context),
        ],
      ),
    );
  }
}
