// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tzData;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   /// Initialisation des notifications + timezone
//   Future<void> init() async {
//     tzData.initializeTimeZones();

//     const AndroidInitializationSettings androidInit =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidInit,
//     );

//     await _plugin.initialize(initSettings);
//   }

//   /// Planifier une notification à une heure précise
//   Future<void> scheduleNotification({
//   required int id,
//   required String title,
//   required String body,
//   required DateTime scheduledDate,
// }) async {
//   await _plugin.zonedSchedule(
//     id,
//     title,
//     body,
//     tz.TZDateTime.from(scheduledDate, tz.local),
//     const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'medication_channel_id',
//         'Rappels de médicaments',
//         importance: Importance.max,
//         priority: Priority.high,
//       ),
//     ),
//     androidAllowWhileIdle: true,
//     uiLocalNotificationDateInterpretation:
//         UILocalNotificationDateInterpretation.absoluteTime,
//     matchDateTimeComponents: DateTimeComponents.time,
//   );
// }


//   /// Annuler une notification par ID
//   Future<void> cancelById(int id) async {
//     await _plugin.cancel(id);
//   }

//   /// Annuler toutes les notifications
//   Future<void> cancelAll() async {
//     await _plugin.cancelAll();
//   }
// }
