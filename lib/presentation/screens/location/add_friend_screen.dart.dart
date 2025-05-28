import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/themes/app_colors.dart';
import '../../../logic/cubit/add_friend_cubit.dart';
import 'package:find_them/data/models/user_search.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
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
                color: isSuccess ? AppColors.foundGreen : AppColors.missingRed,
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
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Navigator.of(context).pop();
                }
              },
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

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    if (value.trim().length >= 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 800), () {
        context.read<AddFriendCubit>().searchUsers(value.trim());
      });
    } else if (value.trim().isEmpty) {
      context.read<AddFriendCubit>().resetState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        
        centerTitle: true,
        title: Text(
          'Add friend',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextColor(context),
          ),
        ),
        backgroundColor: AppColors.getBackgroundColor(context),
        iconTheme: IconThemeData(color: AppColors.getTextColor(context)),
      ),
      body: BlocConsumer<AddFriendCubit, AddFriendState>(
        listener: (context, state) {
          if (state is AddFriendRequestSent) {
            _showDialog(state.message, true);
          } else if (state is AddFriendError) {
            _showDialog(state.message, false);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by username or phone number',
                    hintStyle: TextStyle(
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                    filled: true,
                    fillColor: AppColors.getSurfaceColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(color: AppColors.getTextColor(context)),
                  onChanged: _onSearchChanged,
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    _buildMainContent(state),

                    if (state is AddFriendSearching)
                      Container(
                        color: AppColors.getBackgroundColor(
                          context,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppColors.teal),
                              const SizedBox(height: 16),
                              Text(
                                'Searching users...',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: AppColors.getTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(AddFriendState state) {
    if (state is AddFriendSearchResults) {
      return _buildSearchResults(state.results);
    } else if (state is AddFriendError) {
      return _buildErrorState(state.message);
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_add,
              size: 48,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Find friends',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search by username or phone number to find\npeople you know and connect with them.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.getSecondaryTextColor(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
              context.read<AddFriendCubit>().resetState();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
            child: Text('Try Again', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<UserSearchModel> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.getSecondaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different username or phone number',
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
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = results[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(UserSearchModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal,
            ),
            child: ClipOval(
              child:
                  user.profilePhoto != null
                      ? Image.network(
                        user.profilePhoto!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/profile.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                      : Image.asset(
                        'assets/images/profile.png',
                        width: 50,
                        height: 50,
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
                  user.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                if (user.username.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(
            width: 80,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                context.read<AddFriendCubit>().sendLocationRequest(
                  user.username,
                  user.id,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Connect',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
