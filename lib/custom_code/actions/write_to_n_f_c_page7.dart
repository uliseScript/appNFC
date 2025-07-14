// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

Future<void> writeToNFCPage7(String hexData) async {
  if (hexData.length != 8) throw Exception('hexData debe tener 8 caracteres');

  final isAvailable = await NfcManager.instance.isAvailable();
  if (!isAvailable) throw Exception('NFC no disponible');

  await NfcManager.instance.startSession(
    onDiscovered: (NfcTag tag) async {
      try {
        final nfcA = NfcA.from(tag);
        if (nfcA == null) throw Exception('Tag no compatible con NfcA');

        final bytes = List<int>.generate(
          4,
          (i) => int.parse(hexData.substring(i * 2, 1 * 2 + 2), radix: 16),
        );
        final command = Uint8List.fromList([0xA2, 0x07, ...bytes]);

        await nfcA.transceive(data: command);

        await NfcManager.instance.stopSession();
      } catch (e) {
        await NfcManager.instance.stopSession(errorMessage: 'Error: $e');
      }
    },
  );
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
