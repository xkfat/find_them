import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/repositories/auth_repo.dart';
import 'package:find_them/data/repositories/case_repo.dart';
import 'package:find_them/data/services/auth_service.dart';
import 'package:find_them/data/services/case_service.dart';
import 'package:find_them/logic/cubit/authentification_cubit.dart';
import 'package:find_them/logic/cubit/case_list_cubit.dart';
import 'package:find_them/logic/cubit/sign_up_cubit.dart';
import 'package:find_them/logic/cubit/sms_verification_cubit.dart';
import 'package:find_them/presentation/screens/case/case_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:find_them/core/routes/route_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding.dart';
import '../../presentation/screens/onboarding/onboarding2.dart';
import '../../presentation/screens/onboarding/onboarding3.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/auth/sms_verification_screen.dart.dart';
import '../../presentation/screens/auth/reset_pass_screen.dart';
import '../../presentation/widgets/placeholder_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case RouteConstants.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteConstants.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingWrapper());

      case RouteConstants.signup:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (BuildContext context) =>
                        SignUpCubit(AuthRepository(AuthService())),
                child: const SignupScreen(),
              ),
        );

      case RouteConstants.verifyPhone:
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

      case RouteConstants.login:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (BuildContext context) =>
                        AuthentificationCubit(AuthRepository(AuthService())),
                child: const LoginScreen(),
              ),
        );

      /* case RouteConstants.resetPassword:
        return MaterialPageRoute(
          builder:
              (_) =>
                  const ResetPasswordScreen()
        );
*/

        case RouteConstants.home:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider<CaseCubit>(
                create:
                    (context) => CaseCubit(
                      CaseRepository(CaseService()),
                    ),
                child: const HomeScreen(),
              ),
        );

            case RouteConstants.caseDetails:
        final int caseId = args is int ? args : (args is String ? int.tryParse(args) ?? 0 : 0);
        if (caseId == 0) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid case ID')),
            ),
          );
        }
        return MaterialPageRoute(
          builder:
              (context) => BlocProvider<CaseCubit>(
                create:
                    (context) => CaseCubit(
                      CaseRepository(CaseService()),
                    ),
                child: CaseDetailScreen(caseId: caseId),
              ),
        );

      /*
      case RouteConstants.map:
        return MaterialPageRoute(builder: (_) => const MapScreen());

      case RouteConstants.report:
        return MaterialPageRoute(builder: (_) => const ReportScreen());

      case RouteConstants.reportStep2:
        return MaterialPageRoute(builder: (_) => const ReportStep2Screen());

      case RouteConstants.reportStep3:
        return MaterialPageRoute(builder: (_) => const ReportStep3Screen());

      case RouteConstants.reportSuccess:
        return MaterialPageRoute(builder: (_) => const ReportSuccessScreen());

      case RouteConstants.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case RouteConstants.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case RouteConstants.profile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case RouteConstants.submittedCases:
        return MaterialPageRoute(builder: (_) => const SubmittedCasesScreen());

      case RouteConstants.caseDetails:
        final caseId = args is String ? args : '';
        return MaterialPageRoute(
          builder: (_) => CaseDetailsScreen(caseId: caseId),
        );

      case RouteConstants.addFriend:
        return MaterialPageRoute(builder: (_) => const AddFriendScreen());

      case RouteConstants.locationSharing:
        return MaterialPageRoute(builder: (_) => const LocationSharingScreen());

      case RouteConstants.notifications:
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
