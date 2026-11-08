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
import 'package:nabelli_ecommerce/global_safe_area_wrapper.dart';

import 'app/constants/utils.dart';
import 'app/modules/auth/views/connection_check_view.dart';
import 'app/modules/home/controllers/color_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light, systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark, systemNavigationBarContrastEnforced: false));
  await GetStorage.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(localNotificationsService: localNotificationsService);
  try {
    await FirebaseMessaging.instance.subscribeToTopic('EVENT');
    print('✅ [FCM] "EVENT" topic-ine subscribe edildi.');

  } catch (e) {
    print('❌ [FCM] "EVENT" topic-ine subscribe edilemedi: $e');
  }
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
      locale: storage.read('langCode') != null ? Locale(storage.read('langCode')) : const Locale('tm'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
      translations: MyTranslations(),
      defaultTransition: Transition.fade,
      home: GlobalSafeAreaWrapper(child: const ConnectionCheckView()),
    );
  }
}
