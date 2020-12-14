import 'package:flutter/material.dart';
import 'package:vitaminav/common/local_preferences.dart';

/// Provides specific local preferences for the VitaminaV app to descending
/// widgets
class VitaminaVPreferences extends LocalPreferences {
  final double defaultFontSize;
  VitaminaVPreferences({@required this.defaultFontSize, @required Widget child})
      : super(
          defaultPrefs: {'fontSize': defaultFontSize},
          child: child,
        );

  static VitaminaVPreferences of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<VitaminaVPreferences>();
  }

  /// Global font size for the reader screen
  double get fontSize => get('fontSize');
  set fontSize(double value) => set('fontSize', value);

  /// Hour of the daily notification
  int get notificationHour => get('notificationHour');
  set notificationHour(int value) => set('notificationHour', value);

  /// Minute of the daily notification
  int get notificationMinute => get('notificationMinute');
  set notificationMinute(int value) => set('notificationMinute', value);

  /// Returns the last read index for a specific table of contents identified by
  /// a `prefix`
  int getSavedIndex(String prefix) => get('${prefix}_saved_index');

  /// Sets the last read index for a specific table of contents identified by a
  /// `prefix`
  void setSavedIndex(String prefix, int value) =>
      set('${prefix}_saved_index', value);

  /// Returns the scroll offset for the last read page for a specific table of
  /// contents identified by a `prefix`
  double getSavedScroll(String prefix) => get('${prefix}_saved_scroll');

  /// Sets the scroll offset for the last read page for a specific table of
  /// contents identified by a `prefix`
  void setSavedScroll(String prefix, double value) =>
      set('${prefix}_saved_scroll', value);
}
