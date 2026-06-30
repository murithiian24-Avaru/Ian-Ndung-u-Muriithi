import 'package:flutter/material.dart';
import 'package:adlease/services/storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  static const _localeKey = 'adlease_locale';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> loadLocale() async {
    final code = await _storage.getString(_localeKey);
    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _storage.saveString(_localeKey, locale.languageCode);
    notifyListeners();
  }
}
