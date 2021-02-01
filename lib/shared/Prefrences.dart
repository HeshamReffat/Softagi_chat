import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences preferences;

Future<void> initPref() async {
  return await SharedPreferences.getInstance().then((value) {
    preferences = value;
  });
}

Future<bool> savePhone(String phone) => preferences.setString('myPhone', phone);

String getPhone() => preferences.getString('myPhone');

Future<bool> saveSmSCode(String smsCode) =>
    preferences.setString('SmSCode', smsCode);

String getCode() => preferences.getString('SmSCode');

Future<bool> saveUserItemId(String userItemId) async{
  return await preferences.setString('UserItemId', userItemId);
}

String getUserItemId() => preferences.getString('UserItemId');

Future<bool> saveDeviceToken(String token) async{
  return await preferences.setString('Token', token);
}

String getDeviceToken() => preferences.getString('Token');

Future<bool> saveCreateProfile(String created) async{
  return await preferences.setString('Created', created);
}

String getCreateProfile() => preferences.getString('Created');
