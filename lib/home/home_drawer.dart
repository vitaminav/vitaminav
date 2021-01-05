import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:share/share.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import '../common/constants.dart';
import '../common/vitaminav_preferences.dart';
import '../main.dart';
import 'credits_screen.dart';
import 'time_field.dart';

/// The drawer of the home screen
class HomeDrawer extends StatelessWidget {
  // A global key for the share button is needed for correct display on iPads
  final GlobalKey shareButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Image.asset(
            'assets/logo.png',
            height: 70,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Text(
                  'Ego sum via, veritas, vita.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(
                  height: 20,
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText1,
                    children: [
                      TextSpan(
                          text: 'VitaminaV',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                          text:
                              ', nota anche come Vangelo, è necessaria per la salute del tuo spirito e l’equilibrio del tuo cuore.'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Si tratta di una molecola richiesta dell\'organismo soltanto in piccole quantità, ma necessaria per condurti a conoscere, frequentare e vivere di Colui che è la Via, la Verità e la Vita.',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Crediti'),
            onTap: () => openCredits(context),
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Lascia una recensione'),
            onTap: _leaveAReview,
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Condividi'),
            key: shareButtonKey,
            onTap: () => share(context),
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Feedback'),
            onTap: _sendFeedback,
          ),
          Divider(),
          _notificationEnabled(context)
              ? ListTile(
                  leading: Icon(Icons.notifications_active),
                  title: Text('Ricordami la vitamina V'),
                  subtitle: Text(
                      'Hai attivato i promemoria. Riceverai una notifica ogni giorno alle ${_notificationTime(context).format(context)}. Tocca per disattivare.'),
                  onTap: () => _editNotificationDialog(context: context),
                )
              : ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Ricordami la vitamina V'),
                  subtitle: Text(
                      '10 minuti al giorno sono necessari per la salute del tuo spirito e l’equilibrio del tuo cuore. Tocca per attivare le notifiche!'),
                  onTap: () => _enableNotificationDialog(context),
                ),
          Divider(),
          SizedBox(height: 20),
          Text(
            'ⓒ VitaminaV 2020',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void openCredits(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreditsScreen()),
    );
  }

  void share(BuildContext context) {
    final RenderBox box = shareButtonKey.currentContext.findRenderObject();
    Share.share('Scarica VitaminaV! ${Constants.storeLink}',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  void _leaveAReview() {
    launch(Constants.storeLink);
  }

  void _sendFeedback() {
    launch('mailto:${Constants.feedbackEmail}');
  }

  Future<void> _disableNotification(BuildContext context) async {
    await flutterLocalNotificationsPlugin.cancel(0);
    VitaminaVPreferences.of(context).notificationHour = null;
    VitaminaVPreferences.of(context).notificationMinute = null;
  }

  void _editNotificationDialog({@required BuildContext context}) {
    final previousTime = _notificationTime(context);
    final timeFieldController = TimeFieldController(initialTime: previousTime);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('Modifica la notifica'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                  'Scegli un nuovo orario e tocca "conferma" oppure tocca "disattiva" se non desideri più ricevere la notifica.'),
              TimeField(controller: timeFieldController),
            ],
          ),
        ),
        actions: [
          FlatButton(
            child: Text('Annulla'),
            onPressed: () => Navigator.of(dialogContext).pop(null),
          ),
          FlatButton(
            child: Text('Disattiva'),
            onPressed: () {
              _disableNotification(context);
              Navigator.of(dialogContext).pop();
            },
          ),
          ValueListenableBuilder<TimeOfDay>(
            valueListenable: timeFieldController,
            builder: (BuildContext builderContext, TimeOfDay validated,
                    Widget widget) =>
                FlatButton(
              child: Text('Conferma'),
              onPressed: timeFieldController.value != null
                  ? () {
                      _setNotification(context, timeFieldController.value);
                      Navigator.of(dialogContext).pop();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enableNotificationDialog(BuildContext context) async {
    final previousTime = _notificationTime(context);
    final timeFieldController = TimeFieldController(initialTime: previousTime);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('A che ora vuoi ricevere la notifica quotidiana?'),
        content: SingleChildScrollView(
          child: TimeField(controller: timeFieldController),
        ),
        actions: [
          FlatButton(
            child: Text('Annulla'),
            onPressed: () => Navigator.of(dialogContext).pop(null),
          ),
          ValueListenableBuilder<TimeOfDay>(
            valueListenable: timeFieldController,
            builder: (BuildContext builderContext, TimeOfDay validated,
                    Widget widget) =>
                FlatButton(
              child: Text('Conferma'),
              onPressed: timeFieldController.value != null
                  ? () {
                      _setNotification(context, timeFieldController.value);
                      Navigator.of(dialogContext).pop();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  _setNotification(BuildContext context, TimeOfDay time) async {
    var permission =
        await NotificationPermissions.getNotificationPermissionStatus() ==
            PermissionStatus.granted;
    if (!permission) {
      permission =
          await NotificationPermissions.requestNotificationPermissions() ==
              PermissionStatus.granted;
    }

    if (!permission) {
      print('Notifications rejected.');
      return false;
    }

    // Initialize time zones and set the current one
    tz.initializeTimeZones();
    tz.setLocalLocation(
        tz.getLocation(await FlutterNativeTimezone.getLocalTimezone()));

    // Schedule first notification for today or tomorrow (if the time for today
    // is already passed)
    final now = DateTime.now();
    var scheduledDate = tz.TZDateTime.local(
        now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Prendi la vitamina V!',
      'Tocca questa notifica per aprire l\'app.',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'vitaminav_daily_remainder',
          'Ricordati di prendere la vitamina V',
          'Notifica quotidiana',
          enableVibration: true,
          importance: Importance.max,
          playSound: true,
          enableLights: true,
          styleInformation: BigTextStyleInformation('Ricordati la vitamina V'),
          priority: Priority.max,
          visibility: NotificationVisibility.public,
          category: 'CATEGORY_EVENT',
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Update time in shared preferences
    VitaminaVPreferences.of(context).notificationHour = time.hour;
    VitaminaVPreferences.of(context).notificationMinute = time.minute;

    return true;
  }

  TimeOfDay _notificationTime(BuildContext context) {
    final hour = VitaminaVPreferences.of(context).notificationHour;
    final minute = VitaminaVPreferences.of(context).notificationMinute;

    if (hour == null || minute == null) {
      return null;
    } else {
      return TimeOfDay(hour: hour, minute: minute);
    }
  }

  bool _notificationEnabled(BuildContext context) {
    return !(_notificationTime(context) == null);
  }
}
