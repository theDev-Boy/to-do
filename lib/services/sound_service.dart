// Sound service - system sounds used instead of audioplayers
import 'package:flutter/services.dart';

class SoundService {
  static bool _enabled = true;

  static bool get isEnabled => _enabled;

  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  static Future<void> playTaskComplete() async {
    if (!_enabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> playTaskDelete() async {
    if (!_enabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> playOverdueAlert() async {
    if (!_enabled) return;
    await SystemSound.play(SystemSoundType.alert);
  }

  static Future<void> playReminder() async {
    if (!_enabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> playStreakMilestone() async {
    if (!_enabled) return;
    await SystemSound.play(SystemSoundType.alert);
  }

  static Future<void> playFocusEnd() async {
    if (!_enabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> playBulkAction() async {
    if (!_enabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> playUndo() async {
    if (!_enabled) return;
    await SystemSound.play(SystemSoundType.click);
  }
}
