import 'dart:io';

// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nabelli_ecommerce/app/constants/constants.dart';
import 'package:nabelli_ecommerce/app/constants/firebase_messaging_service.dart';
import 'package:nabelli_ecommerce/app/constants/local_notifications_service.dart';
import 'package:nabelli_ecommerce/firebase_options.dart';

import 'package:nabelli_ecommerce/app/data/services/fcm_service.dart';

import 'app/constants/utils.dart';
import 'app/modules/auth/views/connection_check_view.dart';
import 'app/modules/home/controllers/color_controller.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  await GetStorage.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Send FCM Token to Server
  await FCMService().sendFcmToken();

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(localNotificationsService: localNotificationsService);
  await FirebaseMessaging.instance.subscribeToTopic('EVENT');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ColorController colorController = Get.put(ColorController());
  final storage = GetStorage();

  @override
  void initState() {
    colorController.returnMainColor();
    changeColor();
    super.initState();
  }

  dynamic changeColor() async {
    final a = await storage.read('mainColor');
    if (a != null) {
      final String a = await storage.read('mainColor').toString();
      colorController.findMainColor.value = int.parse(a.toString());
      colorController.getMainColor();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alybaba',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: gilroyRegular,
        colorSchemeSeed: colorController.mainColor,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          scrolledUnderElevation: 0,
          backgroundColor: colorController.mainColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light, // For older iOS versions
          ),
          titleTextStyle: const TextStyle(color: Colors.black, fontFamily: gilroySemiBold, fontSize: 20),
          elevation: 0,
        ),
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent.withOpacity(0)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      fallbackLocale: const Locale('tm'),
      locale: storage.read('langCode') != null
          ? Locale(storage.read('langCode'))
          : const Locale(
              'tm',
            ),
      translations: MyTranslations(),
      defaultTransition: Transition.fade,
      home: const ConnectionCheckView(),
    );
  }
}
