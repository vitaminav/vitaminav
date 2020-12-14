import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides the local shared preferences synchronously to all the descending
/// widgets.
///
/// Preferences are read and written as simple key-values pairs, where
/// the key is a generic [String] and the value has any of the following:
/// String, int, double, bool.
///
/// For a more robust implementation you can extend this class and add
/// getters and setters for each shared preferences record, as needed by your
/// application.
class LocalPreferences extends InheritedNotifier<PreferencesNotifier> {
  final Map<String, dynamic> defaultPrefs;
  final String prefix;

  /// Creates a widget that provides the local shared preferences synchronously
  /// to all the descending widgets, rebuilding them when any of the preferences
  /// is changed.
  ///
  /// A `defaultPrefs` map can be provided to set the default shared
  /// preferences. A `prefix` string can also be provided, to be used for all
  /// the keys, for example to keep separated different contexts of your
  /// application.
  ///
  /// The [LocalPreferences] widget can be accessed from any child as an
  /// [InheritedWidget], with the method `Preferences.of(context)`.
  ///
  /// The shared preferences will be loaded asynchronously from storage only
  /// once, when the widget is created. Any modification requested from the
  /// children will be notified immediately to all the descendants, and
  /// automatically consolidated to storage asynchronously.
  @override
  LocalPreferences({
    Key key,
    @required Widget child,
    this.defaultPrefs,
    this.prefix = '',
  }) : super(
          key: key,
          notifier: PreferencesNotifier(),
          child: child,
        ) {
    defaultPrefs.forEach((key, value) {
      if (!(value is String ||
          value is int ||
          value is double ||
          value is bool)) {
        throw Exception(
            "Invalid default preferences data structure. The value provided for key '$key' has type '${value.runtimeType}'. Only 'String', 'int', 'double' and 'bool' are allowed.");
      }
    });
  }

  static LocalPreferences of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocalPreferences>();
  }

  /// Gets a shared preferences value given its `key`.
  ///
  /// Returns default value indicated in `defaultPrefs` if the actual value
  /// doesn't exist or its runtime type value differs from the default one.
  ///
  /// If the key doesn't exists and its default value is not specified, returns
  /// `null`.
  dynamic get(String key) {
    final contextKey = '$prefix:$key';
    if (defaultPrefs.containsKey(key)) {
      if (!notifier.value.containsKey(contextKey) ||
          notifier.value[contextKey].runtimeType !=
              defaultPrefs[key].runtimeType) {
        return defaultPrefs[key];
      } else {
        return notifier.value[contextKey];
      }
    } else {
      if (notifier.value.containsKey(contextKey)) {
        return notifier.value[contextKey];
      } else {
        return null;
      }
    }
  }

  /// Sets a shared preferences record given a `key` and `value`.
  ///
  /// If a default value is available for the given key, checks that the value
  /// type and the default type are the same, and throws an exception otherwise.
  /// This ensures that any key will always correspond to the same type, as
  /// specified in `defaultPrefs`.
  void set(String key, dynamic value) {
    final contextKey = '$prefix:$key';
    // Check if the value has an acceptable type
    if (!(value is String ||
        value is int ||
        value is double ||
        value is bool ||
        value == null)) {
      throw Exception(
          "Invalid value type '${value.runtimeType}'. Only 'String', 'int', 'double' and 'bool' are allowed, or 'Null' to unset.");
    }

    // Check type consistency with defaults
    if (defaultPrefs.containsKey(contextKey) &&
        defaultPrefs[contextKey].runtimeType != value.runtimeType) {
      throw Exception(
          "The shared preferences value '$contextKey' cannot be set to a value of type '{$value.runtimeType}', as its default value has type '${defaultPrefs[contextKey].runtimeType}'.");
    }

    // Update value notifier
    final newValue = Map<String, dynamic>.from(notifier.value);
    newValue[contextKey] = value;
    notifier.value = newValue;
  }
}

/// A [ValueNotifier] that holds the current value of the shared preferences
/// and handles its asynchronous reading and writing.
class PreferencesNotifier extends ValueNotifier<Map<String, dynamic>> {
  Future<SharedPreferences> get _prefsFuture => SharedPreferences.getInstance();

  PreferencesNotifier() : super({}) {
    refreshValue();
  }

  void refreshValue() {
    _prefsFuture.then((prefs) {
      final newValue = Map.fromEntries(
          prefs.getKeys().map((e) => MapEntry(e, prefs.get(e))));

      value = newValue;
    });
  }

  // Override the value setter to provide transparent consolidation of the
  // preferences records
  @override
  set value(Map<String, dynamic> value) {
    super.value = value;

    // Update the preferences
    _prefsFuture.then((prefs) {
      value.forEach((key, value) {
        if (value is int) {
          prefs.setInt(key, value);
        } else if (value is bool) {
          prefs.setBool(key, value);
        } else if (value is String) {
          prefs.setString(key, value);
        } else if (value is double) {
          prefs.setDouble(key, value);
        }
      });
    });
  }
}
