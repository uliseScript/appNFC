// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:nfc_manager/nfc_manager.dart';

Future<void> reiniciarLecturaNfc() async {
  try {
    // Detener cualquier sesión activa
    await NfcManager.instance.stopSession();

    // Reiniciar sesión vacía para desbloquear lectura
    await NfcManager.instance.startSession(
      //androidPlatformSound: false,
      onDiscovered: (_) async {
        await NfcManager.instance.stopSession();
      },
    );
  } catch (e) {
    // En caso de error al cerrar o iniciar
    await NfcManager.instance.stopSession(errorMessage: e.toString());
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
