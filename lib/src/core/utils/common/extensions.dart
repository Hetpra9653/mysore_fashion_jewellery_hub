import 'package:flutter/material.dart';

extension SizedBoxExtension on num {
  SizedBox get hSizedBox {
    return SizedBox(height: toDouble());
  }

  SizedBox get wSizedBox {
    return SizedBox(width: toDouble());
  }
}


extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return trim().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return '';
      return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
    }).join(' ');
  }
}
