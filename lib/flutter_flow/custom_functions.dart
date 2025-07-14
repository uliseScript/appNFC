import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';

String textToHex8(String input) {
  final bytes = utf8.encode(input.padRight(4).substring(0, 4));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
