import 'package:find_them/core/routes/navigation_helper.dart';
import 'package:find_them/logic/cubits/auth/auth_cubit.dart';
import 'package:find_them/logic/cubits/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppStateCoordinator extends StatelessWidget {
  final Widget child;
  
  const AppStateCoordinator({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSignupSuccessful) {
              // Handle navigation to SMS verification
              NavigationHelper.goToVerifyPhone(state.phoneNumber);
            } else if (state is AuthAuthenticated) {
              // Handle navigation to home
              NavigationHelper.goToHome();
            } else if (state is AuthUnauthenticated) {
              // Handle navigation to login/onboarding
              NavigationHelper.goToLogin();
            }
          },
        ),
        // Add other BlocListeners for other Cubits here
      ],
      child: child,
    );
  }
}