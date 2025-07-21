/*
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

import 'dart:async';
import 'package:flutter/services.dart';

class BleServerWidget extends StatefulWidget {
  const BleServerWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<BleServerWidget> createState() => _BleServerWidgetState();
}

class _BleServerWidgetState extends State<BleServerWidget> {
  static const platform = MethodChannel('com.2RealPeople.bluetooth/server');
  String status = '⏳ Verificando Bluetooth...';
  Timer? _timerVerificarBluetooth;
  Timer? _timerEnviarDato;
  bool _bluetoothActivo = false;
  bool _servidorIniciado = false;

  @override
  void initState() {
    super.initState();
    _verificarBluetooth();
    _timerVerificarBluetooth = Timer.periodic(const Duration(seconds: 3), (_) {
      _verificarBluetooth();
    });
  }

  @override
  void dispose() {
    _timerVerificarBluetooth?.cancel();
    _timerEnviarDato?.cancel();
    super.dispose();
  }

  Future<void> _verificarBluetooth() async {
    try {
      final bool isEnabled = await platform.invokeMethod('verificarBluetooth');
      if (isEnabled && !_servidorIniciado) {
        setState(() {
          _bluetoothActivo = true;
          status = '✅ Bluetooth activado.';
        });
        await _iniciarServidor();
      } else if (!isEnabled) {
        setState(() {
          _bluetoothActivo = false;
          _servidorIniciado = false;
          status = '⚠️ Bluetooth desactivado. Por favor actívalo.';
        });
        _timerEnviarDato?.cancel();
      }
    } on PlatformException catch (e) {
      setState(() {
        status = '❌ Error verificando Bluetooth: ${e.message}';
      });
    }
  }

  Future<void> _iniciarServidor() async {
    try {
      final result = await platform.invokeMethod('iniciarServidor');
      setState(() {
        _servidorIniciado = true;
        status = '✅ Servidor BLE iniciado';
      });
      _timerEnviarDato?.cancel();
      _timerEnviarDato = Timer.periodic(const Duration(seconds: 20), (_) {
        _enviarDato();
      });
    } on PlatformException catch (e) {
      setState(() {
        status = '❌ Error iniciando servidor: ${e.message}';
      });
    }
  }

  Future<void> _enviarDato() async {
    if (!_bluetoothActivo || !_servidorIniciado) return;

    final valor = FFAppState().contenidoHexNFC; //
    if (valor.isEmpty || !valor.startsWith('0x')) {
      setState(() {
        status = '⚠️ Valor en AppState no válido: "$valor"';
      });
      return;
    }

    try {
      final String result = await platform.invokeMethod('enviarDato', valor);
      setState(() {
        status = '📤 Enviado a cliente: $valor\n✅ $result';
      });
    } on PlatformException catch (e) {
      final msg = e.message ?? '';
      if (msg.contains("no conectado")) {
        setState(() {
          status = '⚠️ No hay cliente conectado.\nEsperando conexión...';
        });
      } else {
        setState(() {
          status = '❌ Error enviando: ${e.message}';
        });
      }
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

*/
/*
// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'dart:async';
import 'package:flutter/services.dart';

class BleServerWidget extends StatefulWidget {
  const BleServerWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<BleServerWidget> createState() => _BleServerWidgetState();
}

class _BleServerWidgetState extends State<BleServerWidget> {
  static const platform = MethodChannel('com.2RealPeople.bluetooth/server');
  String status = '⏳ Verificando Bluetooth...';
  Timer? _timerVerificarBluetooth;
  Timer? _timerEnviarDato;
  bool _bluetoothActivo = false;
  bool _servidorIniciado = false;

  @override
  void initState() {
    super.initState();
    _verificarBluetooth();
    _timerVerificarBluetooth = Timer.periodic(const Duration(seconds: 3), (_) {
      _verificarBluetooth();
    });
  }

  @override
  void dispose() {
    _timerVerificarBluetooth?.cancel();
    _timerEnviarDato?.cancel();
    super.dispose();
  }

  Future<void> _verificarBluetooth() async {
    try {
      final bool isEnabled = await platform.invokeMethod('verificarBluetooth');
      if (isEnabled && !_servidorIniciado) {
        setState(() {
          _bluetoothActivo = true;
          status = '✅ Bluetooth activado.';
        });
        await _iniciarServidor();
      } else if (!isEnabled) {
        setState(() {
          _bluetoothActivo = false;
          _servidorIniciado = false;
          status = '⚠️ Bluetooth desactivado. Por favor actívalo.';
        });
        _timerEnviarDato?.cancel();
      }
    } on PlatformException catch (e) {
      setState(() {
        status = '❌ Error verificando Bluetooth: ${e.message}';
      });
    }
  }

  Future<void> _iniciarServidor() async {
    try {
      final result = await platform.invokeMethod('iniciarServidor');
      setState(() {
        _servidorIniciado = true;
        status = '✅ Servidor BLE iniciado';
      });
      _timerEnviarDato?.cancel();
      _timerEnviarDato = Timer.periodic(const Duration(seconds: 20), (_) {
        _enviarDato();
      });
    } on PlatformException catch (e) {
      setState(() {
        status = '❌ Error iniciando servidor: ${e.message}';
      });
    }
  }

  Future<void> _enviarDato() async {
    if (!_bluetoothActivo || !_servidorIniciado) return;

    final valor = FFAppState().contenidoHexNFC; //
    if (valor.isEmpty || !valor.startsWith('0x')) {
      setState(() {
        status = '⚠️ Valor en AppState no válido: "$valor"';
      });
      return;
    }

    try {
      final String result = await platform.invokeMethod('enviarDato', valor);
      setState(() {
        status = '📤 Enviado a cliente: $valor\n✅ $result';
      });
    } on PlatformException catch (e) {
      final msg = e.message ?? '';
      if (msg.contains("no conectado")) {
        setState(() {
          status = '⚠️ No hay cliente conectado.\nEsperando conexión...';
        });
      } else {
        setState(() {
          status = '❌ Error enviando: ${e.message}';
        });
      }
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

*/
/*
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
  const BleServerWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<BleServerWidget> createState() => _BleServerWidgetState();
}

class _BleServerWidgetState extends State<BleServerWidget> {
  static const platform = MethodChannel('com.2RealPeople.bluetooth/server');
  String status = '⏳ Verificando Bluetooth...';
  Timer? _timerVerificarBluetooth;
  Timer? _timerEnviarDato;
  bool _bluetoothActivo = false;
  bool _servidorIniciado = false;

  @override
  void initState() {
    super.initState();
    _verificarBluetooth();
    _timerVerificarBluetooth = Timer.periodic(const Duration(seconds: 3), (_) {
      _verificarBluetooth();
    });
  }

  @override
  void dispose() {
    _timerVerificarBluetooth?.cancel();
    _timerEnviarDato?.cancel();
    super.dispose();
  }

  Future<void> _verificarBluetooth() async {
    try {
      final bool isEnabled = await platform.invokeMethod('verificarBluetooth');
      if (isEnabled && !_servidorIniciado) {
        setState(() {
          _bluetoothActivo = true;
          status = '✅ Bluetooth activado.';
        });
        await _iniciarServidor();
      } else if (!isEnabled) {
        setState(() {
          _bluetoothActivo = false;
          _servidorIniciado = false;
          status = '⚠️ Bluetooth desactivado. Por favor actívalo.';
        });
        _timerEnviarDato?.cancel();
      }
    } on PlatformException catch (e) {
      setState(() {
        status = '❌ Error verificando Bluetooth: ${e.message}';
      });
    }
  }

  Future<void> _iniciarServidor() async {
    try {
      final result = await platform.invokeMethod('iniciarServidor');
      setState(() {
        _servidorIniciado = true;
        status = '✅ Servidor BLE iniciado';
      });
      _timerEnviarDato?.cancel();
      _timerEnviarDato = Timer.periodic(const Duration(seconds: 20), (_) {
        _enviarDato();
      });
    } on PlatformException catch (e) {
      setState(() {
        status = '❌ Error iniciando servidor: ${e.message}';
      });
    }
  }

  Future<void> _enviarDato() async {
    if (!_bluetoothActivo || !_servidorIniciado) return;

    final valor = FFAppState().contenidoHexNFC; //
    if (valor.isEmpty || !valor.startsWith('0x')) {
      setState(() {
        status = '⚠️ Valor en AppState no válido: "$valor"';
      });
      return;
    }

    try {
      final String result = await platform.invokeMethod('enviarDato', valor);
      setState(() {
        status = '📤 Enviado a cliente: $valor\n✅ $result';
      });
    } on PlatformException catch (e) {
      final msg = e.message ?? '';
      if (msg.contains("no conectado")) {
        setState(() {
          status = '⚠️ No hay cliente conectado.\nEsperando conexión...';
        });
      } else {
        setState(() {
          status = '❌ Error enviando: ${e.message}';
        });
      }
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
}*/

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
  const BleServerWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;

  @override
  State<BleServerWidget> createState() => _BleServerWidgetState();
}


