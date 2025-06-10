import 'dart:developer';
import 'package:find_them/data/services/prefrences_service.dart';
import 'package:find_them/presentation/widgets/language_dropdown.dart';
import 'package:find_them/data/models/enum.dart' as AppEnum;
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
  bool isDarkMode = false;
  bool _isUpdatingLanguage = false;
  bool _isUpdatingTheme = false;

  final List<String> languages = ['English', 'العربية', 'Français'];

  final Map<String, String> languageCodes = {
    'English': 'en',
    'العربية': 'ar',
    'Français': 'fr',
  };

  late LocationSharingCubit _locationSharingCubit;
  final ProfilePreferencesService _preferencesService =
      ProfilePreferencesService();

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
    _setCurrentTheme();
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

  void _setCurrentTheme() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          isDarkMode = Theme.of(context).brightness == Brightness.dark;
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

  // Updated language change handler with server sync
  Future<void> _handleLanguageChange(String newLanguage) async {
    if (_isUpdatingLanguage) return;

    setState(() {
      _isUpdatingLanguage = true;
      selectedLanguage = newLanguage;
    });

    final languageCode = languageCodes[newLanguage] ?? 'en';

    // Convert to Language enum
    AppEnum.Language language;
    switch (languageCode) {
      case 'fr':
        language = AppEnum.Language.french;
        break;
      case 'ar':
        language = AppEnum.Language.arabic;
        break;
      default:
        language = AppEnum.Language.english;
    }

    try {
      // Check if user is logged in
      if (await _preferencesService.isUserLoggedIn()) {
        // Update server
        final success = await _preferencesService.updateLanguagePreference(
          language,
        );

        if (success) {
          // Update app language
          widget.changeLanguage(languageCode);

          _showDialog('Language updated to ${language.displayName}', true);
        } else {
          // Revert UI change if server update failed
          setState(() {
            selectedLanguage = _getPreviousLanguage();
          });

          _showDialog('Failed to update language preference', false);
        }
      } else {
        // User not logged in, just update locally
        widget.changeLanguage(languageCode);

        _showDialog(
          'Language changed to ${language.displayName} (will sync when you log in)',
          true,
        );
      }
    } catch (e) {
      log('Error updating language: $e');

      // Revert UI change
      setState(() {
        selectedLanguage = _getPreviousLanguage();
      });

      _showDialog('Error updating language preference', false);
    } finally {
      setState(() {
        _isUpdatingLanguage = false;
      });
    }
  }

  // Updated theme toggle handler with server sync
  Future<void> _handleThemeToggle(bool newIsDarkMode) async {
    if (_isUpdatingTheme) return;

    setState(() {
      _isUpdatingTheme = true;
    });

    final theme = newIsDarkMode ? AppEnum.Theme.dark : AppEnum.Theme.light;

    try {
      // Check if user is logged in
      if (await _preferencesService.isUserLoggedIn()) {
        // Update server
        final success = await _preferencesService.updateThemePreference(theme);

        if (success) {
          // Update app theme
          widget.toggleTheme();
          setState(() {
            isDarkMode = newIsDarkMode;
          });

          _showDialog('Theme updated to ${theme.value} mode', true);
        } else {
          _showDialog('Failed to update theme preference', false);
        }
      } else {
        // User not logged in, just update locally
        widget.toggleTheme();
        setState(() {
          isDarkMode = newIsDarkMode;
        });

        _showDialog(
          'Theme changed to ${theme.value} mode (will sync when you log in)',
          true,
        );
      }
    } catch (e) {
      log('Error updating theme: $e');
      _showDialog('Error updating theme preference', false);
    } finally {
      setState(() {
        _isUpdatingTheme = false;
      });
    }
  }

  String _getPreviousLanguage() {
    final currentLocale = Localizations.localeOf(context);
    switch (currentLocale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
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

                      // Updated Language Selection with loading state
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
                            if (_isUpdatingLanguage)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              LanguageDropdown(
                                selectedLanguage: selectedLanguage,
                                languages: languages,
                                onChanged: _handleLanguageChange,
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

                      // Updated Dark Mode Toggle with loading state
                      _buildToggleOptionWithLoading(
                        context.l10n.darkMode,
                        isDarkMode,
                        _isUpdatingTheme,
                        onChanged: _handleThemeToggle,
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

  // New widget for toggle with loading state
  Widget _buildToggleOptionWithLoading(
    String title,
    bool value,
    bool isLoading, {
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
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Toggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
