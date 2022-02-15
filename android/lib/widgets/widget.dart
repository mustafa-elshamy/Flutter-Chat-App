import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

PreferredSizeWidget appBarMain(BuildContext context, String text) {
  return AppBar(
    title: Text(
      text,
      style: GoogleFonts.lobster(color: Colors.white, fontSize: 24),
    ),
  );
}

InputDecoration TextDecor(String text) {
  double rad = 20;
  return InputDecoration(
      hintText: text,
      hintStyle: TextStyle(color: Colors.white54),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rad),
          borderSide: BorderSide(color: Colors.white, width: 2)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rad),
          borderSide: BorderSide(color: Colors.white, width: 2)));
}

Widget Loading(String text) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: Colors.blue,
        ),
        SizedBox(height: 16),
        Text(text, style: TextStyle(color: Colors.white))
      ],
    ),
  );
}

void ShowToast(String message) {
  Fluttertoast.showToast(
      msg: message, backgroundColor: Colors.blue, textColor: Colors.white);
}
