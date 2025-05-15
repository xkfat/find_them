import 'package:find_them/core/routes/app_router.dart';
import 'package:find_them/logic/cubits/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:find_them/logic/cubits/theme/theme_cubit.dart';
import 'package:find_them/logic/cubits/auth/auth_cubit.dart';
import 'package:find_them/core/constants/themes/app_theme.dart';
import 'package:find_them/core/routes/route_constants.dart';
import 'package:find_them/core/routes/navigation_helper.dart';
import 'package:find_them/data/services/api_service.dart';
import 'package:find_them/data/services/auth_service.dart';
import 'package:find_them/data/services/firebase_auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );

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

class _MyAppState extends State<MyApp> {
  late final ApiService _apiService;
  late final AuthService _authService;
  late final FirebaseAuthService _firebaseAuthService;

  @override
  void initState() {
    super.initState();

    // Initialize services
    _apiService = ApiService();
    _authService = AuthService(_apiService);
    _firebaseAuthService = FirebaseAuthService();

    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(_authService, _firebaseAuthService),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // Handle auth state changes
          if (state is AuthUnauthenticated) {
            // Go to onboarding/login flow when unauthenticated
            NavigationHelper.navigateAndClearStack(RouteConstants.onboarding);
          } else if (state is AuthAuthenticated) {
            // Go to home when authenticated
            NavigationHelper.navigateAndClearStack(RouteConstants.home);
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'FindThem',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state,
              navigatorKey: NavigationHelper.navigatorKey,
              initialRoute: RouteConstants.splash,
              onGenerateRoute: AppRouter.generateRoute,
            );
          },
        ),
      ),
    );
  }
}
