import 'dart:io';
import 'package:diaryconnect/CustomIcon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'Theme/ThemeColor.dart';
import 'Theme/ThemeLanguage.dart';
import 'package:diaryconnect/ViewPage/Diary/Diarys_view.dart';
import 'package:diaryconnect/ViewPage/Diary/DiaryWrite_model.dart';
import 'package:diaryconnect/ViewPage/Diary/DiaryWrite_view.dart';
import 'package:diaryconnect/ViewPage/Calendar/Calendar_view.dart';
import 'package:diaryconnect/ViewPage/Connect/Connect_view.dart';

import 'package:diaryconnect/localization/localization_en.dart';
import 'package:diaryconnect/localization/localization_ko.dart';
import 'package:diaryconnect/localization/localization_jp.dart';

String defaultLocale = Platform.localeName;
late String language, appTheme;

//앱 테마 컬러 관련 Provider
final themeColor = StateNotifierProvider<ThemeNotifier, Color>((ref) {
  return ThemeNotifier();
});

//앱 테마 컬러 관련 StateNotifier
class ThemeNotifier extends StateNotifier<Color> {
  ThemeNotifier() : super(initializedColor(appTheme));
  deepPurple() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', 'deepPurple');
    state = Colors.deepPurple;
  }

  indigo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', 'indigo');
    state = Colors.indigo;
  }

  red() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', 'red');
    state = Colors.red;
  }

  lightBlue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', 'lightBlue');
    state = Colors.lightBlue;
  }

  green() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', 'green');
    state = Colors.green;
  }
}

//앱 언어 관련 Provider
final themeLang = StateNotifierProvider<LangNotifier, dynamic>((ref) {
  return LangNotifier();
});

//앱 언어 관련 StateNotifier
class LangNotifier extends StateNotifier<dynamic> {
  LangNotifier() : super(initializedLang(language));

  setKo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', 'ko_KR');
    state = KRLang();
  }

  setEn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', 'en_US');
    state = USLang();
  }

  setJa() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', 'ja_JP');
    state = JPLang();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //Firebase auth login
  await FirebaseAuth.instance.signInAnonymously();
  User? user = FirebaseAuth.instance.currentUser;
  String? userUID = user!.uid;
  print('auth uid is $userUID');
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool? firstLogin = prefs.getBool('firstLogin');

  //Calendar locale init initialize
  await initializeDateFormatting();
  if (firstLogin == null) {
    int thisYear = DateTime.now().year;
    await prefs.setString('language', defaultLocale);
    await prefs.setString('themeColor', 'indigo');
    await prefs.setInt('firstLoginYear', thisYear);
    await prefs.setBool('firstLogin', false);
  }
  language = prefs.getString('language') ?? defaultLocale;
  appTheme = prefs.getString('themeColor') ?? 'indigo';

  runApp(
    const ProviderScope(
      child: ScreenUtilInit(
        designSize: Size(375, 812),
        child: MyApp(),
      ),
    ),
  );
}

//for appThemedata state
class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ref.watch(themeColor)),
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        useMaterial3: true,
        fontFamily: 'NotoSans',
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  //scaffold body page number
  int selectedIndex = 1;
  //page change
  void onBottomTapped(int index) {
    if (index != selectedIndex) {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(themeLang);
    return Scaffold(
      body: [
        DiarysPage(),
        CalendarPage(),
        ConnectPage(),
      ][selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.edit_note),
            label: lang.entries,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.date_range),
            label: lang.calendar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CustomIcon.people_arrows),
            label: lang.shared,
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onBottomTapped,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        fixedColor: Theme.of(context).colorScheme.secondary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      //only Entries and Calendar (without Shared)
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final DateTime today = DateTime.now();
                final String thisTime =
                    '${today.year}.${today.month}.${today.day}_${today.hour}:${today.minute}';
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final String? thisTimeData = prefs.getString(thisTime);
                if (thisTimeData == null) {
                  Map<String, dynamic> entryData = await makeEntryCase();
                  await Future.microtask(
                    () async => await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DiaryWritePage(entryData: entryData),
                      ),
                    ),
                  );
                  setState(() {});
                }
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.border_color_rounded,
                color: Theme.of(context).colorScheme.onSecondary,
                size: 24.sp,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
