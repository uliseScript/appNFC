// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'index.dart'; // Imports other custom widgets

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';

class NfcReaderWidget extends StatefulWidget {
  const NfcReaderWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<NfcReaderWidget> createState() => _NfcReaderWidgetState();
}

class _NfcReaderWidgetState extends State<NfcReaderWidget> {
  String tagInfo = 'Acerca un tag NFC para comenzar la lectura';
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    FFAppState().addListener(_checkRestartNfc);
    _startNfcListener();
  }

  @override
  void dispose() {
    FFAppState().removeListener(_checkRestartNfc);
    NfcManager.instance.stopSession();
    super.dispose();
  }

  void _checkRestartNfc() {
    if (FFAppState().reiniciarLecturaNFC) {
      FFAppState().update(() => FFAppState().reiniciarLecturaNFC = false);
      _restartNfcListener();
    }
  }

  void _restartNfcListener() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 300));
    _startNfcListener();
  }

  void _startNfcListener() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        hasError = true;
        tagInfo = _formatError('NFC no disponible', [
          '1. Verifica que tu dispositivo soporta NFC',
          '2. Activa el NFC en ajustes del sistema',
          '3. Otorga los permisos necesarios a la app'
        ]);
      });
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        final uid = _getTagUid(tag);
        final info = await _readTagData(tag);
        HapticFeedback.vibrate();

        setState(() {
          tagInfo = _formatTagInfo(info);
          hasError = false;
          FFAppState().update(() {
            FFAppState().contenidoEscritoNFC = info['contenidoAscii'] ?? '';
            FFAppState().contenidoHexNFC = info['contenidoHex'] ?? '';
            FFAppState().contenidoDecimal = info['contenidoDecimal'] ?? '';
            FFAppState().uidNFC = uid;
            FFAppState().tipoNfc = info['memoryInfo']?['Tipo'] ?? '';
            FFAppState().protocoloNFC = info['techDetails']?['Protocolo'] ?? '';
            FFAppState().capacidadNFC =
                info['memoryInfo']?['Capacidad total'] ?? '';
            FFAppState().pagesNFC = info['memoryInfo']?['Páginas'] ?? '';
            FFAppState().bytePageNFC =
                info['memoryInfo']?['Bytes por página'] ?? '';
            FFAppState().suppNdefNFC =
                info['ndefInfo']?['Capacidad máxima'] ?? '';
            FFAppState().writingNdefNFC = info['ndefInfo']?['Escritura'] ?? '';
            if (info['ndefRecords'] != null && info['ndefRecords'].isNotEmpty) {
              final lastRecord = info['ndefRecords'].last;
              FFAppState().recordTipoNFC = lastRecord['Tipo'] ?? '';
              FFAppState().recordTamano = lastRecord['Tamaño'] ?? '';
              FFAppState().recordContenidoNFC = lastRecord['Contenido'] ?? '';
            } else {
              FFAppState().recordTipoNFC = '';
              FFAppState().recordTamano = '';
              FFAppState().recordContenidoNFC = '';
            }
          });
        });
      } catch (e) {
        setState(() {
          tagInfo = _formatError('Error leyendo el tag: $e');
          hasError = true;
        });
      }
    });
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

      try {
        final response =
            await nfcA.transceive(data: Uint8List.fromList([0x30, 0x07]));

        final byteLeido = response[0]; // ✅ Solo el primer byte
        final hex =
            '0x${byteLeido.toRadixString(16).padLeft(2, '0').toUpperCase()}';
        final decimal = byteLeido.toString();
        final ascii = utf8.decode([byteLeido], allowMalformed: true).trim();

        info['contenidoAscii'] = ascii;
        info['contenidoHex'] = hex;
        info['contenidoDecimal'] = decimal;

        info['ndefRecords'] = [
          {
            'Tipo': 'Manual',
            'Contenido': ascii,
            'Tamaño': '${ascii.length} bytes',
          }
        ];
      } catch (e) {
        info['ndefError'] = 'Error leyendo página 7: $e';
      }

      info['memoryInfo'] = {
        'Tipo': 'NTAG215',
        'Capacidad total': '540 bytes',
        'Páginas': '135',
        'Bytes por página': '4',
        'Área de usuario': '504 bytes',
        'Bloqueo': 'Configurable'
      };
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

  String _formatError(String message, [List<String>? details]) {
    final buffer = StringBuffer();
    buffer.writeln('⚠️ $message');
    buffer.writeln('━━━━━━━━━━━━━━━━━━');
    details?.forEach((detail) => buffer.writeln('\n• $detail'));
    return buffer.toString();
  }

  String _formatTagInfo(Map<String, dynamic> info) {
    final buffer = StringBuffer();
    buffer.writeln('🏷️ TAG NFC DETECTADO');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━\n');
    buffer.writeln('🆔 UID: ${info['uid']}');
    buffer.writeln('📌 Tipo: ${info['type']}');
    buffer.writeln('📡 Tecnologías: ${info['techList']}\n');

    if (info['techDetails'] != null) {
      buffer.writeln('🔧 DETALLES TÉCNICOS');
      buffer.writeln('────────────────────');
      (info['techDetails'] as Map<String, dynamic>)
          .forEach((k, v) => buffer.writeln('$k: $v'));
      buffer.writeln();
    }
    if (info['memoryInfo'] != null) {
      buffer.writeln('💾 INFORMACIÓN DE MEMORIA');
      buffer.writeln('────────────────────────');
      (info['memoryInfo'] as Map<String, dynamic>)
          .forEach((k, v) => buffer.writeln('$k: $v'));
      buffer.writeln();
    }

    if (info['ndefRecords'] != null) {
      buffer.writeln('📌 CONTENIDO MANUAL LEÍDO DE PÁGINA 7');
      buffer.writeln('─────────────────────────────');
      for (final record in info['ndefRecords']) {
        buffer.writeln('\n• Tipo: ${record['Tipo']}');
        buffer.writeln('• Tamaño: ${record['Tamaño']}');
        buffer.writeln('• Contenido: ${record['Contenido']}');
      }
    } else if (info['ndefError'] != null) {
      buffer.writeln('\n❌ Error leyendo contenido: ${info['ndefError']}');
    } else {
      buffer.writeln('\nℹ️ No se encontró contenido en página 7');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 500,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Text(
          tagInfo,
          style: TextStyle(
            fontSize: 14,
            color: hasError ? Colors.red[700] : Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

/*// Automatic FlutterFlow imports

import 'index.dart'; // Imports other custom widgets

import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';

class NfcReaderWidget extends StatefulWidget {
  const NfcReaderWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<NfcReaderWidget> createState() => _NfcReaderWidgetState();
}

class _NfcReaderWidgetState extends State<NfcReaderWidget> {
  String tagInfo = 'Acerca un tag NFC para comenzar la lectura';
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    FFAppState().addListener(_checkRestartNfc);
    _startNfcListener();
  }

  @override
  void dispose() {
    FFAppState().removeListener(_checkRestartNfc);
    NfcManager.instance.stopSession();
    super.dispose();
  }

  void _checkRestartNfc() {
    if (FFAppState().reiniciarLecturaNFC) {
      FFAppState().update(() => FFAppState().reiniciarLecturaNFC = false);
      _restartNfcListener();
    }
  }

  void _restartNfcListener() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 300));
    _startNfcListener();
  }

  void _startNfcListener() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        hasError = true;
        tagInfo = _formatError('NFC no disponible', [
          '1. Verifica que tu dispositivo soporta NFC',
          '2. Activa el NFC en ajustes del sistema',
          '3. Otorga los permisos necesarios a la app'
        ]);
      });
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        final uid = _getTagUid(tag);
        final info = await _readTagData(tag);
        HapticFeedback.vibrate();

        setState(() {
          tagInfo = _formatTagInfo(info);
          hasError = false;
          FFAppState().update(() {
            FFAppState().contenidoEscritoNFC = info['contenidoAscii'] ?? '';
            FFAppState().contenidoHexNFC = info['contenidoHex'] ?? '';
            FFAppState().contenidoDecimal = info['contenidoDecimal'] ?? '';
            FFAppState().uidNFC = uid;
            FFAppState().tipoNfc = info['memoryInfo']?['Tipo'] ?? '';
            FFAppState().protocoloNFC = info['techDetails']?['Protocolo'] ?? '';
            FFAppState().capacidadNFC =
                info['memoryInfo']?['Capacidad total'] ?? '';
            FFAppState().pagesNFC = info['memoryInfo']?['Páginas'] ?? '';
            FFAppState().bytePageNFC =
                info['memoryInfo']?['Bytes por página'] ?? '';
            FFAppState().suppNdefNFC =
                info['ndefInfo']?['Capacidad máxima'] ?? '';
            FFAppState().writingNdefNFC = info['ndefInfo']?['Escritura'] ?? '';
            if (info['ndefRecords'] != null && info['ndefRecords'].isNotEmpty) {
              final lastRecord = info['ndefRecords'].last;
              FFAppState().recordTipoNFC = lastRecord['Tipo'] ?? '';
              FFAppState().recordTamano = lastRecord['Tamaño'] ?? '';
              FFAppState().recordContenidoNFC = lastRecord['Contenido'] ?? '';
            } else {
              FFAppState().recordTipoNFC = '';
              FFAppState().recordTamano = '';
              FFAppState().recordContenidoNFC = '';
            }
          });
        });
      } catch (e) {
        setState(() {
          tagInfo = _formatError('Error leyendo el tag: $e');
          hasError = true;
        });
      }
    });
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

      try {
        final response =
            await nfcA.transceive(data: Uint8List.fromList([0x30, 0x07]));
        final ascii = utf8.decode(response.sublist(0, 4)).trim();

        final firstByte = response[0];
        final hex =
            '0x${firstByte.toRadixString(16).padLeft(2, '0').toUpperCase()}';
        final decimal = firstByte.toString();

        // Si algún día necesitas mostrar los 4 bytes como: 6a 00 00 00
        // final hexFull = response.sublist(0, 4).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
        // info['contenidoHexFull'] = hexFull;

        info['contenidoAscii'] = ascii;
        info['contenidoHex'] = hex;
        info['contenidoDecimal'] = decimal;

        info['ndefRecords'] = [
          {
            'Tipo': 'Manual',
            'Contenido': ascii,
            'Tamaño': '${ascii.length} bytes',
          }
        ];
      } catch (e) {
        info['ndefError'] = 'Error leyendo página 7: $e';
      }

      info['memoryInfo'] = {
        'Tipo': 'NTAG215',
        'Capacidad total': '540 bytes',
        'Páginas': '135',
        'Bytes por página': '4',
        'Área de usuario': '504 bytes',
        'Bloqueo': 'Configurable'
      };
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

  String _formatError(String message, [List<String>? details]) {
    final buffer = StringBuffer();
    buffer.writeln('⚠️ $message');
    buffer.writeln('━━━━━━━━━━━━━━━━━━');
    details?.forEach((detail) => buffer.writeln('\n• $detail'));
    return buffer.toString();
  }

  String _formatTagInfo(Map<String, dynamic> info) {
    final buffer = StringBuffer();
    buffer.writeln('🏷️ TAG NFC DETECTADO');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━\n');
    buffer.writeln('🆔 UID: ${info['uid']}');
    buffer.writeln('📌 Tipo: ${info['type']}');
    buffer.writeln('📡 Tecnologías: ${info['techList']}\n');

    if (info['techDetails'] != null) {
      buffer.writeln('🔧 DETALLES TÉCNICOS');
      buffer.writeln('────────────────────');
      (info['techDetails'] as Map<String, dynamic>)
          .forEach((k, v) => buffer.writeln('$k: $v'));
      buffer.writeln();
    }
    if (info['memoryInfo'] != null) {
      buffer.writeln('💾 INFORMACIÓN DE MEMORIA');
      buffer.writeln('────────────────────────');
      (info['memoryInfo'] as Map<String, dynamic>)
          .forEach((k, v) => buffer.writeln('$k: $v'));
      buffer.writeln();
    }
    if (info['ndefRecords'] != null) {
      buffer.writeln('📌 CONTENIDO MANUAL LEÍDO DE PÁGINA 7');
      buffer.writeln('─────────────────────────────');
      for (final record in info['ndefRecords']) {
        buffer.writeln('\n• Tipo: ${record['Tipo']}');
        buffer.writeln('• Tamaño: ${record['Tamaño']}');
        buffer.writeln('• Contenido: ${record['Contenido']}');
      }
    } else if (info['ndefError'] != null) {
      buffer.writeln('\n❌ Error leyendo contenido: ${info['ndefError']}');
    } else {
      buffer.writeln('\nℹ️ No se encontró contenido en página 7');
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 500,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Text(
          tagInfo,
          style: TextStyle(
            fontSize: 14,
            color: hasError ? Colors.red[700] : Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}*/

// class NfcReaderWidget extends StatefulWidget {
//   const NfcReaderWidget({
//     super.key,
//     this.width,
//     this.height,
//   });

//   final double? width;
//   final double? height;

//   @override
//   State<NfcReaderWidget> createState() => _NfcReaderWidgetState();
// }

// class _NfcReaderWidgetState extends State<NfcReaderWidget> {
//   String tagInfo = 'Acerca un tag NFC para comenzar la lectura';
//   bool hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     _startNfcListener();
//   }

//   @override
//   void dispose() {
//     NfcManager.instance.stopSession();
//     super.dispose();
//   }

//   void _startNfcListener() async {
//     final isAvailable = await NfcManager.instance.isAvailable();
//     if (!isAvailable) {
//       setState(() {
//         hasError = true;
//         tagInfo = _formatError('NFC no disponible', [
//           '1. Verifica que tu dispositivo soporta NFC',
//           '2. Activa el NFC en ajustes del sistema',
//           '3. Otorga los permisos necesarios a la app'
//         ]);
//       });
//       return;
//     }

//     NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
//       try {
//         final uid = _getTagUid(tag);
//         final info = await _readTagData(tag);
//         HapticFeedback.vibrate();

//         setState(() {
//           tagInfo = _formatTagInfo(info);
//           hasError = false;
//           FFAppState().update(() {
//             FFAppState().contenidoEscritoNFC = info['contenidoAscii'] ?? '';
//             FFAppState().contenidoHexNFC = info['contenidoHex'] ?? '';
//             FFAppState().contenidoDecimal = info['contenidoDecimal'] ?? '';
//             FFAppState().uidNFC = uid;
//             FFAppState().tipoNfc = info['memoryInfo']?['Tipo'] ?? '';
//             FFAppState().protocoloNFC = info['techDetails']?['Protocolo'] ?? '';
//             FFAppState().capacidadNFC =
//                 info['memoryInfo']?['Capacidad total'] ?? '';
//             FFAppState().pagesNFC = info['memoryInfo']?['Páginas'] ?? '';
//             FFAppState().bytePageNFC =
//                 info['memoryInfo']?['Bytes por página'] ?? '';
//             FFAppState().suppNdefNFC =
//                 info['ndefInfo']?['Capacidad máxima'] ?? '';
//             FFAppState().writingNdefNFC = info['ndefInfo']?['Escritura'] ?? '';
//             if (info['ndefRecords'] != null && info['ndefRecords'].isNotEmpty) {
//               final lastRecord = info['ndefRecords'].last;
//               FFAppState().recordTipoNFC = lastRecord['Tipo'] ?? '';
//               FFAppState().recordTamano = lastRecord['Tamaño'] ?? '';
//               FFAppState().recordContenidoNFC = lastRecord['Contenido'] ?? '';
//             } else {
//               FFAppState().recordTipoNFC = '';
//               FFAppState().recordTamano = '';
//               FFAppState().recordContenidoNFC = '';
//             }
//           });
//         });
//       } catch (e) {
//         setState(() {
//           tagInfo = _formatError('Error leyendo el tag: $e');
//           hasError = true;
//         });
//       }
//     });
//   }

//   Future<Map<String, dynamic>> _readTagData(NfcTag tag) async {
//     final info = <String, dynamic>{};

//     info['uid'] = _getTagUid(tag);
//     info['type'] = tag.data['type']?.toString() ?? 'Desconocido';
//     info['techList'] = tag.data['techList'] != null
//         ? (tag.data['techList'] as List).map((e) => e.toString()).join(', ')
//         : 'Desconocido';

//     final nfcA = NfcA.from(tag);
//     if (nfcA != null) {
//       info['techDetails'] = {
//         'Protocolo': 'NFC-A (ISO 14443-3A)',
//         'ATQA': nfcA.atqa != null
//             ? '0x${List<int>.from(nfcA.atqa).map((e) => e.toRadixString(16).padLeft(2, '0')).join()}'
//             : 'Desconocido',
//         'SAK': nfcA.sak != null
//             ? '0x${nfcA.sak.toRadixString(16).padLeft(2, '0')}'
//             : 'Desconocido',
//       };

//       try {
//         final response =
//             await nfcA.transceive(data: Uint8List.fromList([0x30, 0x07]));
//         final ascii = utf8.decode(response.sublist(0, 4)).trim();

//         final firstByte = response[0];
//         final hex =
//             '0x${firstByte.toRadixString(16).padLeft(2, '0').toUpperCase()}';
//         final decimal = firstByte.toString();

//         // Si algún día necesitas mostrar los 4 bytes como: 6a 00 00 00
//         // final hexFull = response.sublist(0, 4).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
//         // info['contenidoHexFull'] = hexFull;

//         info['contenidoAscii'] = ascii;
//         info['contenidoHex'] = hex;
//         info['contenidoDecimal'] = decimal;

//         info['ndefRecords'] = [
//           {
//             'Tipo': 'Manual',
//             'Contenido': ascii,
//             'Tamaño': '${ascii.length} bytes',
//           }
//         ];
//       } catch (e) {
//         info['ndefError'] = 'Error leyendo página 7: $e';
//       }

//       info['memoryInfo'] = {
//         'Tipo': 'NTAG215',
//         'Capacidad total': '540 bytes',
//         'Páginas': '135',
//         'Bytes por página': '4',
//         'Área de usuario': '504 bytes',
//         'Bloqueo': 'Configurable'
//       };
//     }

//     return info;
//   }

//   String _getTagUid(NfcTag tag) {
//     final nfcA = NfcA.from(tag);
//     if (nfcA != null && nfcA.identifier.isNotEmpty) {
//       return nfcA.identifier
//           .map((e) => e.toRadixString(16).padLeft(2, '0'))
//           .join(':')
//           .toUpperCase();
//     }
//     return 'No disponible';
//   }

//   String _formatError(String message, [List<String>? details]) {
//     final buffer = StringBuffer();
//     buffer.writeln('⚠️ $message');
//     buffer.writeln('━━━━━━━━━━━━━━━━━━');
//     details?.forEach((detail) => buffer.writeln('\n• $detail'));
//     return buffer.toString();
//   }

//   String _formatTagInfo(Map<String, dynamic> info) {
//     final buffer = StringBuffer();
//     buffer.writeln('🏷️ TAG NFC DETECTADO');
//     buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━\n');
//     buffer.writeln('🆔 UID: ${info['uid']}');
//     buffer.writeln('📌 Tipo: ${info['type']}');
//     buffer.writeln('📡 Tecnologías: ${info['techList']}\n');

//     if (info['techDetails'] != null) {
//       buffer.writeln('🔧 DETALLES TÉCNICOS');
//       buffer.writeln('────────────────────');
//       (info['techDetails'] as Map<String, dynamic>)
//           .forEach((k, v) => buffer.writeln('$k: $v'));
//       buffer.writeln();
//     }
//     if (info['memoryInfo'] != null) {
//       buffer.writeln('💾 INFORMACIÓN DE MEMORIA');
//       buffer.writeln('────────────────────────');
//       (info['memoryInfo'] as Map<String, dynamic>)
//           .forEach((k, v) => buffer.writeln('$k: $v'));
//       buffer.writeln();
//     }
//     if (info['ndefRecords'] != null) {
//       buffer.writeln('📌 CONTENIDO MANUAL LEÍDO DE PÁGINA 7');
//       buffer.writeln('─────────────────────────────');
//       for (final record in info['ndefRecords']) {
//         buffer.writeln('\n• Tipo: ${record['Tipo']}');
//         buffer.writeln('• Tamaño: ${record['Tamaño']}');
//         buffer.writeln('• Contenido: ${record['Contenido']}');
//       }
//     } else if (info['ndefError'] != null) {
//       buffer.writeln('\n❌ Error leyendo contenido: ${info['ndefError']}');
//     } else {
//       buffer.writeln('\nℹ️ No se encontró contenido en página 7');
//     }

//     return buffer.toString();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: widget.width ?? double.infinity,
//       height: widget.height ?? 500,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: SingleChildScrollView(
//         child: Text(
//           tagInfo,
//           style: TextStyle(
//             fontSize: 14,
//             color: hasError ? Colors.red[700] : Colors.black87,
//             height: 1.4,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class NfcReaderWidget extends StatefulWidget {
//   const NfcReaderWidget({
//     super.key,
//     this.width,
//     this.height,
//   });

//   final double? width;
//   final double? height;

//   @override
//   State<NfcReaderWidget> createState() => _NfcReaderWidgetState();
// }

// class _NfcReaderWidgetState extends State<NfcReaderWidget> {
//   String tagInfo = 'Acerca un tag NFC para comenzar la lectura';
//   String? lastUid;
//   bool hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     _startNfcListener();
//     FFAppState().addListener(_handleContenidoEscrito);
//   }

//   @override
//   void dispose() {
//     FFAppState().removeListener(_handleContenidoEscrito);
//     NfcManager.instance.stopSession();
//     super.dispose();
//   }

//   void _handleContenidoEscrito() {
//     final nuevoContenido = FFAppState().contenidoEscritoNFC;
//     if (nuevoContenido.isNotEmpty) {
//       setState(() {
//         FFAppState().recordContenidoNFC = nuevoContenido;
//         tagInfo = '✍️ Contenido actualizado dinámicamente: \n"$nuevoContenido"';
//       });
//     }
//   }

//   void _startNfcListener() async {
//     final isAvailable = await NfcManager.instance.isAvailable();
//     if (!isAvailable) {
//       setState(() {
//         hasError = true;
//         tagInfo = _formatError('NFC no disponible', [
//           '1. Verifica que tu dispositivo soporta NFC',
//           '2. Activa el NFC en ajustes del sistema',
//           '3. Otorga los permisos necesarios a la app'
//         ]);
//       });
//       return;
//     }

//     NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
//       try {
//         final uid = _getTagUid(tag);
//         if (uid == lastUid && FFAppState().contenidoEscritoNFC.isEmpty) return;

//         final info = await _readTagData(tag);
//         HapticFeedback.vibrate();

//         setState(() {
//           tagInfo = _formatTagInfo(info);
//           hasError = false;
//           lastUid = uid;
//           FFAppState().update(() {
//             FFAppState().contenidoEscritoNFC = '';
//             FFAppState().uidNFC = uid;
//             FFAppState().tipoNfc = info['memoryInfo']?['Tipo'] ?? '';
//             FFAppState().protocoloNFC = info['techDetails']?['Protocolo'] ?? '';
//             FFAppState().capacidadNFC =
//                 info['memoryInfo']?['Capacidad total'] ?? '';
//             FFAppState().pagesNFC = info['memoryInfo']?['Páginas'] ?? '';
//             FFAppState().bytePageNFC =
//                 info['memoryInfo']?['Bytes por página'] ?? '';
//             FFAppState().suppNdefNFC =
//                 info['ndefInfo']?['Capacidad máxima'] ?? '';
//             FFAppState().writingNdefNFC = info['ndefInfo']?['Escritura'] ?? '';

//             if (info['ndefRecords'] != null && info['ndefRecords'].isNotEmpty) {
//               final lastRecord = info['ndefRecords'].last;
//               FFAppState().recordTipoNFC = lastRecord['Tipo'] ?? '';
//               FFAppState().recordTamano = lastRecord['Tamaño'] ?? '';
//               FFAppState().recordContenidoNFC = lastRecord['Contenido'] ?? '';
//             } else {
//               FFAppState().recordTipoNFC = '';
//               FFAppState().recordTamano = '';
//               FFAppState().recordContenidoNFC = '';
//             }
//           });
//         });
//       } catch (e) {
//         setState(() {
//           tagInfo = _formatError('Error leyendo el tag: $e');
//           hasError = true;
//         });
//       }
//     });
//   }

//   Future<Map<String, dynamic>> _readTagData(NfcTag tag) async {
//     final info = <String, dynamic>{};

//     info['uid'] = _getTagUid(tag);
//     info['type'] = tag.data['type']?.toString() ?? 'Desconocido';
//     info['techList'] = tag.data['techList'] != null
//         ? (tag.data['techList'] as List).map((e) => e.toString()).join(', ')
//         : 'Desconocido';

//     final nfcA = NfcA.from(tag);
//     if (nfcA != null) {
//       info['techDetails'] = {
//         'Protocolo': 'NFC-A (ISO 14443-3A)',
//         'ATQA': nfcA.atqa != null
//             ? '0x${List<int>.from(nfcA.atqa).map((e) => e.toRadixString(16).padLeft(2, '0')).join()}'
//             : 'Desconocido',
//         'SAK': nfcA.sak != null
//             ? '0x${nfcA.sak.toRadixString(16).padLeft(2, '0')}'
//             : 'Desconocido',
//       };

//       if (nfcA.identifier.length == 7) {
//         info['memoryInfo'] = {
//           'Tipo': 'NTAG215 (estimado)',
//           'Capacidad total': '540 bytes (estimado)',
//           'Páginas': '135 (estimado)',
//           'Bytes por página': '4',
//           'Área de usuario': '504 bytes (estimado)',
//           'Bloqueo': 'Configurable',
//           'Nota': 'Estimación basada en longitud del UID'
//         };
//       } else if (nfcA.identifier.length == 4) {
//         info['memoryInfo'] = {
//           'Tipo': 'MIFARE Classic (estimado)',
//           'Capacidad total': '1K/4K (estimado)',
//           'Sectores': '16/40',
//           'Bloques por sector': '4',
//           'Bytes por bloque': '16',
//           'Nota': 'Estimación basada en longitud del UID'
//         };
//       }

//       try {
//         final response =
//             await nfcA.transceive(data: Uint8List.fromList([0x30, 0x07]));
//         final contenidoPagina7 = utf8.decode(response.sublist(0, 4)).trim();
//         info['ndefRecords'] = [
//           {
//             'Tipo': 'Manual',
//             'Contenido': contenidoPagina7,
//             'Tamaño': '${contenidoPagina7.length} bytes',
//           }
//         ];
//       } catch (e) {
//         info['ndefError'] = 'Error leyendo página 7: $e';
//       }
//     }

//     return info;
//   }

//   String _getTagUid(NfcTag tag) {
//     final nfcA = NfcA.from(tag);
//     if (nfcA != null && nfcA.identifier.isNotEmpty) {
//       return nfcA.identifier
//           .map((e) => e.toRadixString(16).padLeft(2, '0'))
//           .join(':')
//           .toUpperCase();
//     }
//     return 'No disponible';
//   }

//   String _formatError(String message, [List<String>? details]) {
//     final buffer = StringBuffer();
//     buffer.writeln('⚠️ $message');
//     buffer.writeln('━━━━━━━━━━━━━━━━━━');
//     details?.forEach((detail) => buffer.writeln('\n• $detail'));
//     return buffer.toString();
//   }

//   String _formatTagInfo(Map<String, dynamic> info) {
//     final buffer = StringBuffer();
//     buffer.writeln('🏷️ TAG NFC DETECTADO');
//     buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━\n');
//     buffer.writeln('🆔 UID: ${info['uid']}');
//     buffer.writeln('📌 Tipo: ${info['type']}');
//     buffer.writeln('📡 Tecnologías: ${info['techList']}\n');

//     if (info['techDetails'] != null) {
//       buffer.writeln('🔧 DETALLES TÉCNICOS');
//       buffer.writeln('────────────────────');
//       (info['techDetails'] as Map<String, dynamic>)
//           .forEach((k, v) => buffer.writeln('$k: $v'));
//       buffer.writeln();
//     }
//     if (info['memoryInfo'] != null) {
//       buffer.writeln('💾 INFORMACIÓN DE MEMORIA');
//       buffer.writeln('────────────────────────');
//       (info['memoryInfo'] as Map<String, dynamic>)
//           .forEach((k, v) => buffer.writeln('$k: $v'));
//       buffer.writeln();
//     }
//     if (info['ndefRecords'] != null) {
//       buffer.writeln('📌 CONTENIDO MANUAL LEÍDO DE PÁGINA 7');
//       buffer.writeln('─────────────────────────────');
//       for (final record in info['ndefRecords']) {
//         buffer.writeln('\n• Tipo: ${record['Tipo']}');
//         buffer.writeln('• Tamaño: ${record['Tamaño']}');
//         buffer.writeln('• Contenido: ${record['Contenido']}');
//       }
//     } else if (info['ndefError'] != null) {
//       buffer.writeln('\n❌ Error leyendo contenido: ${info['ndefError']}');
//     } else {
//       buffer.writeln('\nℹ️ No se encontró contenido en página 7');
//     }

//     return buffer.toString();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: widget.width ?? double.infinity,
//       height: widget.height ?? 500,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: SingleChildScrollView(
//         child: Text(
//           tagInfo,
//           style: TextStyle(
//             fontSize: 14,
//             color: hasError ? Colors.red[700] : Colors.black87,
//             height: 1.4,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class NfcReaderWidget extends StatefulWidget {
//   const NfcReaderWidget({
//     super.key,
//     this.width,
//     this.height,
//   });

//   final double? width;
//   final double? height;

//   @override
//   State<NfcReaderWidget> createState() => _NfcReaderWidgetState();
// }

// class _NfcReaderWidgetState extends State<NfcReaderWidget> {
//   String tagInfo = 'Acerca un tag NFC para comenzar la lectura';
//   String? lastUid;
//   bool hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     _startNfcListener();
//     FFAppState().addListener(_handleContenidoEscrito);
//   }

//   @override
//   void dispose() {
//     FFAppState().removeListener(_handleContenidoEscrito);
//     NfcManager.instance.stopSession();
//     super.dispose();
//   }

//   void _handleContenidoEscrito() {
//     final nuevoContenido = FFAppState().contenidoEscritoNFC;
//     if (nuevoContenido.isNotEmpty) {
//       setState(() {
//         FFAppState().recordContenidoNFC = nuevoContenido;
//         tagInfo = '✍️ Contenido actualizado dinámicamente: \n"$nuevoContenido"';
//       });
//     }
//   }

//   void _startNfcListener() async {
//     final isAvailable = await NfcManager.instance.isAvailable();
//     if (!isAvailable) {
//       setState(() {
//         hasError = true;
//         tagInfo = _formatError('NFC no disponible', [
//           '1. Verifica que tu dispositivo soporta NFC',
//           '2. Activa el NFC en ajustes del sistema',
//           '3. Otorga los permisos necesarios a la app'
//         ]);
//       });
//       return;
//     }

//     NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
//       try {
//         final uid = _getTagUid(tag);
//         if (uid == lastUid && FFAppState().contenidoEscritoNFC.isEmpty) return;

//         final info = await _readTagData(tag);
//         HapticFeedback.vibrate();

//         setState(() {
//           tagInfo = _formatTagInfo(info);
//           hasError = false;
//           lastUid = uid;
//           FFAppState().update(() {
//             FFAppState().contenidoEscritoNFC = '';
//             FFAppState().uidNFC = uid;
//             FFAppState().tipoNfc = info['memoryInfo']?['Tipo'] ?? '';
//             FFAppState().protocoloNFC = info['techDetails']?['Protocolo'] ?? '';
//             FFAppState().capacidadNFC =
//                 info['memoryInfo']?['Capacidad total'] ?? '';
//             FFAppState().pagesNFC = info['memoryInfo']?['Páginas'] ?? '';
//             FFAppState().bytePageNFC =
//                 info['memoryInfo']?['Bytes por página'] ?? '';
//             FFAppState().suppNdefNFC =
//                 info['ndefInfo']?['Capacidad máxima'] ?? '';
//             FFAppState().writingNdefNFC = info['ndefInfo']?['Escritura'] ?? '';

//             if (info['ndefRecords'] != null && info['ndefRecords'].isNotEmpty) {
//               final lastRecord = info['ndefRecords'].last;
//               FFAppState().recordTipoNFC = lastRecord['Tipo'] ?? '';
//               FFAppState().recordTamano = lastRecord['Tamaño'] ?? '';
//               FFAppState().recordContenidoNFC = lastRecord['Contenido'] ?? '';
//             } else {
//               FFAppState().recordTipoNFC = '';
//               FFAppState().recordTamano = '';
//               FFAppState().recordContenidoNFC = '';
//             }
//           });
//         });
//       } catch (e) {
//         setState(() {
//           tagInfo = _formatError('Error leyendo el tag: $e');
//           hasError = true;
//         });
//       }
//     });
//   }

//   Future<Map<String, dynamic>> _readTagData(NfcTag tag) async {
//     final info = <String, dynamic>{};

//     info['uid'] = _getTagUid(tag);
//     info['type'] = tag.data['type']?.toString() ?? 'Desconocido';
//     info['techList'] = tag.data['techList'] != null
//         ? (tag.data['techList'] as List).map((e) => e.toString()).join(', ')
//         : 'Desconocido';

//     final nfcA = NfcA.from(tag);
//     if (nfcA != null) {
//       info['techDetails'] = {
//         'Protocolo': 'NFC-A (ISO 14443-3A)',
//         'ATQA': nfcA.atqa != null
//             ? '0x${List<int>.from(nfcA.atqa).map((e) => e.toRadixString(16).padLeft(2, '0')).join()}'
//             : 'Desconocido',
//         'SAK': nfcA.sak != null
//             ? '0x${nfcA.sak.toRadixString(16).padLeft(2, '0')}'
//             : 'Desconocido',
//       };

//       if (nfcA.identifier.length == 7) {
//         info['memoryInfo'] = {
//           'Tipo': 'NTAG215',
//           'Capacidad total': '540 bytes',
//           'Páginas': '135',
//           'Bytes por página': '4',
//           'Área de usuario': '504 bytes',
//           'Bloqueo': 'Configurable',
//           'Nota': 'Estimación basada en longitud del UID'
//         };
//       } else if (nfcA.identifier.length == 4) {
//         info['memoryInfo'] = {
//           'Tipo': 'MIFARE Classic (estimado)',
//           'Capacidad total': '1K/4K (estimado)',
//           'Sectores': '16/40',
//           'Bloques por sector': '4',
//           'Bytes por bloque': '16',
//           'Nota': 'Estimación basada en longitud del UID'
//         };
//       }

//       try {
//         final response =
//             await nfcA.transceive(data: Uint8List.fromList([0x30, 0x07]));
//         final contenidoPagina7 = utf8.decode(response.sublist(0, 4)).trim();
//         info['ndefRecords'] = [
//           {
//             'Tipo': 'Manual',
//             'Contenido': contenidoPagina7,
//             'Tamaño': '${contenidoPagina7.length} bytes',
//           }
//         ];
//       } catch (e) {
//         info['ndefError'] = 'Error leyendo página 7: $e';
//       }
//     }

//     return info;
//   }

//   String _getTagUid(NfcTag tag) {
//     final nfcA = NfcA.from(tag);
//     if (nfcA != null && nfcA.identifier.isNotEmpty) {
//       return nfcA.identifier
//           .map((e) => e.toRadixString(16).padLeft(2, '0'))
//           .join(':')
//           .toUpperCase();
//     }
//     return 'No disponible';
//   }

//   String _formatError(String message, [List<String>? details]) {
//     final buffer = StringBuffer();
//     buffer.writeln('⚠️ $message');
//     buffer.writeln('━━━━━━━━━━━━━━━━━━');
//     details?.forEach((detail) => buffer.writeln('\n• $detail'));
//     return buffer.toString();
//   }

//   String _formatTagInfo(Map<String, dynamic> info) {
//     final buffer = StringBuffer();
//     buffer.writeln('🏷️ TAG NFC DETECTADO');
//     buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━\n');
//     buffer.writeln('🆔 UID: ${info['uid']}');
//     buffer.writeln('📌 Tipo: ${info['type']}');
//     buffer.writeln('📡 Tecnologías: ${info['techList']}\n');

//     if (info['techDetails'] != null) {
//       buffer.writeln('🔧 DETALLES TÉCNICOS');
//       buffer.writeln('────────────────────');
//       (info['techDetails'] as Map<String, dynamic>)
//           .forEach((k, v) => buffer.writeln('$k: $v'));
//       buffer.writeln();
//     }
//     if (info['memoryInfo'] != null) {
//       buffer.writeln('💾 INFORMACIÓN DE MEMORIA');
//       buffer.writeln('────────────────────────');
//       (info['memoryInfo'] as Map<String, dynamic>)
//           .forEach((k, v) => buffer.writeln('$k: $v'));
//       buffer.writeln();
//     }
//     if (info['ndefRecords'] != null) {
//       buffer.writeln('📌 CONTENIDO MANUAL LEÍDO DE PÁGINA 7');
//       buffer.writeln('─────────────────────────────');
//       for (final record in info['ndefRecords']) {
//         buffer.writeln('\n• Tipo: ${record['Tipo']}');
//         buffer.writeln('• Tamaño: ${record['Tamaño']}');
//         buffer.writeln('• Contenido: ${record['Contenido']}');
//       }
//     } else if (info['ndefError'] != null) {
//       buffer.writeln('\n❌ Error leyendo contenido: ${info['ndefError']}');
//     } else {
//       buffer.writeln('\nℹ️ No se encontró contenido en página 7');
//     }

//     return buffer.toString();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: widget.width ?? double.infinity,
//       height: widget.height ?? 500,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: SingleChildScrollView(
//         child: Text(
//           tagInfo,
//           style: TextStyle(
//             fontSize: 14,
//             color: hasError ? Colors.red[700] : Colors.black87,
//             height: 1.4,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Automatic FlutterFlow imports
// import '/flutter_flow/flutter_flow_theme.dart';
// import '/flutter_flow/flutter_flow_util.dart';
// import '/custom_code/widgets/index.dart'; // Imports other custom widgets
// import '/custom_code/actions/index.dart'; // Imports custom actions
// import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// import 'package:flutter/material.dart';
// // Begin custom widget code
// // DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// import 'package:nfc_manager/nfc_manager.dart';
// import 'package:nfc_manager/platform_tags.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';

// class NfcReaderWidget extends StatefulWidget {
//   const NfcReaderWidget({
//     super.key,
//     this.width,
//     this.height,
//   });

//   final double? width;
//   final double? height;

//   @override
//   State<NfcReaderWidget> createState() => _NfcReaderWidgetState();
// }

// class _NfcReaderWidgetState extends State<NfcReaderWidget> {
//   String tagInfo = 'Acerca un tag NFC para comenzar la lectura';
//   String? lastUid;
//   bool hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     _startNfcListener();
//   }

//   @override
//   void dispose() {
//     NfcManager.instance.stopSession();
//     super.dispose();
//   }

//   void _startNfcListener() async {
//     final isAvailable = await NfcManager.instance.isAvailable();
//     if (!isAvailable) {
//       setState(() {
//         hasError = true;
//         tagInfo = _formatError('NFC no disponible', [
//           '1. Verifica que tu dispositivo soporta NFC',
//           '2. Activa el NFC en ajustes del sistema',
//           '3. Otorga los permisos necesarios a la app'
//         ]);
//       });
//       return;
//     }

//     NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
//       try {
//         final uid = _getTagUid(tag);
//         if (uid == lastUid) return;

//         final info = await _readTagData(tag);
//         HapticFeedback.vibrate();

//         setState(() {
//           tagInfo = _formatTagInfo(info);
//           hasError = false;
//           lastUid = uid;
//           FFAppState().update(() {
//             FFAppState().contenidoEscritoNFC = '';
//             FFAppState().uidNFC = uid;
//             FFAppState().tipoNfc = info['memoryInfo']?['Tipo'] ?? '';
//             FFAppState().protocoloNFC = info['techDetails']?['Protocolo'] ?? '';
//             FFAppState().capacidadNFC =
//                 info['memoryInfo']?['Capacidad total'] ?? '';
//             FFAppState().pagesNFC = info['memoryInfo']?['Páginas'] ?? '';
//             FFAppState().bytePageNFC =
//                 info['memoryInfo']?['Bytes por página'] ?? '';
//             FFAppState().suppNdefNFC =
//                 info['ndefInfo']?['Capacidad máxima'] ?? '';
//             FFAppState().writingNdefNFC = info['ndefInfo']?['Escritura'] ?? '';

//             // Verificamos que haya al menos un registro NDEF
//             if (info['ndefRecords'] != null && info['ndefRecords'].isNotEmpty) {
//               FFAppState().recordTipoNFC = info['ndefRecords'][0]['Tipo'] ?? '';
//               FFAppState().recordTamano =
//                   info['ndefRecords'][0]['Tamaño'] ?? '';
//               FFAppState().recordContenidoNFC =
//                   info['ndefRecords'][0]['Contenido'] ?? '';
//             } else {
//               // Limpiar si no hay datos
//               FFAppState().recordTipoNFC = '';
//               FFAppState().recordTamano = '';
//               FFAppState().recordContenidoNFC = '';
//             }
//           });
//         });
//       } catch (e) {
//         setState(() {
//           tagInfo = _formatError('Error leyendo el tag: $e');
//           hasError = true;
//         });
//       }
//     });
//   }

//   Future<Map<String, dynamic>> _readTagData(NfcTag tag) async {
//     final info = <String, dynamic>{};

//     info['uid'] = _getTagUid(tag);
//     info['type'] = tag.data['type']?.toString() ?? 'Desconocido';
//     info['techList'] = tag.data['techList'] != null
//         ? (tag.data['techList'] as List).map((e) => e.toString()).join(', ')
//         : 'Desconocido';

//     final nfcA = NfcA.from(tag);
//     if (nfcA != null) {
//       info['techDetails'] = {
//         'Protocolo': 'NFC-A (ISO 14443-3A)',
//         'ATQA': nfcA.atqa != null
//             ? '0x${List<int>.from(nfcA.atqa).map((e) => e.toRadixString(16).padLeft(2, '0')).join()}'
//             : 'Desconocido',
//         'SAK': nfcA.sak != null
//             ? '0x${nfcA.sak.toRadixString(16).padLeft(2, '0')}'
//             : 'Desconocido',
//       };

//       if (nfcA.identifier.length == 7) {
//         info['memoryInfo'] = {
//           'Tipo': 'NTAG215 (estimado)',
//           'Capacidad total': '540 bytes (estimado)',
//           'Páginas': '135 (estimado)',
//           'Bytes por página': '4',
//           'Área de usuario': '504 bytes (estimado)',
//           'Bloqueo': 'Configurable',
//           'Nota':
//               'Esta información es una estimación basada en la longitud del UID'
//         };
//       } else if (nfcA.identifier.length == 4) {
//         info['memoryInfo'] = {
//           'Tipo': 'MIFARE Classic (estimado)',
//           'Capacidad total': '1K/4K (estimado)',
//           'Sectores': '16/40',
//           'Bloques por sector': '4',
//           'Bytes por bloque': '16',
//           'Nota':
//               'Esta información es una estimación basada en la longitud del UID'
//         };
//       }
//     }

//     final ndef = Ndef.from(tag);
//     if (ndef != null) {
//       info['ndefInfo'] = {
//         'Soporte NDEF': 'Sí',
//         'Capacidad máxima': '${ndef.maxSize} bytes',
//         'Escritura': ndef.isWritable ? 'Posible' : 'No posible',
//       };

//       try {
//         final message = await ndef.read();
//         if (message.records.isNotEmpty) {
//           info['ndefRecords'] = message.records.map((record) {
//             return {
//               'Tipo': _getRecordType(record),
//               'Contenido': _decodeRecordPayload(record),
//               'Tamaño': '${record.payload.length} bytes',
//             };
//           }).toList();
//         }
//       } catch (e) {
//         info['ndefError'] = e.toString();
//       }
//     }

//     return info;
//   }

//   String _getTagUid(NfcTag tag) {
//     final nfcA = NfcA.from(tag);
//     if (nfcA != null && nfcA.identifier.isNotEmpty) {
//       return nfcA.identifier
//           .map((e) => e.toRadixString(16).padLeft(2, '0'))
//           .join(':')
//           .toUpperCase();
//     }
//     return 'No disponible';
//   }

//   String _getRecordType(NdefRecord record) {
//     if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown) {
//       if (record.type.isNotEmpty && record.type[0] == 0x55) return 'URI';
//       if (record.type.isNotEmpty && record.type[0] == 0x54) return 'Texto';
//     }
//     return record.type.isNotEmpty
//         ? String.fromCharCodes(record.type)
//         : 'Desconocido';
//   }

//   String _decodeRecordPayload(NdefRecord record) {
//     try {
//       if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
//           record.type.isNotEmpty &&
//           record.type[0] == 0x55) {
//         final prefix = _getUriPrefix(record.payload[0]);
//         return prefix + utf8.decode(record.payload.sublist(1));
//       }

//       if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
//           record.type.isNotEmpty &&
//           record.type[0] == 0x54) {
//         if (record.payload.length > 1) {
//           final languageCodeLength = record.payload[0] & 0x3F;
//           if (record.payload.length > languageCodeLength + 1) {
//             return utf8.decode(record.payload.sublist(languageCodeLength + 1));
//           }
//         }
//       }

//       return utf8.decode(record.payload);
//     } catch (e) {
//       return 'Datos binarios: ${record.payload.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':')}';
//     }
//   }

//   String _getUriPrefix(int code) {
//     const prefixes = [
//       "",
//       "http://www.",
//       "https://www.",
//       "http://",
//       "https://",
//       "tel:",
//       "mailto:"
//     ];
//     return code < prefixes.length ? prefixes[code] : "";
//   }

//   String _formatError(String message, [List<String>? details]) {
//     final buffer = StringBuffer();
//     buffer.writeln('⚠️ $message');
//     buffer.writeln('━━━━━━━━━━━━━━━━━━');
//     if (details != null) {
//       for (var detail in details) {
//         buffer.writeln('\n• $detail');
//       }
//     }
//     return buffer.toString();
//   }

//   String _formatTagInfo(Map<String, dynamic> info) {
//     final buffer = StringBuffer();
//     buffer.writeln('🏷️ TAG NFC DETECTADO');
//     buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━');
//     buffer.writeln();

//     buffer.writeln('🆔 UID: ${info['uid']}');
//     buffer.writeln('📌 Tipo: ${info['type']}');
//     buffer.writeln('📡 Tecnologías: ${info['techList']}');
//     buffer.writeln();

//     if (info['techDetails'] != null) {
//       final tech = info['techDetails'] as Map<String, dynamic>;
//       buffer.writeln('🔧 DETALLES TÉCNICOS');
//       buffer.writeln('────────────────────');
//       tech.forEach((key, val) => buffer.writeln('$key: $val'));
//       buffer.writeln();
//     }

//     if (info['memoryInfo'] != null) {
//       final mem = info['memoryInfo'] as Map<String, dynamic>;
//       buffer.writeln('💾 INFORMACIÓN DE MEMORIA');
//       buffer.writeln('────────────────────────');
//       mem.forEach((key, val) => buffer.writeln('$key: $val'));
//       buffer.writeln();
//     }

//     if (info['ndefInfo'] != null) {
//       final ndef = info['ndefInfo'] as Map<String, dynamic>;
//       buffer.writeln('📝 INFORMACIÓN NDEF');
//       buffer.writeln('──────────────────');
//       ndef.forEach((key, val) => buffer.writeln('$key: $val'));
//       buffer.writeln();

//       if (info['ndefRecords'] != null) {
//         buffer.writeln('📌 REGISTROS NDEF ENCONTRADOS');
//         buffer.writeln('─────────────────────────────');
//         for (final record in info['ndefRecords']) {
//           buffer.writeln('\n• Tipo: ${record['Tipo']}');
//           buffer.writeln('• Tamaño: ${record['Tamaño']}');
//           buffer.writeln('• Contenido: ${record['Contenido']}');
//         }
//       } else if (info['ndefError'] != null) {
//         buffer.writeln('\n❌ Error leyendo NDEF: ${info['ndefError']}');
//       } else {
//         buffer.writeln('\nℹ️ No se encontraron registros NDEF');
//       }
//     } else {
//       buffer.writeln('ℹ️ Este tag no soporta NDEF');
//     }

//     return buffer.toString();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: widget.width ?? double.infinity,
//       height: widget.height ?? 500,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: SingleChildScrollView(
//         child: Text(
//           tagInfo,
//           style: TextStyle(
//             fontSize: 14,
//             color: hasError ? Colors.red[700] : Colors.black87,
//             height: 1.4,
//           ),
//         ),
//       ),
//     );
//   }
// }
