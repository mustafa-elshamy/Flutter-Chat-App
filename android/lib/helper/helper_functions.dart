import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

class HelperFunctions {
  static const String LOGGEDIN = "LOGGEDIN";
  static const String USERNAME = "USERNAME";
  static const String USEREMAIL = "USEREMAIL";
  static const String PASSWORD = "PASSWORD";

  static Future<bool> saveUserLoggedIn(bool loggedIn) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return await pref.setBool(LOGGEDIN, loggedIn);
  }

  static Future<bool> saveUserName(String userName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return await pref.setString(USERNAME, userName);
  }

  static Future<bool> saveUserEmail(String userEmail) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return await pref.setString(USEREMAIL, userEmail);
  }

  static Future<bool> saveUserPassword(String password) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return await pref.setString(PASSWORD, password);
  }

  static Future<bool> getUserLoggedIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(LOGGEDIN);
  }

  static Future<String> getUserName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(USERNAME);
  }

  static Future<String> getUserEMAIL() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(USEREMAIL);
  }

  static Future<String> getUserPassword() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(PASSWORD);
  }

  static Future<bool> getUserLoggedOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.remove(LOGGEDIN);
  }

  static Future<bool> removeUserName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.remove(USERNAME);
  }

  static Future<bool> removeUserEMAIL() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.remove(USEREMAIL);
  }

  static Future<bool> removeUserPassword() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.remove(PASSWORD);
  }


}
