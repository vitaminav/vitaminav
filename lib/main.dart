import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'common/extensions.dart';
import 'common/vitaminav_preferences.dart';
import 'home/home_screen.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Local notifications plugin initialization
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_notification_icon');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );
  final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
  );

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State {
  @override
  Widget build(BuildContext context) {
    final primarySwatch = Color(0xFF004C9F).toMaterialColor();
    return VitaminaVPreferences(
      defaultFontSize: 14.0,
      child: MaterialApp(
        title: 'VitaminaV',
        theme: ThemeData(
          primarySwatch: primarySwatch,
          accentColor: primarySwatch,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(brightness: Brightness.dark),
        ),
        home: HomeScreen(),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.grey[850],
          accentColor: Colors.white,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
