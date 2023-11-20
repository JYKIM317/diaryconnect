import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:diaryconnect/main.dart';
import 'ThemeColor.dart';
import 'ThemeLangauge.dart';
import 'package:diaryconnect/localization/localization_ko.dart';
import 'package:diaryconnect/localization/localization_en.dart';
import 'package:diaryconnect/localization/localization_jp.dart';

class ChangeThemePage extends ConsumerStatefulWidget {
  const ChangeThemePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeThemePageState();
}

class _ChangeThemePageState extends ConsumerState<ChangeThemePage> {
  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(themeLang);
    String languageCode = getLangagueCode(lang);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
      backgroundColor: Theme.of(context).colorScheme.background,
      content: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //앱 테마 색상 변경
            Text(
              lang.appTheme,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 21.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: IconButton(
                      onPressed: () {
                        ref.read(themeColor.notifier).red();
                      },
                      icon: Icon(
                        ref.watch(themeColor) == Colors.red
                            ? Icons.incomplete_circle
                            : Icons.circle,
                        color: Colors.red[200],
                        size: 42.sp,
                      )),
                ),
                Expanded(
                  child: IconButton(
                      onPressed: () {
                        ref.read(themeColor.notifier).deepPurple();
                      },
                      icon: Icon(
                        ref.watch(themeColor) == Colors.deepPurple
                            ? Icons.incomplete_circle
                            : Icons.circle,
                        color: Colors.deepPurple[200],
                        size: 42.sp,
                      )),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      ref.read(themeColor.notifier).indigo();
                    },
                    icon: Icon(
                      ref.watch(themeColor) == Colors.indigo
                          ? Icons.incomplete_circle
                          : Icons.circle,
                      color: Colors.indigo[200],
                      size: 42.sp,
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                      onPressed: () {
                        ref.read(themeColor.notifier).lightBlue();
                      },
                      icon: Icon(
                        ref.watch(themeColor) == Colors.lightBlue
                            ? Icons.incomplete_circle
                            : Icons.circle,
                        color: Colors.lightBlue[200],
                        size: 42.sp,
                      )),
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                ref.read(themeColor.notifier).green();
              },
              icon: Icon(
                ref.watch(themeColor) == Colors.green
                    ? Icons.incomplete_circle
                    : Icons.circle,
                color: Colors.green[200],
                size: 42.sp,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            //앱 테마 언어 변경
            Text(
              lang.langauge,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 21.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 10.h),
            IconButton(
              onPressed: () {
                if (languageCode != 'en_US') {
                  ref.read(themeLang.notifier).setEn();
                }
              },
              icon: Container(
                width: 240.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'English',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18.sp,
                      ),
                    ),
                    if (languageCode == 'en_US')
                      Icon(
                        Icons.done,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 18.sp,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            IconButton(
              onPressed: () {
                if (languageCode != 'ko_KR') {
                  ref.read(themeLang.notifier).setKo();
                }
              },
              icon: Container(
                width: 240.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '한국어',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18.sp,
                      ),
                    ),
                    if (languageCode == 'ko_KR')
                      Icon(
                        Icons.done,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 18.sp,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            IconButton(
              onPressed: () {
                if (languageCode != 'ja_JP') {
                  ref.read(themeLang.notifier).setJa();
                }
              },
              icon: Container(
                width: 240.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(6.sp),
                ),
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '日本語',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 18.sp,
                      ),
                    ),
                    if (languageCode == 'ja_JP')
                      Icon(
                        Icons.done,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 18.sp,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
