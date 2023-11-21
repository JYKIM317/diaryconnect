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
  String language;
  switch (lang) {
    case KRLang():
      language = 'ko_KR';
      break;
    case USLang():
      language = 'en_US';
      break;
    case JPLang():
      language = 'ja_JP';
      break;
    default:
      language = Platform.localeName;
      break;
  }
  return language;
}
