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

  void _showRemoveDialog(int friendId, String friendName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Remove Friend',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
          ),
          content: Text(
            'Are you sure you want to remove $friendName from your friends list?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.getTextColor(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await context.read<LocationSharingCubit>().removeFriend(
                    friendId,
                  );
                } catch (e) {}
              },
              child: Text(
                'Remove',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getMissingRedColor(context),
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
        border: Border.all(
          color: AppColors.getInvestigatingYellowColor(context),
          width: 2,
        ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getInvestigatingYellowBackground(
                          context,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Location Request',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getInvestigatingYellowColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await context.read<LocationSharingCubit>().acceptRequest(
                        request.id,
                      );
                    } catch (e) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await context.read<LocationSharingCubit>().declineRequest(
                        request.id,
                      );
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
              ),
            ],
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                isSharing
                                    ? AppColors.getFoundGreenColor(context)
                                    : AppColors.getMissingRedColor(context),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isSharing ? 'Sharing with you' : 'Not sharing',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          canSeeYou ? Icons.visibility : Icons.visibility_off,
                          size: 14,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          canSeeYou ? 'Can see you' : 'Cannot see you',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                iconColor: AppColors.getSecondaryTextColor(context),
                color: AppColors.getSurfaceColor(context),
                onSelected: (value) async {
                  if (value == 'remove') {
                    _showRemoveDialog(
                      friend.friendId,
                      friend.friendDetails.displayName,
                    );
                  } else if (value == 'share_location') {
                    try {
                      await context
                          .read<LocationSharingCubit>()
                          .toggleFriendSharing(friend.friendId, true);
                    } catch (e) {}
                  } else if (value == 'stop_sharing') {
                    try {
                      await context
                          .read<LocationSharingCubit>()
                          .toggleFriendSharing(friend.friendId, false);
                    } catch (e) {}
                  }
                },
                itemBuilder:
                    (context) => [
                      if (!canSeeYou)
                        PopupMenuItem(
                          value: 'share_location',
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.getFoundGreenColor(context),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Share location',
                                style: TextStyle(
                                  color: AppColors.getTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (canSeeYou)
                        PopupMenuItem(
                          value: 'stop_sharing',
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_off,
                                color: AppColors.getInvestigatingYellowColor(
                                  context,
                                ),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Stop sharing',
                                style: TextStyle(
                                  color: AppColors.getTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_remove,
                              color: AppColors.getMissingRedColor(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remove friend',
                              style: TextStyle(
                                color: AppColors.getTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                child: Icon(
                  Icons.more_horiz,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await context.read<LocationSharingCubit>().sendAlert(
                        friend.friendId,
                      );
                      _showDialog('Alert sent successfully!', true);
                    } catch (e) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Send Alert',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to map screen with friend's location data
                    Navigator.pushNamed(
                      context,
                      '/map',
                      arguments: {
                        'focusOnUser': true,
                        'userId': friend.friendId,
                        'username': friend.friendDetails.username,
                        'displayName': friend.friendDetails.displayName,
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, color: AppColors.teal, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'View',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
