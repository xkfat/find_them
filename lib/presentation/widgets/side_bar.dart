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

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int _selectedIndex = -1;
  //final AuthService _authService = AuthService();

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
        return const Center(
          child: CircularProgressIndicator(color: AppColors.darkGreen),
        );
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
            const SnackBar(
              content: Text('Logout failed. Please try again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        navigator.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
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
        color: AppColors.lighterMint,
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

                return Row(
                  children: [
                    CircleAvatar(radius: 34, backgroundImage: profileImage),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null
                              ? '${user.firstName ?? ''} ${user.lastName ?? ''}'
                              : 'Loading...',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          user != null ? '@${user.username ?? 'username'}' : '',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
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
          const Divider(height: 1, thickness: 1),
          _buildMenuItemWithImageIcon(
            0,
            'assets/icons/submit.png',
            'assets/icons/submitF.png',
            'My submitted cases',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/submitted-cases');
            },
          ),
          _buildMenuItemWithImageIcon(
            1,
            'assets/icons/location.png',
            'assets/icons/locationF.png',
            'Location sharing',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/location-sharing');
            },
          ),
          _buildMenuItemWithImageIcon(
            2,
            'assets/icons/notification.png',
            'assets/icons/notificationF.png',
            'Notifications',
            () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          _buildMenuItemWithImageIcon(
            3,
            'assets/icons/logout.png',
            'assets/icons/logoutF.png',
            'Log out',
            _handleLogout,
          ),
          const Spacer(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    String title,
  ) {
    bool isSelected = index == _selectedIndex;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        Future.delayed(Duration(milliseconds: 150), () {
          Navigator.pop(context);
        });
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
          leading: Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected ? AppColors.darkGreen : Colors.black,
            size: 24,
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color: isSelected ? AppColors.darkGreen : Colors.black,
            ),
          ),
        ),
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
            color: isSelected ? AppColors.darkGreen : Colors.black,
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color: isSelected ? AppColors.darkGreen : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
