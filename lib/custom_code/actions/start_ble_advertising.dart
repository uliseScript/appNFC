// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// import 'package:flutter_flow/flutter_flow_util.dart';
// import 'package:flutter_flow/custom_functions.dart';
// import 'package:flutter_flow/custom_actions.dart';

import 'dart:typed_data';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

Future<String> startBleAdvertising(String valorAppState) async {
  try {
    final blePeripheral = FlutterBlePeripheral();

    final advertiseData = AdvertiseData(
      serviceUuid: 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7',
      localName: 'FlutterBLE',
      manufacturerId: 1234,
      manufacturerData: Uint8List.fromList(valorAppState.codeUnits),
    );

    await blePeripheral.start(advertiseData: advertiseData);
    return 'BLE Advertising iniciado con éxito';
  } catch (e) {
    return 'Error al iniciar BLE: \$e';
  }
}