class _BleServerWidgetState extends State<BleServerWidget> {
  static const platform = MethodChannel('com.2RealPeople.bluetooth/server');
  String status = '⏳ Iniciando...';
  Timer? _bluetoothTimer;
  Timer? _cambioTimer;
  bool _servidorIniciado = false;
  String _ultimoValor = '';

  @override
  void initState() {
    super.initState();
    _verificarBluetooth();
    _bluetoothTimer =
        Timer.periodic(const Duration(seconds: 3), (_) => _verificarBluetooth());
  }

  @override
  void dispose() {
    _bluetoothTimer?.cancel();
    _cambioTimer?.cancel();
    super.dispose();
  }

  Future<void> _verificarBluetooth() async {
    try {
      final bool isEnabled = await platform.invokeMethod('verificarBluetooth');
      if (isEnabled && !_servidorIniciado) {
        setState(() => status = '✅ Bluetooth activado');
        await _iniciarServidor();
      } else if (!isEnabled) {
        _servidorIniciado = false;
        setState(() => status = '⚠️ Bluetooth apagado');
        _cambioTimer?.cancel();
      }
    } catch (e) {
      setState(() => status = '❌ Error: ${e.toString()}');
    }
  }

  Future<void> _iniciarServidor() async {
    try {
      await platform.invokeMethod('iniciarServidor');
      _servidorIniciado = true;
      setState(() => status = '✅ Servidor BLE iniciado');

      // Enviar valor actual si es válido
      _ultimoValor = FFAppState().contenidoHexNFC;
      if (_esValido(_ultimoValor)) {
        _enviarDato(_ultimoValor);
      }

      _cambioTimer =
          Timer.periodic(const Duration(milliseconds: 300), (_) => _verificarCambio());
    } catch (e) {
      setState(() => status = '❌ Error al iniciar servidor');
    }
  }

  void _verificarCambio() {
    final actual = FFAppState().contenidoHexNFC;
    if (_esValido(actual) && actual != _ultimoValor) {
      _ultimoValor = actual;
      _enviarDato(actual);
    }
  }

  bool _esValido(String valor) {
    return valor.startsWith('0x') && valor.length == 4;
  }

  Future<void> _enviarDato(String valorHex) async {
    try {
      final result = await platform.invokeMethod('enviarDato', valorHex);
      setState(() => status = '📤 Enviado al radio: $valorHex');
    } on PlatformException catch (e) {
      setState(() => status = '❌ Error enviando: ${e.message}');
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
