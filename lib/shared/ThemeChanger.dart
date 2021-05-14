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
  void getThemes(){
    var appTheme = getAppTheme();
    if (appTheme != null) {
      switch (appTheme) {
        case 'ThemeMode.dark':
          themeMode = ThemeMode.dark;
          break;
        case 'ThemeMode.light':
          themeMode = ThemeMode.light;
          break;
        case 'ThemeMode.system':
          themeMode = ThemeMode.system;
          break;
      }
    }
    //notifyListeners();
  }
}