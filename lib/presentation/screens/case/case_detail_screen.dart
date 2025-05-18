import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/core/constants/themes/app_text.dart';
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/models/enum.dart';
import 'package:find_them/logic/cubit/case_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CaseDetailScreen extends StatefulWidget {
  final int caseId;

  const CaseDetailScreen({Key? key, required this.caseId}) : super(key: key);

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CaseCubit>().getCaseDetail(widget.caseId);
  }

  void _makePhoneCall(String phoneNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
                    launchUrl(phoneUri);
                  },
                  icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                  label: const Text(
                    'Call +222 31310909',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
    const String phoneNumber = '+22231310909';

    String formattedDate = '';
    try {
      final DateTime date = caseData.lastSeenDate;
      formattedDate = DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      formattedDate =
          '${caseData.lastSeenDate.day}/${caseData.lastSeenDate.month}/${caseData.lastSeenDate.year}';
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 364,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.lighterMint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 70),

                            Text(
                              caseData.fullName,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 80),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildAgeBadge(caseData.age.toString()),
                                  const SizedBox(width: 10),
                                  _buildStatusBadge(caseData.status.value),
                                  const SizedBox(width: 10),
                                  _buildGenderBadge(caseData.gender.value),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                            SizedBox(
                              width: 248,
                              height: 60,
                              child: _buildDaysInfoBox(caseData),
                            ),

                            const SizedBox(height: 26),
                            const Text(
                              'Case Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 26),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.lighterMint,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_today,
                                            size: 18,
                                            color: AppColors.darkGreen,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Last seen date:',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.lighterMint,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.location_on,
                                            size: 18,
                                            color: AppColors.darkGreen,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Last seen location:',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                caseData.lastSeenLocation,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 26),
                            if (caseData.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Description:',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        caseData.description,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  child: Container(
                    width: 198,
                    height: 185,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkGreen, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      image: DecorationImage(
                        image:
                            caseData.photo.isNotEmpty
                                ? NetworkImage(caseData.photo)
                                : const AssetImage('assets/images/profile.png')
                                    as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Leave information action - empty for now
                      },
                      child: const Text(
                        'Leave an information',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                SizedBox(
                  height: 48,
                  width: 48,
                  child: ElevatedButton(
                    onPressed: () => _makePhoneCall('+22231310909'),
                    child: const Icon(Icons.phone, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: AppColors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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

  Widget _buildAgeBadge(String age) {
    return Container(
      width: 80,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: age,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextSpan(
                text: ' years old',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderBadge(String gender) {
    return Container(
      width: 80,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          gender,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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
      displayStatus =
          displayStatus.substring(0, 1).toUpperCase() +
          displayStatus.substring(1);
    }

    return Container(
      width: 124,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          displayStatus,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
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
        iconData = Icons.error_outline;
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: iconColor, size: 20),
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
}
