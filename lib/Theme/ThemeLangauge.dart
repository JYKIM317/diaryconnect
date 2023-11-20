import 'dart:io';
import 'package:diaryconnect/localization/localization_en.dart';
import 'package:diaryconnect/localization/localization_ko.dart';
import 'package:diaryconnect/localization/localization_jp.dart';

/*
ko_KR : Korea
en_US : US
ja_JP : Japan
*/

initializedLang(String locale) {
  var lang;
  switch (locale) {
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
