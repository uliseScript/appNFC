// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:typed_data';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

Future<void> escribirYLeerNdef(String texto) async {
  final isAvailable = await NfcManager.instance.isAvailable();
  if (!isAvailable) {
    throw Exception('NFC no disponible en este dispositivo');
  }

  await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    try {
      final nfcA = NfcA.from(tag);
      if (nfcA == null) throw Exception('El tag no soporta NFC-A');

      int? numero;
      if (texto.trim().toLowerCase().startsWith('0x')) {
        numero = int.tryParse(texto.trim().substring(2), radix: 16);
      } else {
        numero = int.tryParse(texto.trim());
      }

      if (numero == null || numero < 100 || numero > 1000) {
        throw Exception('Ingresa un número entre 100 y 1000');
      }

      //  byte bajo y byte alto
      final page7Data = Uint8List(4);
      page7Data[0] = numero & 0xFF; // byte bajo
      page7Data[1] = (numero >> 8) & 0xFF; // byte alto

      // Escribir en la página 7
      final writePage7 = Uint8List.fromList([0xA2, 0x07, ...page7Data]);
      await nfcA.transceive(data: writePage7);

      // Leer la página 7
      final readPage7 = Uint8List.fromList([0x30, 0x07]);
      final response = await nfcA.transceive(data: readPage7);

      final byteLsb = response[0];
      final byteMsb = response[1];

      final numeroCompleto = byteLsb + (byteMsb << 8);

      final leidoDecimal = numeroCompleto.toString();
      final leidoHex =
          '0x${byteLsb.toRadixString(16).padLeft(2, '0').toUpperCase()}';

      FFAppState().update(() {
        FFAppState().contenidoEscritoNFC = leidoDecimal;
        FFAppState().contenidoHexNFC = leidoHex;
        FFAppState().reiniciarLecturaNFC = true;
      });

      await NfcManager.instance.stopSession();
    } catch (e) {
      await NfcManager.instance.stopSession(errorMessage: e.toString());
    }
  });

  return;
}

/*
Future<void> escribirYLeerNdef(String texto) async {
  final isAvailable = await NfcManager.instance.isAvailable();
  if (!isAvailable) {
    throw Exception('NFC no disponible en este dispositivo');
  }

  await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    try {
      final nfcA = NfcA.from(tag);
      if (nfcA == null) throw Exception('El tag no soporta NFC-A');

      int? numero;
      if (texto.trim().toLowerCase().startsWith('0x')) {
        numero = int.tryParse(texto.trim().substring(2), radix: 16);
      } else {
        numero = int.tryParse(texto.trim());
      }

      if (numero == null || numero < 0 || numero > 255) {
        throw Exception('Ingresa un número entre 0 y 255 (ej. 101 o 0x65)');
      }

      final page7Data = Uint8List(4);
      page7Data[0] = numero;

      final writePage7 = Uint8List.fromList([0xA2, 0x07, ...page7Data]);
      await nfcA.transceive(data: writePage7);

      final readPage7 = Uint8List.fromList([0x30, 0x07]);
      final response = await nfcA.transceive(data: readPage7);

      final byteLeido = response[0];
      final leidoDecimal = byteLeido.toString();
      final leidoHex =
          '0x${byteLeido.toRadixString(16).padLeft(2, '0').toUpperCase()}';

      FFAppState().update(() {
        FFAppState().contenidoEscritoNFC = leidoDecimal;
        FFAppState().contenidoHexNFC = leidoHex;
        FFAppState().reiniciarLecturaNFC = true; // 👈 Esta es la señal
      });

      await NfcManager.instance.stopSession();
    } catch (e) {
      await NfcManager.instance.stopSession(errorMessage: e.toString());
    }
  });

  return;
}*/

// Future<void> escribirYLeerNdef(String texto) async {
//   final isAvailable = await NfcManager.instance.isAvailable();
//   if (!isAvailable) {
//     throw Exception('NFC no disponible en este dispositivo');
//   }

//   NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
//     try {
//       final nfcA = NfcA.from(tag);
//       if (nfcA == null) throw Exception('El tag no soporta comunicación NFC-A');

//       // 🔍 Interpretar entrada como decimal o hexadecimal
//       int? numero;
//       if (texto.trim().toLowerCase().startsWith('0x')) {
//         numero = int.tryParse(texto.trim().substring(2), radix: 16);
//       } else {
//         numero = int.tryParse(texto.trim());
//       }

