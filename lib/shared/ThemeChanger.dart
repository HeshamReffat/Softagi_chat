import 'package:flutter/material.dart';
import 'package:softagi_chat/shared/Prefrences.dart';

class ThemeChanger with ChangeNotifier{
  var themeMode = ThemeMode.system;
  get getTheme => themeMode;
  setTheme(theme){
    themeMode = theme;
    saveAppTheme(theme.toString());
    notifyListeners();
  }
}