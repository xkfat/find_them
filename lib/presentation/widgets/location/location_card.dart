import 'package:find_them/data/models/location_request.dart';
import 'package:find_them/data/models/location_sharing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/themes/app_colors.dart';
import '../../../logic/cubit/location_sharing_cubit.dart';
import 'package:find_them/presentation/helpers/localisation_extenstion.dart';

class LocationCards extends StatelessWidget {
  final List<LocationRequestModel> requests;
  final List<LocationSharingModel> friends;
  final Function(String message, bool isSuccess) onShowDialog;

  const LocationCards({
    super.key,
    required this.requests,
    required this.friends,
    required this.onShowDialog,
  });

  @override
  Widget build(BuildContext context) {
    final allItems = <Widget>[];

    for (final request in requests) {
      allItems.add(_buildRequestCard(context, request));
    }

    for (final friend in friends) {
      allItems.add(_buildFriendCard(context, friend));
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
              context.l10n.noLocationSharingFriends,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.tapToAddFriends,
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

  Widget _buildRequestCard(BuildContext context, LocationRequestModel request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
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
                        context.l10n.locationRequest,
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
                    } catch (e) {
                      //catch
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    context.l10n.accept,
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
                    } catch (e) {
                      //catch
                    }
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
                    context.l10n.decline,
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

  Widget _buildFriendCard(BuildContext context, LocationSharingModel friend) {
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
                          isSharing
                              ? context.l10n.sharingWithYou
                              : context.l10n.notSharing,
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
                          canSeeYou
                              ? context.l10n.canSeeYou
                              : context.l10n.cannotSeeYou,
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
                      context,
                      friend.friendId,
                      friend.friendDetails.displayName,
                    );
                  } else if (value == 'share_location') {
                    try {
                      await context
                          .read<LocationSharingCubit>()
                          .toggleFriendSharing(friend.friendId, true);
                    } catch (e) {
                      //catch
                    }
                  } else if (value == 'stop_sharing') {
                    try {
                      await context
                          .read<LocationSharingCubit>()
                          .toggleFriendSharing(friend.friendId, false);
                    } catch (e) {
                      //catch
                    }
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
                                context.l10n.shareLocation,
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
                                context.l10n.stopSharing,
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
                              context.l10n.removeFriend,
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
                      onShowDialog(context.l10n.alertSentSuccessfully, true);
                    } catch (e) {
                      //catch
                    }
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
                        context.l10n.sendAlert,
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
                        context.l10n.view,
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

  void _showRemoveDialog(
    BuildContext context,
    int friendId,
    String friendName,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.getCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            context.l10n.removeFriend,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
          ),
          content: Text(
            context.l10n.areYouSureRemoveFriend(friendName),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.getTextColor(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.l10n.cancel,
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
                } catch (e) {
                  //catch
                }
              },
              child: Text(
                context.l10n.remove,
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
}
