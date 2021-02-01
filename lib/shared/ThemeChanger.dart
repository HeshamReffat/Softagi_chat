import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier{
  var themeMode = ThemeMode.system;
  get getTheme => themeMode;
  setTheme(theme){
    themeMode = theme;
    notifyListeners();
  }
}