import 'package:flutter/services.dart';

class HapticService {
  static bool _enabled = true;

  static bool get isEnabled => _enabled;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  static void light() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  static void medium() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  static void selection() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  static void rigid() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  static void soft() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }
}
