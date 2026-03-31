import 'package:flutter/material.dart';

class SportIconMapper {
  static const List<Map<String, dynamic>> iconOptions = [
    {'key': 'soccer', 'icon': Icons.sports_soccer, 'label': 'Bóng đá'},
    {'key': 'badminton', 'icon': Icons.sports_tennis, 'label': 'Cầu lông'},
    {'key': 'basketball', 'icon': Icons.sports_basketball, 'label': 'Bóng rổ'},
    {'key': 'volleyball', 'icon': Icons.sports_volleyball, 'label': 'Bóng chuyền'},
    {'key': 'swimming', 'icon': Icons.pool, 'label': 'Bơi lội'},
    {'key': 'gym', 'icon': Icons.fitness_center, 'label': 'Gym'},
    {'key': 'running', 'icon': Icons.directions_run, 'label': 'Chạy bộ'},
    {'key': 'pickleball', 'icon': Icons.sports_handball, 'label': 'Pickleball'},
    {'key': 'golf', 'icon': Icons.sports_golf, 'label': 'Golf'},
  ];

  static IconData iconFromKey(String key) {
    for (final option in iconOptions) {
      if (option['key'] == key) {
        return option['icon'] as IconData;
      }
    }
    return Icons.sports;
  }

  static String labelFromKey(String key) {
    for (final option in iconOptions) {
      if (option['key'] == key) {
        return option['label'] as String;
      }
    }
    return 'Khác';
  }

  static int indexFromKey(String key) {
    for (int i = 0; i < iconOptions.length; i++) {
      if (iconOptions[i]['key'] == key) {
        return i;
      }
    }
    return 0;
  }
}
