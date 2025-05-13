import 'package:flutter/material.dart';
import '../../core/routes/route_constants.dart';

class NavigationHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic> replaceTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic> navigateAndClearStack(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack() {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }
  }

  static void goToLogin() => navigateTo(RouteConstants.login);
  static void goToSignup() => navigateTo(RouteConstants.signup);
  static void goToVerifyPhone(String phoneNumber) =>
      navigateTo(RouteConstants.verifyPhone, arguments: phoneNumber);

  static void goToHome() => navigateAndClearStack(RouteConstants.home);
  static void goToMap() => navigateTo(RouteConstants.map);
  static void goToProfile() => navigateTo(RouteConstants.profile);
  static void goToSettings() => navigateTo(RouteConstants.settings);

  static void startReportFlow() => navigateTo(RouteConstants.report);
  static void goToReportStep2() => navigateTo(RouteConstants.reportStep2);
  static void goToReportStep3() => navigateTo(RouteConstants.reportStep3);
  static void goToReportSuccess() => navigateTo(RouteConstants.reportSuccess);

  static void viewCaseDetails(String caseId) =>
      navigateTo(RouteConstants.caseDetails, arguments: caseId);

  static void goToLocationSharing() =>
      navigateTo(RouteConstants.locationSharing);
  static void goToAddFriend() => navigateTo(RouteConstants.addFriend);
  static void goToNotifications() => navigateTo(RouteConstants.notifications);
}
