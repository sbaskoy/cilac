import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'view/ekipata/ekip_ata_state.dart';
import 'view/home/istatislik_state.dart';
import 'view/loginpage/login_view.dart';
import 'view/notification_state.dart';
import 'view/sikayetlist/sikayetlist_state.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

Future onSelectNotification(String payload) async {
  List<String> data = payload.split("|");
  showSimpleNotification(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              data[0],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              data[1],
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 4));
}

const AndroidNotificationChannel andChannle = AndroidNotificationChannel(
    'high_importance_channel', 'Hight Importance Notifications',
   );
// ignore: unnecessary_new
final FlutterLocalNotificationsPlugin plugins = new FlutterLocalNotificationsPlugin();

Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // BİLDİRİM AYARLARI
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  await plugins
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(andChannle);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    plugins.initialize(initializationSettings, onSelectNotification: (payload) {
       onSelectNotification(payload ?? '');
    });
    NoticationState.initNotification(context);
    return OverlaySupport.global(
      child: MultiProvider(
        // GLOBAL TANIMLAMALAR
        // BU 3 SINIFI TÜM EKRANLARDA KULLANMAMIZI SAGLAR
        providers: [
          Provider(create: (context) => new SikayetListState()),
          Provider(create: (context) => new EkipAtaState()),
          Provider(create: (context) => new IstatislikState()),
        ],
        child: MaterialApp(
          title:"ORYAZ CILAC",
          localizationsDelegates:const  [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales:const [
             Locale('tr', 'TR'),
          ],
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData.dark().copyWith(),
          themeMode: ThemeMode.light,
          home: LoginView(),
        ),
      ),
    );
  }
}
