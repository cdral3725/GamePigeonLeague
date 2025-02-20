import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  _PlayerProfileScreenState createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  late Timer _timer;
  DateTime _nextDeadline = DateTime.now();
  Duration _timeRemaining = Duration(days: 7);
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _setupNotifications();
    _fetchDeadline();
    _startCountdown();
  }

  void _setupNotifications() async {
    tzdata.initializeTimeZones();
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings settings = InitializationSettings(android: androidInitSettings);
    await _notificationsPlugin.initialize(settings);
  }

  void _fetchDeadline() async {
    FirebaseFirestore.instance.collection('config').doc('deadline').get().then((snapshot) {
      if (snapshot.exists) {
        Timestamp timestamp = snapshot['date'];
        setState(() {
          _nextDeadline = timestamp.toDate();
          _timeRemaining = _nextDeadline.difference(DateTime.now());
        });

        _scheduleNotification(_nextDeadline);
      }
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        DateTime now = DateTime.now();
        if (_nextDeadline.isBefore(now)) {
          _fetchDeadline(); // Refresh deadline when it passes
        } else {
          _timeRemaining = _nextDeadline.difference(now);
        }
      });
    });
  }

  void _scheduleNotification(DateTime deadline) async {
    await _notificationsPlugin.zonedSchedule(
     0,
      "Game Deadline Approaching!",
      "Don't forget to submit your game by ${deadline.toLocal()}",
      tz.TZDateTime.from(deadline.subtract(Duration(hours: 3)), tz.local), // 3 hours before
      const NotificationDetails(
        android: AndroidNotificationDetails(
         "deadline_channel",
          "Game Deadline",
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ ADD THIS LINE
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime =
        "${_timeRemaining.inDays}d ${_timeRemaining.inHours % 24}h ${_timeRemaining.inMinutes % 60}m";

    double progress = _timeRemaining.inSeconds / (7 * 24 * 60 * 60);

    return Scaffold(
      appBar: AppBar(title: Text("Player Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Next Game Deadline:", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(value: progress, minHeight: 10, color: Colors.red),
            SizedBox(height: 20),
            Text("Deadline: ${_nextDeadline.toLocal()}"),
          ],
        ),
      ),
    );
  }
}

