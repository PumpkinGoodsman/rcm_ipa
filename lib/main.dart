

import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:ACM/services/helper/notification_services.dart';
import 'package:ACM/views/Dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Splashscreen/Splash.dart';
import 'firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';


void main() async{

  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggin') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

@pragma('vm:entrty point')
Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async
{
  await Firebase.initializeApp();
  print(message.notification!.title.toString());
}


class MyApp extends StatefulWidget {



  @override
  final bool isLoggedIn;
  MyApp({required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void initState() {
    super.initState();
    NotificationServices().setupInteractMessage(context as BuildContext);
    NotificationServices().firebaseInit(context as BuildContext);


    FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.body}');
      // Handle your message here
    });
    _requestStoragePermission();
  }
  Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.request();

    if (status.isGranted) {
      print('permission is granted');

    } else if (status.isDenied) {

    } else if (status.isPermanentlyDenied) {
      // Open app settings if permission is permanently denied
      await openAppSettings();
    }
  }

  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      home: widget.isLoggedIn ?  Dashboard() : SplashScreen(), // Set SplashScreen as the home screen
    );
  }
}
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context)
  { return super.createHttpClient(context)
    ..badCertificateCallback =
      (X509Certificate cert, String host, int port) => true; }
}