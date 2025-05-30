import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/themes/app_colors.dart';
import '../../../logic/cubit/location_sharing_cubit.dart';
import '../../widgets/location/location_card.dart';
import 'package:find_them/presentation/helpers/localisation_extenstion.dart';

class LocationSharingScreen extends StatefulWidget {
  const LocationSharingScreen({super.key});

  @override
  State<LocationSharingScreen> createState() => _LocationSharingScreenState();
}

class _LocationSharingScreenState extends State<LocationSharingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LocationSharingCubit>().loadLocationData();
  }

  void _showCustomDialog(String message, bool isSuccess) {
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
                color:
                    isSuccess
                        ? AppColors.getFoundGreenColor(context)
                        : AppColors.getMissingRedColor(context),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          context.l10n.locationSharingTitle,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextColor(context),
          ),
        ),
        backgroundColor: AppColors.getBackgroundColor(context),
        iconTheme: IconThemeData(color: AppColors.getTextColor(context)),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_add,
              color: AppColors.getTextColor(context),
            ),
            onPressed: () => Navigator.pushNamed(context, '/add-friend'),
          ),
        ],
      ),
      body: BlocConsumer<LocationSharingCubit, LocationSharingState>(
        listener: (context, state) {
          if (state is LocationSharingActionSuccess) {
            _showCustomDialog(state.message, true);
          } else if (state is LocationSharingError) {
            _showCustomDialog(state.message, false);
          }
        },
        builder: (context, state) {
          if (state is LocationSharingLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            );
          } else if (state is LocationSharingError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${context.l10n.error}: ${state.message}',
                    style: TextStyle(color: AppColors.getTextColor(context)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LocationSharingCubit>().loadLocationData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                    ),
                    child: Text(
                      context.l10n.retry,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is LocationSharingLoaded) {
            return LocationCards(
              requests: state.requests,
              friends: state.friends,
              onShowDialog: _showCustomDialog,
            );
          }
          return Container();
        },
      ),
    );
  }
}
