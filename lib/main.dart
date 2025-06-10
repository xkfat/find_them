import 'package:find_them/core/routes/app_router.dart';
import 'package:find_them/data/services/notification_service.dart';
import 'package:find_them/data/services/prefrences_service.dart';
import 'package:find_them/data/models/enum.dart' as AppEnum;
import 'package:find_them/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // DISABLE reCAPTCHA for SMS verification
  FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
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
  late ProfilePreferencesService _preferencesService;
  bool _preferencesLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationService = NotificationService();
    _preferencesService = ProfilePreferencesService();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize notifications
    await _notificationService.initialize();

    // Load preferences from server/cache
    await _loadPreferences();
  }

  Future<void> refreshUserPreferences() async {
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      // Check if user is logged in first
      final isLoggedIn = await _preferencesService.isUserLoggedIn();

      if (isLoggedIn) {
        // User is logged in, load from server
        final preferences = await _preferencesService.loadPreferences();

        setState(() {
          final languageValue = preferences['language'] ?? 'english';
          final language = AppEnum.LanguageExtension.fromValue(languageValue);
          _locale = Locale(language.code);

          final themeValue = preferences['theme'] ?? 'light';
          isDarkMode = themeValue == 'dark';

          _preferencesLoaded = true;
        });
      } else {
        // User is not logged in, clear any cached preferences and use defaults
        await _preferencesService.clearCachedPreferences();

        setState(() {
          _locale = const Locale('en'); // Default language
          isDarkMode = false; // Default theme
          _preferencesLoaded = true;
        });
      }
    } catch (e) {
      // Use defaults if loading fails
      setState(() {
        _locale = const Locale('en');
        isDarkMode = false;
        _preferencesLoaded = true;
      });
    }
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
        if (_notificationService.isFullyInitialized) {
          _notificationService.refreshNotifications();
        }
        // Sync preferences when app resumes (if user is logged in)
        _syncPreferencesFromServer();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _syncPreferencesFromServer() async {
    if (await _preferencesService.isUserLoggedIn()) {
      final preferences = await _preferencesService.loadPreferences();

      setState(() {
        final languageValue = preferences['language'] ?? 'english';
        final language = AppEnum.LanguageExtension.fromValue(languageValue);
        _locale = Locale(language.code);

        final themeValue = preferences['theme'] ?? 'light';
        isDarkMode = themeValue == 'dark';
      });
    } else {
      // User is logged out, reset to defaults and clear cache
      await _preferencesService.clearCachedPreferences();
      setState(() {
        _locale = const Locale('en');
        isDarkMode = false;
      });
    }
  }

  void toggleTheme() async {
    final newTheme = isDarkMode ? AppEnum.Theme.light : AppEnum.Theme.dark;

    // Check if user is logged in
    if (await _preferencesService.isUserLoggedIn()) {
      // Update server
      final success = await _preferencesService.updateThemePreference(newTheme);

      if (success) {
        setState(() {
          isDarkMode = !isDarkMode;
        });
      } else {
        // Show error message
        if (navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(content: Text('Failed to update theme preference')),
          );
        }
      }
    } else {
      // User not logged in, just update locally
      setState(() {
        isDarkMode = !isDarkMode;
      });
      // Cache locally for when they log in
      final prefs = await _preferencesService.getCachedPreferences();
      prefs['theme'] = newTheme.value;
    }
  }

  void changeLanguage(String languageCode) async {
    // Convert language code to Language enum
    AppEnum.Language language;
    switch (languageCode) {
      case 'fr':
        language = AppEnum.Language.french;
        break;
      case 'ar':
        language = AppEnum.Language.arabic;
        break;
      default:
        language = AppEnum.Language.english;
    }

    // Check if user is logged in
    if (await _preferencesService.isUserLoggedIn()) {
      // Update server
      final success = await _preferencesService.updateLanguagePreference(
        language,
      );

      if (success) {
        setState(() {
          _locale = Locale(languageCode);
        });
      } else {
        // Show error message
        if (navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(
              content: Text('Failed to update language preference'),
            ),
          );
        }
      }
    } else {
      // User not logged in, just update locally
      setState(() {
        _locale = Locale(languageCode);
      });
      // Cache locally for when they log in
      final prefs = await _preferencesService.getCachedPreferences();
      prefs['language'] = language.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen until preferences are loaded
    if (!_preferencesLoaded) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading preferences...'),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Find Them',
      navigatorKey: navigatorKey,
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
