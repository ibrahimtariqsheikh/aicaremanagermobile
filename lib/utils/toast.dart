import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

void showToast(String message, {bool isError = false}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: isError ? Colors.red : Colors.black87,
    textColor: Colors.white,
    timeInSecForIosWeb: 3,
  );
}
