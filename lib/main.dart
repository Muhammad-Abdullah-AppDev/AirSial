import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:airsial_app/theme/theme_manager.dart';
import 'package:airsial_app/theme/themes.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sizer/sizer.dart';

import 'package:airsial_app/Pages/home_page.dart';
import 'package:airsial_app/Pages/login_page.dart';
import 'package:airsial_app/utils/routes.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'controllor/zoom_controller.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); // Initialize here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
        appId: '1:270261376319:android:d776b21d944a63e3e36f8a',
        messagingSenderId: '270261376319',
        projectId: 'sialapp',
        storageBucket: 'sialapp.appspot.com',
        apiKey: 'AIzaSyDLHc2HCNuaiLD62p1YMAN5E6pZfvyS2rw',
      )
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //await NotificationService().initNotification();
  await initAppFunction();

  runApp(Sizer(
      builder: (context, orientation, screenType) {
    return MyApp();
  }));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  //await Firebase.initializeApp();
  debugPrint(message.notification!.title.toString());
  debugPrint(message.notification!.body.toString());
  debugPrint(message.data.toString());
}

Future<void> initAppFunction() async {
  try {
    await GetStorage.init();

    Get.put(ZoomController());
    tz.initializeTimeZones();

    //await NotificationService().initNotification();

    bool isFirstTime = GetStorage().read('isFirstTime') ?? true;
    debugPrint('isFirstTime: $isFirstTime');

    if (isFirstTime) {
      debugPrint('Clearing stored data...');
      GetStorage().remove('cnic');
      GetStorage().remove('folio');
      GetStorage().remove('shname');
      GetStorage().remove('profileImage');
      debugPrint('Stored data cleared.');

      GetStorage().write('isFirstTime', false);
    } else {
      debugPrint('Stored data already cleared.');
    }
  } catch (e) {
    debugPrint('Initialization Error: $e');
    // Handle the initialization error here
  }
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    final cnic = GetStorage().read('cnic');
    final folio = GetStorage().read('folio');
    final name = GetStorage().read('shname');

    debugPrint('CNIC: $cnic');
    debugPrint('Folio: $folio');
    debugPrint('name: $name');

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeManager().theme,
      initialRoute: cnic != null && folio != null
          ? MyRoutes.homeRout
          : MyRoutes.LoginRout, // Change to login route if not logged in
      routes: {
        "/": (context) => LoginPage(),
        MyRoutes.homeRout: (context) => HomePage(),
        MyRoutes.LoginRout: (context) => LoginPage(),
      },
    );
  }
}