import 'package:find_them/core/routes/app_router.dart';
import 'package:find_them/data/services/firebase_service.dart';
import 'package:find_them/data/services/notification_service.dart';
import 'package:find_them/data/services/auth_service.dart';
import 'package:find_them/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('Background message received: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Core first
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Only initialize basic notification service (no FCM yet)
  await _initializeBasicServices();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

Future<void> _initializeBasicServices() async {
  try {
    // Only initialize basic notification service
    // FCM will be initialized after successful login/signup
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    print('✅ Basic services initialized (FCM will initialize after auth)');
  } catch (e) {
    print('❌ Error initializing basic services: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isDarkMode = false;
  Locale _locale = const Locale('en');
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationService = NotificationService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // Only refresh if service is fully initialized (after auth)
        if (_notificationService.isFullyInitialized) {
          _notificationService.refreshNotifications();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Them',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
      builder: (context, child) {
        return Directionality(
          textDirection:
              _locale.languageCode == 'ar'
                  ? TextDirection.ltr
                  : TextDirection.ltr,
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      onGenerateRoute:
          (settings) =>
              AppRouter.generateRoute(settings, toggleTheme, changeLanguage),
    );
  }
}