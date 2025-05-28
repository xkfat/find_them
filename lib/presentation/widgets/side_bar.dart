import 'package:find_them/data/models/user.dart';
import 'package:find_them/data/repositories/auth_repo.dart';
import 'package:find_them/data/services/auth_service.dart';
import 'package:find_them/logic/cubit/authentification_cubit.dart';
import 'package:find_them/logic/cubit/profile_cubit.dart';
import 'package:find_them/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/themes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:find_them/l10n/app_localizations.dart';

extension LocalizationHelper on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  void _handleLogout() async {
    final navigator = Navigator.of(context);

    navigator.pop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(child: CircularProgressIndicator(color: AppColors.teal));
      },
    );

    try {
      final authService = AuthService();
      final success = await authService.logout();

      if (context.mounted) {
        navigator.pop();
      }

      if (success) {
        if (context.mounted) {
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder:
                  (context) => BlocProvider(
                    create:
                        (context) => AuthentificationCubit(
                          AuthRepository(AuthService()),
                        ),
                    child: const LoginScreen(),
                  ),
            ),
            (route) => false,
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.logoutFailed,
                style: TextStyle(color: AppColors.getTextColor(context)),
              ),
              backgroundColor: AppColors.getInvestigatingYellowBackground(
                context,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        navigator.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.l10n.errorLoggingOut}: ${e.toString()}',
              style: TextStyle(color: AppColors.getTextColor(context)),
            ),
            backgroundColor: AppColors.getMissingRedBackground(context),
          ),
        );

        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder:
                (context) => BlocProvider(
                  create:
                      (context) =>
                          AuthentificationCubit(AuthRepository(AuthService())),
                  child: const LoginScreen(),
                ),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 34, top: 90),
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                User? user;
                if (state is ProfileLoaded) {
                  user = state.user;
                } else if (state is ProfileUpdateSuccess) {
                  user = state.user;
                } else if (state is ProfilePhotoUploadSuccess) {
                  user = state.user;
                }

                ImageProvider<Object> profileImage;
                if (user != null &&
                    user.profilePhoto != null &&
                    user.profilePhoto!.isNotEmpty) {
                  profileImage = NetworkImage(user.profilePhoto!);
                } else {
                  profileImage = const AssetImage('assets/images/profile.png');
                }

                if (user == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundImage: profileImage,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Unknown user',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextColor(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap:
                                    () => Navigator.of(
                                      context,
                                    ).pushNamed('/auth/login'),
                                child: Text(
                                  context.l10n.login,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.teal,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                }

                String firstName = user.firstName;
                String lastName = user.lastName;
                String username = user.username;

                return Row(
                  children: [
                    CircleAvatar(radius: 34, backgroundImage: profileImage),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName $lastName',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                        Text(
                          '@$username',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 48),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.getDividerColor(context),
          ),
          _buildMenuItemWithImageIcon(
            0,
            'assets/icons/submit.png',
            'assets/icons/submitF.png',
            context.l10n.mySubmittedCases,
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/submitted-cases');
            },
          ),
          _buildMenuItemWithImageIcon(
            1,
            'assets/icons/location.png',
            'assets/icons/locationF.png',
            context.l10n.locationSharing,
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/location-sharing');
            },
          ),
          _buildMenuItemWithImageIcon(
            2,
            'assets/icons/notification.png',
            'assets/icons/notificationF.png',
            context.l10n.notifications,
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          _buildMenuItemWithImageIcon(
            3,
            'assets/icons/logout.png',
            'assets/icons/logoutF.png',
            context.l10n.logout,
            _handleLogout,
          ),
          const Spacer(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItemWithImageIcon(
    int index,
    String outlinedIconPath,
    String filledIconPath,
    String title,
    VoidCallback onTap,
  ) {
    bool isSelected = index == _selectedIndex;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        onTap();
      },
      onHover: (hovering) {
        if (hovering && !isSelected) {
          setState(() {
            _selectedIndex = index;
          });
        } else if (!hovering && isSelected) {
          setState(() {
            _selectedIndex = -1;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Image.asset(
            isSelected ? filledIconPath : outlinedIconPath,
            width: 24,
            height: 24,
            color:
                isSelected ? AppColors.teal : AppColors.getTextColor(context),
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color:
                  isSelected ? AppColors.teal : AppColors.getTextColor(context),
            ),
            textDirection:
                Localizations.localeOf(context).languageCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
