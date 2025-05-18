import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/core/constants/themes/app_text.dart';
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/models/enum.dart';
import 'package:find_them/logic/cubit/case_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CaseDetailScreen extends StatefulWidget {
  final int caseId;

  const CaseDetailScreen({
    Key? key,
    required this.caseId,
  }) : super(key: key);

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the case details when the screen initializes
    context.read<CaseCubit>().getCaseWithUpdates(widget.caseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: BlocBuilder<CaseCubit, CaseListState>(
        builder: (context, state) {
          if (state is CaseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CaseError) {
            return Center(child: Text(state.message));
          } else if (state is CaseDetailLoaded) {
            final caseData = state.caseData;
            return _buildCaseDetail(context, caseData);
          }
          
          return const Center(child: Text('Case not found'));
        },
      ),
    );
  }
  
  Widget _buildCaseDetail(BuildContext context, Case caseData) {
    return SafeArea(
      child: Column(
        children: [
          // Header with back button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Case detail content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Person photo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkGreen, width: 2),
                      image: DecorationImage(
                        image: caseData.photo.isNotEmpty
                          ? NetworkImage(caseData.photo)
                          : const AssetImage('assets/images/profile.png') as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Full name
                  Text(
                    caseData.fullName,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Age and Status badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoBadge(
                        caseData.age.toString(),
                        caseData.gender.value,
                        Colors.grey[300]!,
                      ),
                      const SizedBox(width: 12),
                      _buildStatusBadge(caseData.status.value),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Days missing/found/investigating badge
                  _buildDaysInfoBox(caseData),
                  
                  const SizedBox(height: 24),
                  
                  // Case information section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Case Information',
                          style: AppTextStyles.titleMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Last seen date:', '${caseData.lastSeenDate.day}/${caseData.lastSeenDate.month}/${caseData.lastSeenDate.year}'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Last seen location:', caseData.lastSeenLocation),
                        
                        if (caseData.description.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Description:',
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            caseData.description,
                            style: AppTextStyles.bodyMedium(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Updates section
                  if (caseData.updates != null && caseData.updates!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Updates',
                            style: AppTextStyles.titleMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: caseData.updates!.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final update = caseData.updates![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          update.formattedDate,
                                          style: AppTextStyles.bodySmall(context).copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      update.message,
                                      style: AppTextStyles.bodyMedium(context),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Share case action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Share Case',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Submit information action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Submit Information',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String age, String gender, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$age years • $gender',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
  
  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor = Colors.white;
    
    switch (status.toLowerCase()) {
      case 'missing':
        badgeColor = AppColors.missingRed;
        break;
      case 'under_investigation':
        badgeColor = AppColors.investigatingYellow;
        textColor = Colors.black87;
        break;
      case 'found':
        badgeColor = AppColors.foundGreen;
        break;
      default:
        badgeColor = Colors.grey;
    }
    
    String displayStatus = status.replaceAll('_', ' ');
    if (displayStatus == 'under investigation') {
      displayStatus = 'Investigating';
    } else {
      displayStatus = displayStatus.substring(0, 1).toUpperCase() + displayStatus.substring(1);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayStatus,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
  
  Widget _buildDaysInfoBox(Case caseData) {
    Color backgroundColor;
    Color iconColor;
    IconData iconData;
    String message;
    
    switch (caseData.status.value.toLowerCase()) {
      case 'missing':
        backgroundColor = AppColors.missingRedBackground;
        iconColor = AppColors.missingRed;
        iconData = Icons.warning_amber_rounded;
        message = 'Missing for ${caseData.daysMissing} days';
        break;
      case 'under_investigation':
        backgroundColor = AppColors.investigatingYellowBackground;
        iconColor = AppColors.investigatingYellow;
        iconData = Icons.search;
        message = 'Investigating for ${caseData.daysMissing} days';
        break;
      case 'found':
        backgroundColor = AppColors.foundGreenBackground;
        iconColor = AppColors.foundGreen;
        iconData = Icons.check_circle;
        message = 'Found after ${caseData.daysMissing} days';
        break;
      default:
        backgroundColor = Colors.grey[200]!;
        iconColor = Colors.grey;
        iconData = Icons.info;
        message = 'Status: ${caseData.status.value}';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: iconColor),
          const SizedBox(width: 12),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium(context),
          ),
        ),
      ],
    );
  }
}