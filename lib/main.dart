import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Theme/ThemeColor.dart';
import 'Theme/ThemeLangauge.dart';
import 'package:diaryconnect/ViewPage/Entries/Entries_view.dart';
import 'package:diaryconnect/ViewPage/Entries/EntryWrite_model.dart';
import 'package:diaryconnect/ViewPage/Entries/EntryWrite_view.dart';

String defaultLocale = Platform.localeName;
final themeColor = StateNotifierProvider<ThemeNotifier, Color>((ref) {
  return ThemeNotifier();
});
final themeLang = StateNotifierProvider<LangNotifier, dynamic>((ref) {
  return LangNotifier();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool? firstLogin = prefs.getBool('firstLogin');
  if (firstLogin == null) {
    int thisYear = DateTime.now().year;
    await prefs.setString('langauge', defaultLocale);
    await prefs.setInt('firstLoginYear', thisYear);
    await prefs.setBool('firstLogin', false);
  }
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
        EntriesPage(),
        EntriesPage(),
        EntriesPage(),
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
            icon: const Icon(Icons.offline_share),
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
                        builder: (context) => EntryWrite(entryData: entryData),
                      ),
                    ),
                  );
                  setState(() {});
                } else {
                  //동일한 시간대 작성한 다이어리가 있을경우 처리할 내용
                }
              },
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.border_color_rounded,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
