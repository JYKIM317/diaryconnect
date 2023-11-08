import 'dart:convert';
import 'package:diaryconnect/CustomIcon.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'Entries_model.dart';

class EntriesPage extends StatefulWidget {
  const EntriesPage({super.key});

  @override
  State<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: EdgeInsets.fromLTRB(10.w, 24.h, 10.w, 0),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: FutureBuilder(
          //Get Entries Data from Entries_model
          future: getEntries(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingIndicator(
                indicatorType: Indicator.pacman,
                colors: [Theme.of(context).colorScheme.onPrimary],
                strokeWidth: 2,
                backgroundColor: Theme.of(context).colorScheme.primary,
                pathBackgroundColor: Theme.of(context).colorScheme.primary,
              );
            }
            List<Map<String, dynamic>> myEntries = snapshot.data;
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

                return Container(
                  width: double.infinity,
                  height: 160.h,
                  padding: EdgeInsets.fromLTRB(10.w, 19.h, 10.w, 19.h),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.sp),
                      color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              //일
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              //요일
                              Text(
                                '$dayOfWeek',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        flex: 2,
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: [
                              //시간
                              Text(
                                '${date.hour}:${date.minute}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                              //내용
                              Text(
                                '$detail',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        flex: 5,
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.topCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  //날씨
                                  Icon(
                                    weather,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  //기분
                                  Icon(
                                    mood,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ],
                              ),
                              //사진 있을 시 파일
                              if (imageExist) Icon(CustomIcon.attach),
                            ],
                          ),
                        ),
                        flex: 3,
                      ),
                    ],
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
