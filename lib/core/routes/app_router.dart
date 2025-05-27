import 'package:find_them/data/models/auth.dart';
import 'package:find_them/data/repositories/auth_repo.dart';
import 'package:find_them/data/repositories/case_repo.dart';
import 'package:find_them/data/repositories/location_sharing_repo.dart';
import 'package:find_them/data/repositories/map_repo.dart';
import 'package:find_them/data/repositories/notification_repo.dart';
import 'package:find_them/data/repositories/profile_repo.dart';
import 'package:find_them/data/repositories/report_repo.dart';
import 'package:find_them/data/repositories/submitted_cases_repo.dart';
import 'package:find_them/data/services/auth_service.dart';
import 'package:find_them/data/services/case_service.dart';
import 'package:find_them/data/services/location_sharing_service.dart';
import 'package:find_them/data/services/map_service.dart';
import 'package:find_them/data/services/notification_service.dart';
import 'package:find_them/data/services/report_service.dart';
import 'package:find_them/data/services/submitted_cases_service.dart';
import 'package:find_them/logic/cubit/add_friend_cubit.dart';
import 'package:find_them/logic/cubit/authentification_cubit.dart';
import 'package:find_them/logic/cubit/case_list_cubit.dart';
import 'package:find_them/logic/cubit/case_updates_cubit.dart';
import 'package:find_them/logic/cubit/location_sharing_cubit.dart';
import 'package:find_them/logic/cubit/map_cubit.dart';
import 'package:find_them/logic/cubit/notification_cubit.dart';
import 'package:find_them/logic/cubit/user_submitted_cases_cubit.dart';
import 'package:find_them/logic/cubit/profile_cubit.dart';
import 'package:find_them/logic/cubit/report_cubit.dart';
import 'package:find_them/logic/cubit/sign_up_cubit.dart';
import 'package:find_them/logic/cubit/sms_verification_cubit.dart';
import 'package:find_them/logic/cubit/submit_case_cubit.dart';
import 'package:find_them/presentation/screens/case/case_detail_screen.dart';
import 'package:find_them/presentation/screens/case/my_submitted_cases_screen.dart';
import 'package:find_them/presentation/screens/map/map_screen.dart';
import 'package:find_them/presentation/screens/notifications/notification_screen.dart';
import 'package:find_them/presentation/screens/profile/profile_screen.dart';
import 'package:find_them/presentation/screens/report/report_screen.dart';
import 'package:find_them/presentation/screens/report/report_screen2.dart';
import 'package:find_them/presentation/screens/report/report_screen3.dart';
import 'package:find_them/presentation/screens/report/report_success_screen.dart';
import 'package:find_them/presentation/screens/settings/change_pass_screen.dart';
import 'package:find_them/presentation/screens/settings/settings_screen.dart';
import 'package:find_them/presentation/screens/location/add_friend_screen.dart.dart';
import 'package:find_them/presentation/screens/location/location_sharing_screen.dart';
import 'package:find_them/presentation/widgets/profileDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/auth/sms_verification_screen.dart.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
    RouteSettings settings,
    VoidCallback toggleTheme,
  ) {
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

      case '/home':
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<CaseCubit>(
                    create:
                        (context) => CaseCubit(CaseRepository(CaseService())),
                  ),
                  BlocProvider<ProfileCubit>(
                    create: (context) => ProfileCubit(ProfileRepository()),
                  ),
                ],
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
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (context) => MapCubit(
                      MapRepository(MapService(), LocationSharingService()),
                    ),
                child: const MapScreen(),
              ),
        );

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
                    latitude: args['latitude'],
                    longitude: args['longitude'],

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
                    (context) =>
                        ProfileCubit(ProfileRepository())..loadProfile(),
                child: BlocListener<ProfileCubit, ProfileState>(
                  listener: (context, state) {
                    // Use ProfileDialog instead of SnackBar for notifications
                    if (state is ProfileUpdateSuccess) {
                      showProfileDialog(
                        context: context,
                        message: 'Profile updated successfully',
                        isSuccess: true,
                      );
                    } else if (state is ProfileUpdateError) {
                      showProfileDialog(
                        context: context,
                        message: state.message,
                        isSuccess: false,
                      );
                    } else if (state is ProfilePhotoUploadSuccess) {
                      showProfileDialog(
                        context: context,
                        message: 'Profile photo uploaded successfully',
                        isSuccess: true,
                      );
                    } else if (state is ProfilePhotoUploadError) {
                      showProfileDialog(
                        context: context,
                        message:
                            'Failed to upload profile photo: ${state.message}',
                        isSuccess: false,
                      );
                    } else if (state is ProfilePasswordChangeSuccess) {
                      showProfileDialog(
                        context: context,
                        message: 'Password changed successfully',
                        isSuccess: true,
                      );
                    } else if (state is ProfilePasswordChangeError) {
                      showProfileDialog(
                        context: context,
                        message: 'Password change failed: ${state.message}',
                        isSuccess: false,
                      );
                    }
                  },
                  child: const ProfileScreen(),
                ),
              ),
        );
      case '/settings':
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<ProfileCubit>(
                    create: (context) => ProfileCubit(ProfileRepository()),
                  ),
                ],
                child: SettingsScreen(toggleTheme: toggleTheme),
              ),
        );
      case '/settings/change-password':
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider<ProfileCubit>(
                create: (context) => ProfileCubit(ProfileRepository()),
                child: const ChangePasswordScreen(),
              ),
        );
      case '/submitted-cases':
        return MaterialPageRoute(
          builder:
              (_) => MultiBlocProvider(
                providers: [
                  BlocProvider<UserSubmittedCasesCubit>(
                    create:
                        (context) => UserSubmittedCasesCubit(
                          SubmittedCaseRepository(SubmittedCaseService()),
                        ),
                  ),
                  BlocProvider<CaseUpdatesCubit>(
                    create:
                        (context) => CaseUpdatesCubit(
                          SubmittedCaseRepository(SubmittedCaseService()),
                        ),
                  ),
                ],
                child: const SubmittedCasesScreen(),
              ),
        );

      case '/location-sharing':
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (context) => LocationSharingCubit(
                      LocationSharingRepository(LocationSharingService()),
                    ),
                child: const LocationSharingScreen(),
              ),
        );

      case '/add-friend':
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (context) => AddFriendCubit(
                      LocationSharingRepository(LocationSharingService()),
                    ),
                child: const AddFriendScreen(),
              ),
        );
      case '/notifications':
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create:
                    (context) => NotificationCubit(
                      NotificationRepository(NotificationService()),
                    ),
                child: const NotificationsScreen(),
              ),
        );

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
