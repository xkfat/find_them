import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/repositories/auth_repo.dart';
import 'package:find_them/data/repositories/case_repo.dart';
import 'package:find_them/data/repositories/profile_repo.dart';
import 'package:find_them/data/repositories/report_repo.dart';
import 'package:find_them/data/services/auth_service.dart';
import 'package:find_them/data/services/case_service.dart';
import 'package:find_them/data/services/profile_service.dart';
import 'package:find_them/data/services/report_service.dart';
import 'package:find_them/logic/cubit/authentification_cubit.dart';
import 'package:find_them/logic/cubit/case_list_cubit.dart';
import 'package:find_them/logic/cubit/profile_cubit.dart';
import 'package:find_them/logic/cubit/report_cubit.dart';
import 'package:find_them/logic/cubit/sign_up_cubit.dart';
import 'package:find_them/logic/cubit/sms_verification_cubit.dart';
import 'package:find_them/logic/cubit/submit_case_cubit.dart';
import 'package:find_them/presentation/screens/case/case_detail_screen.dart';
import 'package:find_them/presentation/screens/map/map_screen.dart';
import 'package:find_them/presentation/screens/profile/profile_screen.dart';
import 'package:find_them/presentation/screens/report/report_screen.dart';
import 'package:find_them/presentation/screens/report/report_screen2.dart';
import 'package:find_them/presentation/screens/report/report_screen3.dart';
import 'package:find_them/presentation/screens/report/report_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/auth/sms_verification_screen.dart.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingWrapper());

      case '/auth/signup':
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (BuildContext context) =>
                        SignUpCubit(AuthRepository(AuthService())),
                child: const SignupScreen(),
              ),
        );

      case '/auth/verify-phone':
        final Map<String, dynamic> params = args as Map<String, dynamic>;
        final String phoneNumber = params['phoneNumber'];
        final SignUpData? signUpData = params['signUpData'];

        return MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create:
                    (context) =>
                        SmsVerificationCubit(AuthRepository(AuthService())),
                child: SmsVerificationScreen(
                  phoneNumber: phoneNumber,
                  signUpData: signUpData,
                ),
              ),
        );

      case '/auth/login':
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (BuildContext context) =>
                        AuthentificationCubit(AuthRepository(AuthService())),
                child: const LoginScreen(),
              ),
        );

      /* case '/auth/reset-password' :
        return MaterialPageRoute(
          builder:
              (_) =>
                  const ResetPasswordScreen()
        );
*/

      case '/home':
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider<CaseCubit>(
                create: (context) => CaseCubit(CaseRepository(CaseService())),
                child: const HomeScreen(),
              ),
        );

      case '/case/details':
        final int caseId =
            args is int ? args : (args is String ? int.tryParse(args) ?? 0 : 0);
        if (caseId == 0) {
          return MaterialPageRoute(
            builder:
                (_) => const Scaffold(
                  body: Center(child: Text('Invalid case ID')),
                ),
          );
        }
        return MaterialPageRoute(
          builder:
              (context) => MultiBlocProvider(
                providers: [
                  BlocProvider<CaseCubit>(
                    create:
                        (context) => CaseCubit(CaseRepository(CaseService())),
                  ),
                  BlocProvider<ReportCubit>(
                    create:
                        (context) =>
                            ReportCubit(ReportRepository(ReportService())),
                  ),
                ],
                child: CaseDetailScreen(caseId: caseId),
              ),
        );

      case '/map':
        return MaterialPageRoute(builder: (_) => const MapScreen());

      case '/report':
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider<SubmitCaseCubit>(
                create:
                    (context) => SubmitCaseCubit(CaseRepository(CaseService())),
                child: const Report1Screen(),
              ),
        );

      case '/report2':
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder:
                (_) => BlocProvider<SubmitCaseCubit>(
                  create:
                      (context) =>
                          SubmitCaseCubit(CaseRepository(CaseService())),
                  child: Report2Screen(
                    firstName: args['firstName'] as String,
                    lastName: args['lastName'] as String,
                    age: args['age'] as int,
                    gender: args['gender'] as String,
                  ),
                ),
          );
        } else {
          return MaterialPageRoute(
            builder:
                (_) => Scaffold(
                  body: Center(child: Text('Invalid arguments provided')),
                ),
          );
        }

      case '/report3':
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder:
                (_) => BlocProvider<SubmitCaseCubit>(
                  create:
                      (context) =>
                          SubmitCaseCubit(CaseRepository(CaseService())),
                  child: Report3Screen(
                    firstName: args['firstName'] as String,
                    lastName: args['lastName'] as String,
                    age: args['age'] as int,
                    gender: args['gender'] as String,
                    lastSeenDate: args['lastSeenDate'] as DateTime,
                    lastSeenLocation: args['lastSeenLocation'] as String,
                    latitude:
                        args.containsKey('latitude')
                            ? args['latitude'] as double?
                            : null,
                    longitude:
                        args.containsKey('longitude')
                            ? args['longitude'] as double?
                            : null,

                    contactPhone:
                        args.containsKey('contactPhone')
                            ? args['contactPhone'] as String?
                            : null,
                  ),
                ),
          );
        } else {
          return MaterialPageRoute(
            builder:
                (_) => Scaffold(
                  body: Center(child: Text('Invalid arguments provided')),
                ),
          );
        }

      case '/report_success':
        return MaterialPageRoute(builder: (_) => const ReportSuccessScreen());

     case '/profile':
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider<ProfileCubit>(
                create:
                    (context) => ProfileCubit(ProfileRepository(profileService: ProfileService())),
                child: const ProfileScreen(),
              ),
        );
      /*
      case '/settings' :
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

   
      case '/submitted-cases' :
        return MaterialPageRoute(builder: (_) => const SubmittedCasesScreen());


      case '/friends/add' :
        return MaterialPageRoute(builder: (_) => const AddFriendScreen());

      case'/location-sharing' :
        return MaterialPageRoute(builder: (_) => const LocationSharingScreen());

      case '/notifications' :
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
*/
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
