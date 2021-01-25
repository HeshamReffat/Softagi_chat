import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier{
  var themeMode = ThemeMode.light;
  get getTheme => themeMode;
  setTheme(theme){
    themeMode = theme;
    notifyListeners();
  }
}