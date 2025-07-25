// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

Future<bool> checkInternet() async {
  bool result = await InternetConnection().hasInternetAccess;
  return result;
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
