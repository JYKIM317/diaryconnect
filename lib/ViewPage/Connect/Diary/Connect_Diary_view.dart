import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:diaryconnect/main.dart';
import 'Connect_Diary_model.dart';
import 'package:diaryconnect/ViewPage/Connect/Connect_model.dart';

class ViewConnectDiaryPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> entryData;
  final String uid;
  const ViewConnectDiaryPage(
      {super.key, required this.entryData, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ViewConnectDiaryPageState();
}

class _ViewConnectDiaryPageState extends ConsumerState<ViewConnectDiaryPage> {
  late IconData weather, mood;
  late DateTime date;
  late String detail, dayOfWeek, image, uid;
  final TextEditingController editingController = TextEditingController();

  String? userUID = FirebaseAuth.instance.currentUser!.uid;

  ScrollController scrollController = ScrollController();

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
    uid = widget.uid;
    editingController.text = detail;
    scrollController.addListener(() {
      onScroll();
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(themeLang);
    return Scaffold(
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
                          child: Text(
                            lang.cancel,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
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
                            //커넥트 다이어리 삭제 로직
                            String eventName =
                                "${date.year}.${date.month}.${date.day}_${date.hour}:${date.minute}_$uid";
                            await deleteConnectDiary(eventName);
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: FutureBuilder(
                        future: getFriendName(uid),
                        initialData: '',
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          String name = snapshot.data ?? '';
                          return Text(
                            name,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        weather,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 28.sp,
                      ),
                      SizedBox(width: 16.w),
                      Icon(
                        mood,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 18.sp,
                      ),
                      SizedBox(width: 16.w),
                    ],
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
                readOnly: true,
                minLines: image == 'null' ? 20 : 5,
                maxLines: null,
                style: const TextStyle(
                  fontFamily: 'null',
                ),
                decoration: const InputDecoration(
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            if (image != 'null')
              Container(
                padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
                child: Image.memory(base64Decode(image)),
              )
          ],
        ),
      ),
    );
  }
}