//       if (numero == null || numero < 0 || numero > 255) {
//         throw Exception('Ingresa un número entre 0 y 255 (ej. 101 o 0x65)');
//       }

//       // 📝 Escribir ese número en la página 7
//       final page7Data = Uint8List(4);
//       page7Data[0] = numero;

//       final writePage7 = Uint8List.fromList([0xA2, 0x07, ...page7Data]);
//       await nfcA.transceive(data: writePage7);

//       // 📖 Leer la página 7
//       final readPage7 = Uint8List.fromList([0x30, 0x07]);
//       final response = await nfcA.transceive(data: readPage7);

//       final byteLeido = response[0];
//       final leidoDecimal = byteLeido.toString();
//       final leidoHex =
//           '0x${byteLeido.toRadixString(16).padLeft(2, '0').toUpperCase()}';

//       // 🔄 Guardar en AppState
//       FFAppState().update(() {
//         FFAppState().contenidoEscritoNFC = leidoDecimal;
//         FFAppState().contenidoHexNFC = leidoHex;
//       });

//       FFAppState().notifyListeners();
//       NfcManager.instance.stopSession();
//     } catch (e) {
//       NfcManager.instance.stopSession(errorMessage: e.toString());
//     }
//   });
// }

// Future<void> escribirYLeerNdef(String texto) async {
//   final isAvailable = await NfcManager.instance.isAvailable();
//   if (!isAvailable) {
//     throw Exception('NFC no disponible en este dispositivo');
//   }

//   NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
//     try {
//       final nfcA = NfcA.from(tag);
//       if (nfcA == null) throw Exception('El tag no soporta comunicación NFC-A');

//       // Convertir texto a bytes y rellenar a 4 bytes
//       final textBytes = Uint8List.fromList(texto.codeUnits);
//       final page7Data = Uint8List(4);
//       for (int i = 0; i < 4 && i < textBytes.length; i++) {
//         page7Data[i] = textBytes[i];
//       }

//       final writePage7 = Uint8List.fromList([0xA2, 0x07, ...page7Data]);
//       await nfcA.transceive(data: writePage7);

//       // Leer la página 7 para confirmar
//       final readPage7 = Uint8List.fromList([0x30, 0x07]);
//       final response = await nfcA.transceive(data: readPage7);

//       final leido = String.fromCharCodes(response.sublist(0, 4));

//       FFAppState().update(() {
//         FFAppState().contenidoEscritoNFC = leido;
//       });

//       FFAppState().notifyListeners();
//       NfcManager.instance.stopSession();
//     } catch (e) {
//       NfcManager.instance.stopSession(errorMessage: e.toString());
//     }
//   });
// }

// // Automatic FlutterFlow imports
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/custom_code/actions/index.dart'; // Imports other custom actions
// import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// import 'package:flutter/material.dart';
// // Begin custom action code
// // DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// import 'dart:convert';

// import 'package:nfc_manager/nfc_manager.dart';
// import 'package:nfc_manager/platform_tags.dart';

// Future<void> escribirYLeerNdef(String texto) async {
//   final isAvailable = await NfcManager.instance.isAvailable();
//   if (!isAvailable) {
//     throw Exception('NFC no disponible en este dispositivo');
//   }

//   NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
//     try {
//       final ndef = Ndef.from(tag);
//       if (ndef == null) throw Exception('El tag no soporta NDEF');
//       if (!ndef.isWritable) throw Exception('El tag no es escribible');

//       final mensaje = NdefMessage([NdefRecord.createText(texto)]);
//       await ndef.write(mensaje);

//       // Leer inmediatamente después de escribir
//       final message = await ndef.read();

//       String contenido = '';
//       if (message.records.isNotEmpty) {
//         final record = message.records.first;
//         if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
//             record.type.isNotEmpty &&
//             record.type[0] == 0x54) {
//           final languageCodeLength = record.payload[0] & 0x3F;
//           contenido =
//               utf8.decode(record.payload.sublist(languageCodeLength + 1));
//         } else {
//           contenido = utf8.decode(record.payload);
//         }
//       }

//       FFAppState().update(() {
//         FFAppState().contenidoEscritoNFC = contenido;
//       });

//       FFAppState().notifyListeners();

//       NfcManager.instance.stopSession();
//     } catch (e) {
//       NfcManager.instance.stopSession(errorMessage: e.toString());
//     }
//   });
// }
