import 'dart:io';
import 'package:diaryconnect/localization/localization_en.dart';
import 'package:diaryconnect/localization/localization_ko.dart';
import 'package:diaryconnect/localization/localization_jp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
ko_KR : Korea
en_US : US
ja_JP : Japan
*/

defaultLang() {
  String defaultLocale = Platform.localeName;
  var lang;
  switch (defaultLocale) {
    case 'ko_KR':
      lang = KRLang();
      break;
    case 'en_US':
      lang = USLang();
      break;
    case 'ja_JP':
      lang = JPLang();
      break;
    default:
      lang = USLang();
  }
  return lang;
}

class LangNotifier extends StateNotifier<dynamic> {
  LangNotifier() : super(defaultLang());
  setKo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('langauge', 'ko_KR');
    state = KRLang();
  }

  setEn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('langauge', 'en_US');
    state = USLang();
  }

  setJa() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('langauge', 'ja_JP');
    state = JPLang();
  }
}

String getLangagueCode(var lang) {
  String langauge;
  switch (lang) {
    case KRLang():
      langauge = 'ko_KR';
      break;
    case USLang():
      langauge = 'en_US';
      break;
    case JPLang():
      langauge = 'ja_JP';
      break;
    default:
      langauge = Platform.localeName;
      break;
  }
  return langauge;
}
