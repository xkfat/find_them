import 'package:find_them/data/models/location_request.dart';
import 'package:find_them/data/models/location_sharing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/themes/app_colors.dart';
import '../../../logic/cubit/location_sharing_cubit.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Location sharing',
          style: GoogleFonts.dmSans(
            fontSize: 14,
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
            _showDialog(state.message, true);
          } else if (state is LocationSharingError) {
            _showDialog(state.message, false);
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
                    'Error: ${state.message}',
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
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is LocationSharingLoaded) {
            return _buildLocationList(state);
          }
          return Container();
        },
      ),
    );
  }

  Widget _buildLocationList(LocationSharingLoaded state) {
    final allItems = <Widget>[];

    for (final request in state.requests) {
      allItems.add(_buildRequestCard(request));
    }

    for (final friend in state.friends) {
      allItems.add(_buildFriendCard(friend));
    }

    if (allItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: AppColors.getSecondaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No location sharing friends',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add friends for location sharing',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: allItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => allItems[index],
    );
  }

  Widget _buildRequestCard(LocationRequestModel request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal,
                ),
                child: ClipOval(
                  child:
                      request.senderDetails.profilePhoto != null
                          ? Image.network(
                            request.senderDetails.profilePhoto!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/profile.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                          : Image.asset(
                            'assets/images/profile.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.senderDetails.displayName,
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'block') {
                    //TODO
                  } else if (value == 'report') {}
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(value: 'report', child: Text('Report')),
                    ],
                child: Icon(
                  Icons.more_horiz,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Not sharing',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await context
                                .read<LocationSharingCubit>()
                                .acceptRequest(request.id);
                          } catch (e) {}
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        child: Text(
                          'Accept',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_off,
                            size: 16,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Can not see you',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () async {
                          try {
                            await context
                                .read<LocationSharingCubit>()
                                .declineRequest(request.id);
                          } catch (e) {}
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        child: Text(
                          'Decline',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(LocationSharingModel friend) {
    final isSharing = friend.isSharing;
    final canSeeYou = friend.canSeeYou;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal,
                ),
                child: ClipOval(
                  child:
                      friend.friendDetails.profilePhoto != null
                          ? Image.network(
                            friend.friendDetails.profilePhoto!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/profile.png',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                          : Image.asset(
                            'assets/images/profile.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.friendDetails.displayName,
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'remove') {
                    try {
                      await context.read<LocationSharingCubit>().removeFriend(
                        friend.friendId,
                      );
                    } catch (e) {
                      // Error handled by BlocConsumer listener
                    }
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'remove',
                        child: Text('Remove Friend'),
                      ),
                    ],
                child: Icon(
                  Icons.more_horiz,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  isSharing ? AppColors.foundGreen : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isSharing ? 'Sharing' : 'Not sharing',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await context
                                .read<LocationSharingCubit>()
                                .sendAlert(friend.friendId);
                            _showDialog('Alert sent successfully!', true);
                          } catch (e) {
                            // Error handled by BlocConsumer listener
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        child: Text(
                          'Alert',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            canSeeYou ? Icons.visibility : Icons.visibility_off,
                            size: 16,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            canSeeYou ? 'Can see you' : 'Can not see you',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 4),
                            Text(
                              'View',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.getSecondaryTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
