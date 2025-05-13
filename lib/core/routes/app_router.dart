import 'package:flutter/material.dart';
import 'package:find_them/core/routes/route_constants.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
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
        return MaterialPageRoute(
          builder:
              (_) => const PlaceholderScreen(screenName: 'OnboardingScreen()'),
        );
     /* case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen()); */
      case RouteConstants.signup:
        return MaterialPageRoute(builder: (_) => const PlaceholderScreen(screenName:  'SignupScreen()'));

     /* case RouteConstants.verifyPhone:
        final phoneNumber = args is String ? args : '';
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(screenName: 'VerifyPhoneScreen(phoneNumber: phoneNumber),'
        ));
*/
      case RouteConstants.resetPassword:
        return MaterialPageRoute(builder: (_) => const PlaceholderScreen(screenName:  'ResetPasswordScreen()'));

      case RouteConstants.home:
        return MaterialPageRoute(builder: (_) => const PlaceholderScreen(screenName:  'HomeScreen()'));


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
