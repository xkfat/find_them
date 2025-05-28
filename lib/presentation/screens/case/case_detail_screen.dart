import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/data/models/case.dart';
import 'package:find_them/data/models/enum.dart';
import 'package:find_them/logic/cubit/case_list_cubit.dart';
import 'package:find_them/logic/cubit/report_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CaseDetailScreen extends StatefulWidget {
  final int caseId;

  const CaseDetailScreen({super.key, required this.caseId});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CaseCubit>().getCaseDetail(widget.caseId);
  }

  void _showReportDialog(BuildContext context, int caseId) {
    final TextEditingController noteController = TextEditingController();
    final reportCubit = context.read<ReportCubit>();

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setState) {
              bool isSubmitting = false;

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: AppColors.getSurfaceColor(context),
                elevation: 8,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Leave an information',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: AppColors.getSecondaryTextColor(context),
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Please provide any information you have about this missing person, and help us find other people loved ones.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.getSecondaryTextColor(context),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.getCardColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.teal, width: 1),
                        ),
                        child: TextField(
                          controller: noteController,
                          maxLines: 7,
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write your message here...',
                            hintStyle: TextStyle(
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                            contentPadding: EdgeInsets.all(16),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              isSubmitting
                                  ? null
                                  : () async {
                                    if (noteController.text.trim().isEmpty) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              backgroundColor:
                                                  AppColors.getSurfaceColor(
                                                    context,
                                                  ),
                                              title: Text(
                                                'Missing Information',
                                                style: TextStyle(
                                                  color: AppColors.getTextColor(
                                                    context,
                                                  ),
                                                ),
                                              ),
                                              content: Text(
                                                'Please enter some information',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.getSecondaryTextColor(
                                                        context,
                                                      ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: Text(
                                                    'OK',
                                                    style: TextStyle(
                                                      color: AppColors.teal,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      isSubmitting = true;
                                    });

                                    try {
                                      await reportCubit.submitReport(
                                        caseId: caseId,
                                        note: noteController.text.trim(),
                                      );

                                      Navigator.pop(dialogContext);

                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => Dialog(
                                              backgroundColor:
                                                  AppColors.getSurfaceColor(
                                                    context,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  20.0,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.favorite,
                                                      color:
                                                          AppColors.getFoundGreenColor(
                                                            context,
                                                          ),
                                                      size: 60,
                                                    ),
                                                    SizedBox(height: 16),
                                                    Text(
                                                      'Thank You!',
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors.getTextColor(
                                                              context,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'for trying to help us.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            AppColors.getSecondaryTextColor(
                                                              context,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 45,
                                                      child: ElevatedButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              AppColors.teal,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'OK',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      );
                                    } catch (e) {
                                      setState(() {
                                        isSubmitting = false;
                                      });

                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => Dialog(
                                              backgroundColor:
                                                  AppColors.getSurfaceColor(
                                                    context,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  20.0,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.error,
                                                      color:
                                                          AppColors.getMissingRedColor(
                                                            context,
                                                          ),
                                                      size: 60,
                                                    ),
                                                    SizedBox(height: 16),
                                                    Text(
                                                      'Submission Failed',
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            AppColors.getTextColor(
                                                              context,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'Failed to submit information. Please try again.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            AppColors.getSecondaryTextColor(
                                                              context,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 45,
                                                      child: ElevatedButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              AppColors.getMissingRedColor(
                                                                context,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'OK',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      );
                                    }
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              isSubmitting
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Submitting...',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                  : Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.getSurfaceColor(context),
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
                    'Call +222 12345678',
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
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
      backgroundColor: AppColors.getSurfaceColor(context),
      body: BlocBuilder<CaseCubit, CaseListState>(
        builder: (context, state) {
          if (state is CaseLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            );
          } else if (state is CaseError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: AppColors.getTextColor(context)),
              ),
            );
          } else if (state is CaseDetailLoaded) {
            final caseData = state.caseData;
            return _buildCaseDetail(context, caseData);
          }

          return Center(
            child: Text(
              'Case not found',
              style: TextStyle(color: AppColors.getTextColor(context)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCaseDetail(BuildContext context, Case caseData) {
    String formattedDate = '';
    try {
      final DateTime date = caseData.lastSeenDate;
      formattedDate = DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      formattedDate =
          '${caseData.lastSeenDate.year}/${caseData.lastSeenDate.month}/${caseData.lastSeenDate.day}';
    }

    return Column(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.getTextColor(context),
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 130),

                      Text(
                        caseData.fullName,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextColor(context),
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Column(
                              children: [
                                const SizedBox(height: 26),

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
                                  width: 350,
                                  height: 90,
                                  child: _buildDaysInfoBox(caseData),
                                ),

                                const SizedBox(height: 26),

                                Text(
                                  'Case Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.getTextColor(context),
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
                                      color: AppColors.getSurfaceColor(context),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.getDividerColor(
                                            context,
                                          ).withOpacity(0.3),
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.getCardColor(
                                                  context,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Icon(
                                                Icons.calendar_today,
                                                size: 24,
                                                color:
                                                    AppColors.getPrimaryColor(
                                                      context,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Last seen date:',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppColors.getSecondaryTextColor(
                                                          context,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  formattedDate,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.getTextColor(
                                                          context,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 22),

                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.getCardColor(
                                                  context,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Icon(
                                                Icons.location_on,
                                                size: 24,
                                                color:
                                                    AppColors.getPrimaryColor(
                                                      context,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Last seen location:',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.getSecondaryTextColor(
                                                            context,
                                                          ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    caseData.lastSeenLocation,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.getTextColor(
                                                            context,
                                                          ),
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
                                        color: AppColors.getSurfaceColor(
                                          context,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Description:',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color:
                                                  AppColors.getSecondaryTextColor(
                                                    context,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            caseData.description,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColors.getTextColor(
                                                context,
                                              ),
                                            ),
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
                    ],
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
                    border: Border.all(
                      color: AppColors.getPrimaryColor(context),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getDividerColor(
                          context,
                        ).withOpacity(0.3),
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
          decoration: BoxDecoration(color: AppColors.getCardColor(context)),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (caseData.id != null) {
                          _showReportDialog(context, caseData.id!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.getMissingRedColor(
                                context,
                              ),
                              content: Text(
                                'Cannot submit report: Invalid case ID',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }
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
                        backgroundColor: AppColors.getPrimaryColor(context),
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
                    onPressed: () => _makePhoneCall('+22212345678'),
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
        ),
      ],
    );
  }

  Widget _buildAgeBadge(String age) {
    return Container(
      width: 80,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.getDividerColor(context).withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: age,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextColor(context),
                ),
              ),
              TextSpan(
                text: '  years old',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.getTextColor(context),
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
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.getDividerColor(context).withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          gender,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextColor(context),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor = AppColors.getTextColor(context);
    Color dotColor;

    switch (status.toLowerCase()) {
      case 'missing':
        badgeColor = AppColors.getMissingRedBackground(context);
        dotColor = AppColors.getMissingRedColor(context);
        break;
      case 'under_investigation':
        badgeColor = AppColors.getInvestigatingYellowBackground(context);
        dotColor = AppColors.getInvestigatingYellowColor(context);
        break;
      case 'found':
        badgeColor = AppColors.getFoundGreenBackground(context);
        dotColor = AppColors.getFoundGreenColor(context);
        break;
      default:
        badgeColor = AppColors.getDividerColor(context);
        dotColor = AppColors.getSecondaryTextColor(context);
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
      width: 150,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),

          Text(
            displayStatus,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysInfoBox(Case caseData) {
    Color backgroundColor;
    Color iconColor;
    String message;

    switch (caseData.status.value.toLowerCase()) {
      case 'missing':
        backgroundColor = AppColors.getMissingRedBackground(context);
        iconColor = AppColors.getMissingRedColor(context);
        message = 'Missing for ${caseData.daysMissing} days';
        break;
      case 'under_investigation':
        backgroundColor = AppColors.getInvestigatingYellowBackground(context);
        iconColor = AppColors.getInvestigatingYellowColor(context);
        message = 'Investigating for ${caseData.daysMissing} days';
        break;
      case 'found':
        backgroundColor = AppColors.getFoundGreenBackground(context);
        iconColor = AppColors.getFoundGreenColor(context);
        message = 'Found after ${caseData.daysMissing} days';
        break;
      default:
        backgroundColor = AppColors.getDividerColor(context);
        iconColor = AppColors.getSecondaryTextColor(context);
        message = 'Status: ${caseData.status.value}';
    }

    return Container(
      height: 60,
      width: 248,
      //padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIcons.warning_circle, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
