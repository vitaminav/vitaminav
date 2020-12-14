import 'dart:math';

import 'package:flutter/material.dart';

// This file contains miscellaneous extensions that are used across different screens

extension ColorToMaterialColor on Color {
  /// Returns a [MaterialColor] from this [Color], introducting variations on lightness
  MaterialColor toMaterialColor() {
    final base = HSLColor.fromColor(this);

    final lightnessMap = {
      050: 1.8,
      100: 1.6,
      200: 1.4,
      300: 1.2,
      400: 1.0,
      500: 0.9,
      600: 0.8,
      700: 0.7,
      800: 0.6,
      900: 0.5,
    };

    return MaterialColor(
      this.value,
      lightnessMap.map<int, Color>(
        (key, multiplier) => MapEntry(
          key,
          base
              .withLightness(
                (base.lightness * multiplier).sat(
                  lower: 0,
                  upper: 1,
                ),
              )
              .toColor(),
        ),
      ),
    );
  }
}

extension Saturate on num {
  /// Returns this number saturated between given `upper` and `lower` bounds
  num sat({num upper, num lower}) {
    return min(upper ?? double.infinity, max(lower ?? -double.infinity, this));
  }
}

extension DateToItalianString on DateTime {
  /// Returns a localized string representation of this date for Italian
  String toItalianString() {
    final months = [
      'gennaio',
      'febbraio',
      'marzo',
      'aprile',
      'maggio',
      'giugno',
      'luglio',
      'agosto',
      'settembre',
      'ottobre',
      'novembre',
      'dicembre'
    ];
    return '$day ${months[month - 1]} $year';
  }
}

extension IntToRoman on int {
  /// Returns a roman numeric system representation of this number
  String get roman {
    final digits = {
      1000: 'M',
      900: 'CM',
      500: 'D',
      400: 'CD',
      100: 'C',
      90: 'XC',
      50: 'L',
      40: 'XL',
      10: 'X',
      9: 'IX',
      5: 'V',
      4: 'IV',
      1: 'I',
    };

    var result = '';
    var remain = this;

    while (remain > 0) {
      final value = digits.keys.firstWhere((value) => value <= remain);
      result += digits[value];
      remain -= value;
    }

    return result;
  }
}
