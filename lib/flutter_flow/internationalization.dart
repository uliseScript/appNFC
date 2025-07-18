import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['en', 'es'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? esText = '',
  }) =>
      [enText, esText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return FFLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // HomePage
  {
    '64lxfx8z': {
      'en': 'Logout',
      'es': 'Cerrar sesión',
    },
    'qgn1ji69': {
      'en': 'NFC',
      'es': 'NFC',
    },
    '4g4w597u': {
      'en': 'Serial Number.',
      'es': 'Número de serie.',
    },
    'rgdomrj0': {
      'en': 'Type of tag.',
      'es': 'Tipo de etiqueta.',
    },
    '76ykg4h8': {
      'en': 'Pages.',
      'es': 'Páginas.',
    },
    'wyynofja': {
      'en': 'Pages: ',
      'es': 'Páginas:',
    },
    'fs2d7f11': {
      'en': 'Capacity: ',
      'es': 'Capacidad:',
    },
    'ty6gxcdj': {
      'en': 'Information NDEF.',
      'es': 'Información NDEF.',
    },
    't3krjerq': {
      'en': 'Maximum capacity:  ',
      'es': 'Capacidad máxima:',
    },
    'qg824xfx': {
      'en': 'Writing:',
      'es': 'Escritura:',
    },
    'akg7xk8n': {
      'en': 'Records found.',
      'es': 'Registros encontrados.',
    },
    '72f49g22': {
      'en': 'Information not available.',
      'es': 'Información no disponible.',
    },
    'zq64w7u7': {
      'en': 'Content: ',
      'es': 'Contenido:',
    },
    '79nawp7h': {
      'en': 'Write.',
      'es': 'Escribir.',
    },
    '3pk0hyiu': {
      'en': 'Place the text you want to save in your Tag.',
      'es': 'Coloca el texto que deseas guardar en tu Tag.',
    },
    'tqlg9t52': {
      'en': 'Approximate a Tag to display data.',
      'es': 'Aproximar una etiqueta para mostrar datos.',
    },
    'l6idxc0m': {
      'en': 'Home',
      'es': '',
    },
  },
  // Login
  {
    'vmxr6e8a': {
      'en': 'Get Started',
      'es': 'Empezar',
    },
    'tsm7rsxx': {
      'en': 'Let\'s get started by filling out the form below.',
      'es': 'Comencemos rellenando el formulario que aparece a continuación.',
    },
    'eewu9zkt': {
      'en': 'User Name',
      'es': 'Nombre de usuario',
    },
    'k06ymfxg': {
      'en': 'Password',
      'es': 'Contraseña',
    },
    'wxuxy0ik': {
      'en': 'Login',
      'es': 'Acceso',
    },
    'n1vpq70j': {
      'en': 'Internet Error',
      'es': 'Error de Internet',
    },
    'd5y4nna0': {
      'en': 'No connection, check your network',
      'es': 'Sin conexión, revisa tu red',
    },
    'f5yuijrc': {
      'en': 'Error',
      'es': 'Error',
    },
    '8bn0e5y5': {
      'en': 'API Error',
      'es': 'Error de API',
    },
    '366r6des': {
      'en': 'Success.',
      'es': 'Éxito.',
    },
    'wjgzxg1o': {
      'en': 'Credentials entered correctly.',
      'es': 'Credenciales ingresadas correctamente.',
    },
    'mll1514q': {
      'en': 'User not found.',
      'es': 'Usuario no encontrado.',
    },
    'fogn7sjp': {
      'en': 'Please verify your credentials and try again.',
      'es': 'Verifique sus credenciales y vuelva a intentarlo.',
    },
    '6gv3s5jz': {
      'en': 'Home',
      'es': '',
    },
  },
  // List10OrderHistory
  {
    'eazbilzm': {
      'en': 'Recent Orders',
      'es': '',
    },
    '9781jhro': {
      'en': 'Below are your most recent orders',
      'es': '',
    },
    'czpzx4xr': {
      'en': 'Order #: ',
      'es': '',
    },
    'l2f9qod2': {
      'en': '429242424',
      'es': '',
    },
    'az5s0l3a': {
      'en': 'Mon. July 3rd',
      'es': '',
    },
    'rfltj0l8': {
      'en': '2.5 lbs',
      'es': '',
    },
    'wpg66zrj': {
      'en': '\$1.50',
      'es': '',
    },
    'ci9cgop4': {
      'en': 'Shipped',
      'es': '',
    },
    'u9heprh0': {
      'en': 'Order #: ',
      'es': '',
    },
    'l79lsxxn': {
      'en': '429242424',
      'es': '',
    },
    '5s0wz8fz': {
      'en': 'Mon. July 3rd',
      'es': '',
    },
    '4jf06yw8': {
      'en': '2.5 lbs',
      'es': '',
    },
    'zocg7afu': {
      'en': '\$1.50',
      'es': '',
    },
    'p52itchf': {
      'en': 'Shipped',
      'es': '',
    },
    '3ruajvj1': {
      'en': 'Order #: ',
      'es': '',
    },
    'od3e57cf': {
      'en': '429242424',
      'es': '',
    },
    'rq6z8sex': {
      'en': 'Mon. July 3rd',
      'es': '',
    },
    'x9q9d681': {
      'en': '2.5 lbs',
      'es': '',
    },
    'fdm2mxcf': {
      'en': '\$1.50',
      'es': '',
    },
    'moov77oc': {
      'en': 'Accepted',
      'es': '',
    },
    'uy94cizb': {
      'en': 'Order #: ',
      'es': '',
    },
    '211t2780': {
      'en': '429242424',
      'es': '',
    },
    '8r8rt0ge': {
      'en': 'Mon. July 3rd',
      'es': '',
    },
    'pwtdh13w': {
      'en': '2.5 lbs',
      'es': '',
    },
    '6s3bpdum': {
      'en': '\$1.50',
      'es': '',
    },
    'xp7zwldq': {
      'en': 'Accepted',
      'es': '',
    },
    'fmhu3cpn': {
      'en': 'Home',
      'es': '',
    },
  },
  // MessageDialogError
  {
    'f6iynvip': {
      'en': 'OK',
      'es': 'DE ACUERDO',
    },
  },
  // MessageDialog
  {
    'dzdfi1mp': {
      'en': 'OK',
      'es': 'DE ACUERDO',
    },
  },
  // MessageDialogTag
  {
    'd62kvy7b': {
      'en': 'OK',
      'es': 'OK',
    },
  },
  // textComponent
  {
    '49k4umea': {
      'en': 'TextField',
      'es': '',
    },
    '0ltzshcv': {
      'en': 'OK',
      'es': 'OK',
    },
    'irc443s5': {
      'en': 'Approximate a Tag.',
      'es': 'Aproximar un Tag.',
    },
    '5ob8ybgu': {
      'en': 'Approximate a Tag to record data.',
      'es': 'Aproximar una etiqueta para registrar datos.',
    },
    'si2uvixq': {
      'en': 'Information.',
      'es': 'Información.',
    },
    'v5s07e7d': {
      'en': 'The data was recorded correctly.',
      'es': 'Los datos se registraron correctamente.',
    },
  },
  // Miscellaneous
  {
    'yrp1cq6n': {
      'en': '',
      'es': '',
    },
    'yl1wjntk': {
      'en': '',
      'es': '',
    },
    'w61522ju': {
      'en': '',
      'es': '',
    },
    'rilmulca': {
      'en': '',
      'es': '',
    },
    '0oe6uvfb': {
      'en': '',
      'es': '',
    },
    'z7u59fa3': {
      'en': '',
      'es': '',
    },
    'bv7h61s6': {
      'en': '',
      'es': '',
    },
    'qxag1n9u': {
      'en': '',
      'es': '',
    },
    'iz75itvb': {
      'en': '',
      'es': '',
    },
    'kx4h6fke': {
      'en': '',
      'es': '',
    },
    'zvvahz3h': {
      'en': '',
      'es': '',
    },
    'zgfujaon': {
      'en': '',
      'es': '',
    },
    'kl9tew41': {
      'en': '',
      'es': '',
    },
    'u2wue3a5': {
      'en': '',
      'es': '',
    },
    'i8r1zhlr': {
      'en': '',
      'es': '',
    },
    '3ukbl3mp': {
      'en': '',
      'es': '',
    },
    '8qm9mmao': {
      'en': '',
      'es': '',
    },
    'onomp67b': {
      'en': '',
      'es': '',
    },
    'qc4ntsp8': {
      'en': '',
      'es': '',
    },
    'ac4r7o60': {
      'en': '',
      'es': '',
    },
    'g9f5k5jz': {
      'en': '',
      'es': '',
    },
    'jot2z7sk': {
      'en': '',
      'es': '',
    },
    'cnoinrr3': {
      'en': '',
      'es': '',
    },
    'ijdqbnzh': {
      'en': '',
      'es': '',
    },
    'o8p3g084': {
      'en': '',
      'es': '',
    },
  },
].reduce((a, b) => a..addAll(b));
