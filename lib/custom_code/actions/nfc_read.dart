// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

//import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';

Future<String> nfcRead() async {
  bool isAvailable = await NfcManager.instance.isAvailable();
  if (!isAvailable) {
    throw Exception("NFC no está disponible en este dispositivo.");
  }

  Map<String, dynamic>? tagData;

  await NfcManager.instance.startSession(
    onDiscovered: (NfcTag tag) async {
      tagData = tag.data;
      await NfcManager.instance.stopSession();
    },
    alertMessage: 'Escanea un tag NFC',
  );

  int maxWait = 10;
  while (tagData == null && maxWait > 0) {
    await Future.delayed(Duration(seconds: 1));
    maxWait--;
  }

  if (tagData == null) {
    throw Exception("No se detectó ningún tag NFC.");
  }

  return jsonEncode(tagData);
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
