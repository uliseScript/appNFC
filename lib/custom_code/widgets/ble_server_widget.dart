// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class BleServerWidget extends StatefulWidget {
  const BleServerWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<BleServerWidget> createState() => _BleServerWidgetState();
}

class _BleServerWidgetState extends State<BleServerWidget> {
  static const platform = MethodChannel('com.2RealPeople.bluetooth/server');
  String status = '⏳ Verificando Bluetooth...';
  Timer? _serverTimer;
  Timer? _bluetoothCheckTimer;
  bool _bluetoothActivo = false;
  bool _servidorIniciado = false;

  @override
  void initState() {
    super.initState();
    _iniciarChequeoBluetooth();
  }

  @override
  void dispose() {
    _serverTimer?.cancel();
    _bluetoothCheckTimer?.cancel();
    super.dispose();
  }

  void _iniciarChequeoBluetooth() {
    _verificarBluetooth();

    _bluetoothCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _verificarBluetooth();
    });
  }

  Future<void> _verificarBluetooth() async {
    try {
      final bool resultado = await platform.invokeMethod('verificarBluetooth');

      if (resultado) {
        if (!_bluetoothActivo) {
          // Bluetooth acaba de encenderse
          setState(() {
            _bluetoothActivo = true;
            status = '✅ Bluetooth activado. Servidor iniciado.';
          });
          _iniciarServidor();
        }
      } else {
        if (_bluetoothActivo || !_servidorIniciado) {
          // Bluetooth está apagado
          setState(() {
            _bluetoothActivo = false;
            _servidorIniciado = false;
            status =
                '⚠️ Bluetooth está desactivado.\nActívalo para iniciar el servidor.';
          });
        }
      }
    } on PlatformException catch (e) {
      setState(() {
        status = '❌ Error al verificar Bluetooth: ${e.message}';
      });
    }
  }

  Future<void> _iniciarServidor() async {
    try {
      final result = await platform.invokeMethod('iniciarServidor');
      setState(() {
        _servidorIniciado = true;
        status = '✅ Servidor activo: $result';
      });

      // Enviar datos cada 5 segundos
      _serverTimer?.cancel();
      _serverTimer =
          Timer.periodic(const Duration(seconds: 5), (_) => _enviarDato());
    } on PlatformException catch (e) {
      setState(() {
        _servidorIniciado = false;
        status = '❌ Error al iniciar servidor: ${e.message}';
      });
    }
  }

  Future<void> _enviarDato() async {
    if (!_bluetoothActivo || !_servidorIniciado) return;
    final mensaje = FFAppState().contenidoHexNFC;
    try {
      final result = await platform.invokeMethod('enviarDato', mensaje);
      setState(() {
        status = '📤 Enviado: $mensaje';
      });
    } on PlatformException catch (e) {
      setState(() {
        status = '❌ Error al enviar: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Text(
        status,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
