import 'package:find_them/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'logic/cubits/theme/theme_cubit.dart';
import 'logic/cubits/theme/theme_state.dart';
import 'core/constants/themes/app_theme.dart';
import 'core/routes/route_constants.dart';
import 'core/routes/navigation_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FindThem',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            navigatorKey: NavigationHelper.navigatorKey,
            initialRoute: RouteConstants.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
