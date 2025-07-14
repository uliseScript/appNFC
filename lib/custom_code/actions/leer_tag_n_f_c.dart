// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
// Begin custom widget code

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';

Future<String> leerTagNFC() async {
  final isAvailable = await NfcManager.instance.isAvailable();
  if (!isAvailable) {
    throw Exception('NFC no disponible');
  }

  final completer = Completer<String>();

  NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    try {
      final info = await _readTagData(tag);
      await NfcManager.instance.stopSession();
      HapticFeedback.vibrate();

      completer.complete(jsonEncode(info));
    } catch (e) {
      await NfcManager.instance.stopSession(errorMessage: 'Error: $e');
      completer.completeError('Error leyendo tag: $e');
    }
  });

  return completer.future;
}

Future<Map<String, dynamic>> _readTagData(NfcTag tag) async {
  final info = <String, dynamic>{};

  info['uid'] = _getTagUid(tag);
  info['type'] = tag.data['type']?.toString() ?? 'Desconocido';
  info['techList'] = tag.data['techList'] != null
      ? (tag.data['techList'] as List).map((e) => e.toString()).join(', ')
      : 'Desconocido';

  final nfcA = NfcA.from(tag);
  if (nfcA != null) {
    info['techDetails'] = {
      'Protocolo': 'NFC-A (ISO 14443-3A)',
      'ATQA': nfcA.atqa != null
          ? '0x${List<int>.from(nfcA.atqa).map((e) => e.toRadixString(16).padLeft(2, '0')).join()}'
          : 'Desconocido',
      'SAK': nfcA.sak != null
          ? '0x${nfcA.sak.toRadixString(16).padLeft(2, '0')}'
          : 'Desconocido',
    };

    if (nfcA.identifier.length == 7) {
      info['memoryInfo'] = {
        'Tipo': 'NTAG215 (estimado)',
        'Capacidad total': '540 bytes (estimado)',
        'Páginas': '135 (estimado)',
      };
    } else if (nfcA.identifier.length == 4) {
      info['memoryInfo'] = {
        'Tipo': 'MIFARE Classic (estimado)',
        'Capacidad total': '1K/4K (estimado)',
        'Páginas': 'Desconocido',
      };
    }
  }

  final ndef = Ndef.from(tag);
  if (ndef != null) {
    info['ndefInfo'] = {
      'Soporte NDEF': 'Sí',
      'Capacidad máxima': '${ndef.maxSize} bytes',
      'Escritura': ndef.isWritable ? 'Posible' : 'No posible',
    };

    try {
      final message = await ndef.read();
      if (message.records.isNotEmpty) {
        info['ndefRecords'] = message.records.map((record) {
          return {
            'Tipo': _getRecordType(record),
            'Contenido': _decodeRecordPayload(record),
            'Tamaño': '${record.payload.length} bytes',
          };
        }).toList();
      }
    } catch (e) {
      info['ndefError'] = e.toString();
    }
  }

  return info;
}

String _getTagUid(NfcTag tag) {
  final nfcA = NfcA.from(tag);
  if (nfcA != null && nfcA.identifier.isNotEmpty) {
    return nfcA.identifier
        .map((e) => e.toRadixString(16).padLeft(2, '0'))
        .join(':')
        .toUpperCase();
  }
  return 'No disponible';
}

String _getRecordType(NdefRecord record) {
  if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
    if (record.type.isNotEmpty && record.type[0] == 0x55) return 'URI';
    if (record.type.isNotEmpty && record.type[0] == 0x54) return 'Texto';
  }
  return record.type.isNotEmpty
      ? String.fromCharCodes(record.type)
      : 'Desconocido';
}

String _decodeRecordPayload(NdefRecord record) {
  try {
    if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
        record.type.isNotEmpty &&
        record.type[0] == 0x55) {
      final prefix = _getUriPrefix(record.payload[0]);
      return prefix + utf8.decode(record.payload.sublist(1));
    }

    if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
        record.type.isNotEmpty &&
        record.type[0] == 0x54) {
      if (record.payload.length > 1) {
        final languageCodeLength = record.payload[0] & 0x3F;
        if (record.payload.length > languageCodeLength + 1) {
          return utf8.decode(record.payload.sublist(languageCodeLength + 1));
        }
      }
    }

    return utf8.decode(record.payload);
  } catch (e) {
    return 'Datos binarios: ${record.payload.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':')}';
  }
}

String _getUriPrefix(int code) {
  const prefixes = [
    "",
    "http://www.",
    "https://www.",
    "http://",
    "https://",
    "tel:",
    "mailto:"
  ];
  return code < prefixes.length ? prefixes[code] : "";
}
