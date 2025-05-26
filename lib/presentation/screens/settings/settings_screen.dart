import 'package:find_them/presentation/widgets/LanguageDrop.dart';
import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:find_them/presentation/widgets/toggle.dart';

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

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _checkNotificationPermission();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Container(color: AppColors.getBackgroundColor(context)),
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
                      onChanged: (value) {
                        setState(() {
                          locationSharingEnabled = value;
                        });
                      },
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
