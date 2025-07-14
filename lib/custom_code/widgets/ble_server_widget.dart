// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

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
  String status = '⏳ Iniciando servidor Bluetooth...';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    iniciarServidor();
    // Envía automáticamente cada 5 segundos el valor desde AppState
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      enviarDato(FFAppState().contenidoHexNFC);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> iniciarServidor() async {
    try {
      final result = await platform.invokeMethod('iniciarServidor');
      setState(() {
        status = '✅ Servidor activo: $result';
      });
    } on PlatformException catch (e) {
      setState(() {
        status = '❌ Error al iniciar servidor: ${e.message}';
      });
    }
  }

  Future<void> enviarDato(String mensaje) async {
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
// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!
