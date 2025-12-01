import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ColorService {
  static ColorService? _instance;
  static ColorService get instance => _instance ??= ColorService._();
  
  ColorService._();

  Map<String, Color>? _colors;

  Future<void> loadColors() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/colors.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _colors = {
        'primary': _hexToColor(jsonData['primary']),
        'primaryDark': _hexToColor(jsonData['primaryDark']),
        'secondary': _hexToColor(jsonData['secondary']),
        'background': _hexToColor(jsonData['background']),
        'surface': _hexToColor(jsonData['surface']),
        'error': _hexToColor(jsonData['error']),
        'success': _hexToColor(jsonData['success']),
        'warning': _hexToColor(jsonData['warning']),
        'text': _hexToColor(jsonData['text']),
        'textSecondary': _hexToColor(jsonData['textSecondary']),
      };
    } catch (e) {
      // Couleurs par défaut en cas d'erreur
      _colors = {
        'primary': const Color(0xFF7ED957),
        'primaryDark': const Color(0xFF5CB83A),
        'secondary': const Color(0xFF00A5E5),
        'background': const Color(0xFFF8F9FA),
        'surface': Colors.white,
        'error': const Color(0xFFDC3545),
        'success': const Color(0xFF28A745),
        'warning': const Color(0xFFFFC107),
        'text': const Color(0xFF2C3E50),
        'textSecondary': const Color(0xFF6C757D),
      };
    }
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Color getColor(String name) {
    return _colors?[name] ?? Colors.grey;
  }
}

