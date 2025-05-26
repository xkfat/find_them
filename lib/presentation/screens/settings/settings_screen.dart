import 'package:find_them/presentation/widgets/LanguageDrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:find_them/presentation/widgets/toggle.dart';
import 'package:find_them/logic/cubit/location_sharing_cubit.dart';
import 'package:find_them/data/repositories/location_sharing_repo.dart';
import 'package:find_them/data/services/location_sharing_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const SettingsScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = false;
  bool locationPermissionEnabled = false;
  bool locationSharingEnabled = false;
  String selectedLanguage = 'English';
  final List<String> languages = ['Arabic', 'English', 'French'];
  late LocationSharingCubit _locationSharingCubit;

  @override
  void initState() {
    super.initState();
    _locationSharingCubit = LocationSharingCubit(
      LocationSharingRepository(LocationSharingService()),
    );
    _checkLocationPermission();
    _checkNotificationPermission();
    _loadLocationSharingSettings();
  }

  @override
  void dispose() {
    _locationSharingCubit.close();
    super.dispose();
  }

  Future<void> _loadLocationSharingSettings() async {
    try {
      final settings = await _locationSharingCubit.getSharingSettings();
      if (settings != null) {
        setState(() {
          locationSharingEnabled = settings['is_sharing'] ?? false;
        });
      }
    } catch (e) {
      // Handle error silently or show minimal feedback
      print('Error loading location sharing settings: $e');
    }
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      notificationsEnabled = status.isGranted;
    });
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    setState(() {
      locationPermissionEnabled = status.isGranted;
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    setState(() {
      locationPermissionEnabled = status.isGranted;
    });
  }

  Future<void> _openNotificationSettings() async {
    await openAppSettings();
    await Future.delayed(const Duration(seconds: 1));
    _checkNotificationPermission();
  }

  void _showDialog(String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? AppColors.foundGreen : Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.getTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.teal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleLocationSharing(bool value) async {
    try {
      await _locationSharingCubit.toggleGlobalSharing(value);
      setState(() {
        locationSharingEnabled = value;
      });

      final message =
          value
              ? 'Location sharing enabled - Now sharing with all friends'
              : 'Location sharing disabled';
      _showDialog(message, true);
    } catch (e) {
      // Revert the toggle state on error
      setState(() {
        locationSharingEnabled = !value;
      });
      _showDialog('Failed to update location sharing: ${e.toString()}', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationSharingCubit, LocationSharingState>(
      bloc: _locationSharingCubit,
      listener: (context, state) {
        if (state is LocationSharingActionSuccess) {
          // Success is already handled in _toggleLocationSharing
        } else if (state is LocationSharingError) {
          _showDialog('Error: ${state.message}', false);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.getBackgroundColor(context),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: AppColors.getBackgroundColor(context),
                  ),
                ),
              ],
            ),

            Center(
              child: Container(
                width: 411,
                height: 500,
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.black54
                              : Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Account Settings',
                          style: GoogleFonts.rubik(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 38),
                      _buildNavigationOption(
                        'Edit profile',
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),

                      const SizedBox(height: 22),

                      _buildNavigationOption(
                        'Change password',
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              '/settings/change-password',
                            ),
                      ),

                      const SizedBox(height: 22),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Change language',
                              style: GoogleFonts.rubik(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: AppColors.getTextColor(context),
                              ),
                            ),
                            LanguageDropdown(
                              selectedLanguage: selectedLanguage,
                              languages: languages,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedLanguage = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      _buildToggleOption(
                        'Notifications',
                        notificationsEnabled,
                        onChanged: (value) async {
                          await _openNotificationSettings();
                        },
                      ),

                      const SizedBox(height: 22),

                      _buildToggleOption(
                        'Dark mode',
                        Theme.of(context).brightness == Brightness.dark,
                        onChanged: (value) {
                          widget.toggleTheme();
                        },
                      ),

                      const SizedBox(height: 22),

                      _buildToggleOption(
                        'Location permission',
                        locationPermissionEnabled,
                        onChanged: (value) async {
                          if (value) {
                            await _requestLocationPermission();
                          } else {
                            openAppSettings();
                          }
                        },
                      ),

                      const SizedBox(height: 22),

                      _buildToggleOption(
                        'Location sharing',
                        locationSharingEnabled,
                        onChanged: _toggleLocationSharing,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const Padding(
          padding: EdgeInsets.only(left: 0),
          child: ButtomNavBar(currentIndex: 3),
        ),
      ),
    );
  }

  Widget _buildNavigationOption(String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.rubik(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: AppColors.getTextColor(context),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption(
    String title,
    bool value, {
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: AppColors.getTextColor(context),
            ),
          ),
          Toggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
