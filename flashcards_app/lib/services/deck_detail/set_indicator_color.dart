import 'package:flutter/material.dart';

setIndicatorColour(int level) {
  if (level == 2) {
    Color color = const Color(0x00000000);
    return color;
  } else if (level > 0 && level <= 2) {
    Color color = Colors.red;
    return color;
  } else if (level > 2 && level <= 5) {
    Color color = Colors.orange;
    return color;
  } else if (level > 5 && level <= 7) {
    Color color = Colors.yellow;
    return color;
  } else if (level > 7 && level <= 10) {
    Color color = Colors.lightGreen;
    return color;
  } else if (level > 7 && level <= 10) {
    Color color = Colors.green;
    return color;
  }
}
