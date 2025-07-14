import 'package:flutter/material.dart';
import 'package:n_f_c_app/backend/api_requests/_/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _userName = prefs.getString('ff_userName') ?? _userName;
    });
    _safeInit(() {
      _password = prefs.getString('ff_password') ?? _password;
    });
    _safeInit(() {
      _uidNFC = prefs.getString('ff_uidNFC') ?? _uidNFC;
    });
    _safeInit(() {
      _tipoNfc = prefs.getString('ff_tipoNfc') ?? _tipoNfc;
    });
    _safeInit(() {
      _protocoloNFC = prefs.getString('ff_protocoloNFC') ?? _protocoloNFC;
    });
    _safeInit(() {
      _pagesNFC = prefs.getString('ff_pagesNFC') ?? _pagesNFC;
    });
    _safeInit(() {
      _capacidadNFC = prefs.getString('ff_capacidadNFC') ?? _capacidadNFC;
    });
    _safeInit(() {
      _bytePageNFC = prefs.getString('ff_bytePageNFC') ?? _bytePageNFC;
    });
    _safeInit(() {
      _suppNdefNFC = prefs.getString('ff_suppNdefNFC') ?? _suppNdefNFC;
    });
    _safeInit(() {
      _writingNdefNFC = prefs.getString('ff_writingNdefNFC') ?? _writingNdefNFC;
    });
    _safeInit(() {
      _recordTipoNFC = prefs.getString('ff_recordTipoNFC') ?? _recordTipoNFC;
    });
    _safeInit(() {
      _recordTamano = prefs.getString('ff_recordTamano') ?? _recordTamano;
    });
    _safeInit(() {
      _recordContenidoNFC =
          prefs.getString('ff_recordContenidoNFC') ?? _recordContenidoNFC;
    });
    _safeInit(() {
      _contenidoEscritoNFC =
          prefs.getString('ff_contenidoEscritoNFC') ?? _contenidoEscritoNFC;
    });
    _safeInit(() {
      _escrituraPagina7 =
          prefs.getString('ff_escrituraPagina7') ?? _escrituraPagina7;
    });
    _safeInit(() {
      _contenidoHexNFC =
          prefs.getString('ff_contenidoHexNFC') ?? _contenidoHexNFC;
    });
    _safeInit(() {
      _contenidoDecimal =
          prefs.getString('ff_contenidoDecimal') ?? _contenidoDecimal;
    });
    _safeInit(() {
      _tagWrite = prefs.getString('ff_tagWrite') ?? _tagWrite;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _userName = '';
  String get userName => _userName;
  set userName(String value) {
    _userName = value;
    prefs.setString('ff_userName', value);
  }

  String _password = '';
  String get password => _password;
  set password(String value) {
    _password = value;
    prefs.setString('ff_password', value);
  }

  String _uidNFC = '';
  String get uidNFC => _uidNFC;
  set uidNFC(String value) {
    _uidNFC = value;
    prefs.setString('ff_uidNFC', value);
  }

  String _tipoNfc = '';
  String get tipoNfc => _tipoNfc;
  set tipoNfc(String value) {
    _tipoNfc = value;
    prefs.setString('ff_tipoNfc', value);
  }

  String _protocoloNFC = '';
  String get protocoloNFC => _protocoloNFC;
  set protocoloNFC(String value) {
    _protocoloNFC = value;
    prefs.setString('ff_protocoloNFC', value);
  }

  String _pagesNFC = '';
  String get pagesNFC => _pagesNFC;
  set pagesNFC(String value) {
    _pagesNFC = value;
    prefs.setString('ff_pagesNFC', value);
  }

  String _capacidadNFC = '';
  String get capacidadNFC => _capacidadNFC;
  set capacidadNFC(String value) {
    _capacidadNFC = value;
    prefs.setString('ff_capacidadNFC', value);
  }

  String _bytePageNFC = '';
  String get bytePageNFC => _bytePageNFC;
  set bytePageNFC(String value) {
    _bytePageNFC = value;
    prefs.setString('ff_bytePageNFC', value);
  }

  String _suppNdefNFC = '';
  String get suppNdefNFC => _suppNdefNFC;
  set suppNdefNFC(String value) {
    _suppNdefNFC = value;
    prefs.setString('ff_suppNdefNFC', value);
  }

  String _writingNdefNFC = '';
  String get writingNdefNFC => _writingNdefNFC;
  set writingNdefNFC(String value) {
    _writingNdefNFC = value;
    prefs.setString('ff_writingNdefNFC', value);
  }

  String _recordTipoNFC = '';
  String get recordTipoNFC => _recordTipoNFC;
  set recordTipoNFC(String value) {
    _recordTipoNFC = value;
    prefs.setString('ff_recordTipoNFC', value);
  }

  String _recordTamano = '';
  String get recordTamano => _recordTamano;
  set recordTamano(String value) {
    _recordTamano = value;
    prefs.setString('ff_recordTamano', value);
  }

  String _recordContenidoNFC = '';
  String get recordContenidoNFC => _recordContenidoNFC;
  set recordContenidoNFC(String value) {
    _recordContenidoNFC = value;
    prefs.setString('ff_recordContenidoNFC', value);
  }

  String _contenidoEscritoNFC = '';
  String get contenidoEscritoNFC => _contenidoEscritoNFC;
  set contenidoEscritoNFC(String value) {
    _contenidoEscritoNFC = value;
    prefs.setString('ff_contenidoEscritoNFC', value);
  }

  String _escrituraPagina7 = '';
  String get escrituraPagina7 => _escrituraPagina7;
  set escrituraPagina7(String value) {
    _escrituraPagina7 = value;
    prefs.setString('ff_escrituraPagina7', value);
  }

  String _contenidoHexNFC = '';
  String get contenidoHexNFC => _contenidoHexNFC;
  set contenidoHexNFC(String value) {
    _contenidoHexNFC = value;
    prefs.setString('ff_contenidoHexNFC', value);
  }

  String _contenidoDecimal = '';
  String get contenidoDecimal => _contenidoDecimal;
  set contenidoDecimal(String value) {
    _contenidoDecimal = value;
    prefs.setString('ff_contenidoDecimal', value);
  }

  String _tagWrite = '';
  String get tagWrite => _tagWrite;
  set tagWrite(String value) {
    _tagWrite = value;
    prefs.setString('ff_tagWrite', value);
  }

  bool _reiniciarLecturaNFC = false;
  bool get reiniciarLecturaNFC => _reiniciarLecturaNFC;
  set reiniciarLecturaNFC(bool value) {
    _reiniciarLecturaNFC = value;
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
