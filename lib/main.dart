import 'package:find_them/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_theme.dart';
//import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  

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
/*
FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );
  */
class _MyAppState extends State<MyApp> {
  /*
  late final ApiService _apiService;
  late final AuthService _authService;
  late final FirebaseAuthService _firebaseAuthService;
  late final AuthRepository _authRepository;
*/
  /*
  @override
  void initState() {
    super.initState();

    _apiService = ApiService();
    _authService = AuthService(_apiService);
    _firebaseAuthService = FirebaseAuthService();
    _authRepository = AuthRepository(_authService, _firebaseAuthService);

    FlutterNativeSplash.remove();
  }
*/
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FindThem',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // themeMode: state,
      //  navigatorKey: NavigationHelper.navigatorKey,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
