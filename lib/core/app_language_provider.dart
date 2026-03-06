import 'package:flutter/material.dart';

class AppLanguageProvider extends ChangeNotifier {
  Locale _appLocale = const Locale('en');

  Locale get appLocale => _appLocale;

  void changeLanguage(Locale type) {
    if (_appLocale == type) {
      return;
    }
    _appLocale = type;
    notifyListeners();
  }
}
