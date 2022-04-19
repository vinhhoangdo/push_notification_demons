import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';

import 'model/push_notification_model.dart';
import 'ui/notifcation_badge.dart';

void main() {
  runApp(const MyApp());
}

/// Handling background notifications
Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.messageId}');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Notification Demo',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: const MyHomePage(title: 'Flutter Notification Demo'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int _totalNotification;
  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;

  void registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();
    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;
    // 3. On iOS, this helps to take the user permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    // Handling background notifications
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );

        setState(() {
          _notificationInfo = notification;
          _totalNotification++;
        });
        if (_notificationInfo != null) {
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotification: _totalNotification),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.blue.shade700,
            duration: const Duration(seconds: 5),
          );
        }
      });
    } else {
      log('User declined or has not accepted permission');
    }
  }

  void checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );

      setState(() {
        _notificationInfo = notification;
        _totalNotification++;
      });
    }
  }

  @override
  void initState() {
    _totalNotification = 0;
    checkForInitialMessage();
    registerNotification();

    // For handling notification when the app is in background
    // not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotification++;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notify'),
          systemOverlayStyle:
              const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'App for capturing Firebase Push Notifications',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            const SizedBox(height: 10),
            NotificationBadge(totalNotification: _totalNotification),
            _notificationInfo != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Title: ${_notificationInfo!.dataTitle ?? _notificationInfo!.title}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Message: ${_notificationInfo!.dataBody ?? _notificationInfo!.body}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ));
  }
}
