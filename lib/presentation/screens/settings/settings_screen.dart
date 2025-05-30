import 'dart:developer';
import 'package:find_them/presentation/widgets/language_dropdown.dart';
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
import 'package:find_them/l10n/app_localizations.dart';
import 'package:find_them/presentation/helpers/localisation_extenstion.dart';


class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final Function(String) changeLanguage;

  const SettingsScreen({
    super.key,
    required this.toggleTheme,
    required this.changeLanguage,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = false;
  bool locationPermissionEnabled = false;
  bool locationSharingEnabled = false;
  String selectedLanguage = 'English';

  final List<String> languages = ['English', 'العربية', 'Français'];

  final Map<String, String> languageCodes = {
    'English': 'en',
    'العربية': 'ar',
    'Français': 'fr',
  };

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
    _setCurrentLanguage();
  }

  @override
  void dispose() {
    _locationSharingCubit.close();
    super.dispose();
  }

  void _setCurrentLanguage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentLocale = Localizations.localeOf(context);
        setState(() {
          switch (currentLocale.languageCode) {
            case 'ar':
              selectedLanguage = 'العربية';
              break;
            case 'fr':
              selectedLanguage = 'Français';
              break;
            default:
              selectedLanguage = 'English';
          }
        });
      }
    });
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
      log('Error loading location sharing settings: $e');
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
                context.l10n.ok,
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
              ? context.l10n.locationSharing +
                  ' ' +
                  context.l10n.success.toLowerCase()
              : context.l10n.locationSharing + ' disabled';
      _showDialog(message, true);
    } catch (e) {
      setState(() {
        locationSharingEnabled = !value;
      });
      _showDialog('${context.l10n.error}: ${e.toString()}', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationSharingCubit, LocationSharingState>(
      bloc: _locationSharingCubit,
      listener: (context, state) {
        if (state is LocationSharingActionSuccess) {
        } else if (state is LocationSharingError) {
          _showDialog('${context.l10n.error}: ${state.message}', false);
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
                          context.l10n.accountSettings,
                          style: GoogleFonts.rubik(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 38),
                      _buildNavigationOption(
                        context.l10n.editProfile,
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),
                      const SizedBox(height: 22),
                      _buildNavigationOption(
                        context.l10n.changePassword,
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
                              context.l10n.changeLanguage,
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

                                final languageCode =
                                    languageCodes[newValue] ?? 'en';

                                widget.changeLanguage(languageCode);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildToggleOption(
                        context.l10n.notifications,
                        notificationsEnabled,
                        onChanged: (value) async {
                          await _openNotificationSettings();
                        },
                      ),
                      const SizedBox(height: 22),
                      _buildToggleOption(
                        context.l10n.darkMode,
                        Theme.of(context).brightness == Brightness.dark,
                        onChanged: (value) {
                          widget.toggleTheme();
                        },
                      ),
                      const SizedBox(height: 22),
                      _buildToggleOption(
                        context.l10n.locationPermission,
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
                        context.l10n.locationSharing,
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
