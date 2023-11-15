import 'package:diaryconnect/CustomIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'Entries_model.dart';
import 'package:diaryconnect/ViewPage/Entries/EntryWrite_view.dart';

class EntriesPage extends ConsumerStatefulWidget {
  const EntriesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EntriesPageState();
}

class _EntriesPageState extends ConsumerState<EntriesPage> {
  ScrollController scrollController = ScrollController();
  late double lastScrollOffset;
  onScroll() {}

  @override
  void initState() {
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: EdgeInsets.only(top: 47.h),
      child: SingleChildScrollView(
        controller: scrollController,
        child: FutureBuilder(
          //Get Entries Data from Entries_model
          future: getEntries(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('');
            }
            List<Map<String, dynamic>> myEntries = snapshot.data.toList();
            if (myEntries.isEmpty) {
              return Center(
                heightFactor: 6,
                child: Text(
                  'NO Entries',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
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
                Map<String, dynamic> thisEntry = myEntries[index];
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
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 18.sp,
                            ),
                          ),
                          Text(
                            thisEntry['monthFlag'],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 80.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final IconData weather = weatherIconData(thisEntry['weather']);
                final IconData mood = moodIconData(thisEntry['mood']);
                final DateTime date = DateTime.parse(thisEntry['date']);
                final String detail = thisEntry['detail'];
                final String dayOfWeek = DateFormat('E', 'en_US').format(date);
                final String image = thisEntry['image'];
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
                    lastScrollOffset = scrollController.offset - 1;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntryWrite(entryData: entryData),
                      ),
                    );
                    setState(() {});
                    scrollController.animateTo(
                      lastScrollOffset,
                      duration: const Duration(milliseconds: 10),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Padding(
                    //entry side padding
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Container(
                      width: double.infinity,
                      height: 140.h,
                      padding: EdgeInsets.fromLTRB(10.w, 19.h, 10.w, 19.h),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.sp),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12.sp,
                                offset: Offset(8.w, 10.h)),
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //일
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 42.sp,
                                      fontWeight: FontWeight.w700,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //시간
                                  Text(
                                    '${date.hour}:${date.minute < 10 ? 0.toString() + date.minute.toString() : date.minute}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: 70.h,
                                    ),
                                    child: Text(
                                      detail,
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 16.sp,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      //날씨
                                      Icon(
                                        weather,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 28.sp,
                                      ),
                                      //기분
                                      Icon(
                                        mood,
                                        color: Theme.of(context)
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
                                          EdgeInsets.fromLTRB(0, 0, 12.w, 6.h),
                                      child: Icon(
                                        CustomIcon.attach,
                                        color: Theme.of(context)
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
                return SizedBox(height: 18.h);
              },
            );
          },
        ),
      ),
    );
  }
}
