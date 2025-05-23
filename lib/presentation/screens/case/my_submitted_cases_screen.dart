import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/data/models/submitted_case.dart';
import 'package:find_them/logic/cubit/user_submitted_cases_cubit.dart';
import 'package:find_them/logic/cubit/case_updates_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:find_them/data/models/enum.dart';

Color _getStatusColor(SubmissionStatus status) {
  switch (status.value) {
    case 'active':
      return AppColors.missingRed;
    case 'in_progress':
      return AppColors.investigatingYellow;
    case 'closed':
      return AppColors.foundGreen;
    case 'rejected':
      return Colors.grey;
    default:
      return AppColors.grey;
  }
}

String _getStatusText(SubmissionStatus status) {
  switch (status.value) {
    case 'active':
      return 'Active';
    case 'in_progress':
      return 'In Progress';
    case 'closed':
      return 'Closed';
    case 'rejected':
      return 'Rejected';
    default:
      return status.value;
  }
}

class SubmittedCasesScreen extends StatefulWidget {
  const SubmittedCasesScreen({super.key});

  @override
  State<SubmittedCasesScreen> createState() => _SubmittedCasesScreenState();
}

class _SubmittedCasesScreenState extends State<SubmittedCasesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserSubmittedCasesCubit>().getSubmittedCases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'My submitted cases',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<
                UserSubmittedCasesCubit,
                UserSubmittedCasesState
              >(
                builder: (context, state) {
                  if (state is UserSubmittedCasesLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.teal),
                    );
                  } else if (state is UserSubmittedCasesError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<UserSubmittedCasesCubit>()
                                  .getSubmittedCases();
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
                  } else if (state is UserSubmittedCasesLoaded) {
                    if (state.cases.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: AppColors.darkGreen.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No submitted cases',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You haven\'t submitted any missing person reports yet.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<UserSubmittedCasesCubit>()
                            .getSubmittedCases();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: state.cases.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return SubmittedCaseCard(
                            submittedCase: state.cases[index],
                            onTap: () {
                              _showCaseDetails(context, state.cases[index]);
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const Center(child: Text('Unknown state'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCaseDetails(BuildContext context, SubmittedCase submittedCase) {
    final caseUpdatesCubit = context.read<CaseUpdatesCubit>();

    caseUpdatesCubit.getCaseWithUpdates(submittedCase.id);

    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: caseUpdatesCubit,
            child: BlocBuilder<CaseUpdatesCubit, CaseUpdatesState>(
              builder: (context, state) {
                if (state is CaseUpdatesLoaded) {
                  return CaseDetailsDialog(
                    submittedCase: state.caseWithUpdates,
                  );
                } else if (state is CaseUpdatesLoading) {
                  return _buildLoadingDialog(context);
                } else if (state is CaseUpdatesError) {
                  return _buildErrorDialog(
                    context,
                    state.message,
                    submittedCase,
                  );
                } else {
                  return CaseDetailsDialog(submittedCase: submittedCase);
                }
              },
            ),
          ),
    ).then((_) {
      caseUpdatesCubit.reset();
    });
  }

  Widget _buildLoadingDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.teal),
            const SizedBox(height: 16),
            Text(
              'Loading case details...',
              style: GoogleFonts.inter(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDialog(
    BuildContext context,
    String message,
    SubmittedCase fallbackCase,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading details',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<CaseUpdatesCubit>().getCaseWithUpdates(
                      fallbackCase.id,
                    );
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
          ],
        ),
      ),
    );
  }
}

class SubmittedCaseCard extends StatelessWidget {
  final SubmittedCase submittedCase;
  final VoidCallback onTap;

  const SubmittedCaseCard({
    super.key,
    required this.submittedCase,
    required this.onTap,
  });

  Color get _statusColor {
    return _getStatusColor(submittedCase.status);
  }

  Color get _statusBackgroundColor {
    switch (submittedCase.status.value) {
      case 'active':
        return AppColors.missingRedBackground;
      case 'in_progress':
        return AppColors.investigatingYellowBackground;
      case 'closed':
        return AppColors.foundGreenBackground;
      case 'rejected':
        return Colors.grey.shade200;
      default:
        return AppColors.backgroundGrey;
    }
  }

  String get _statusText {
    return _getStatusText(submittedCase.status);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lighterMint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkGreen, width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      submittedCase.fullName,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusText,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.darkGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Submitted on ${submittedCase.formattedSubmissionDate}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),

            if (submittedCase.latestUpdate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildUpdateItem(
                      CaseUpdateItem(
                        message: submittedCase.latestUpdate!.message,
                        date: submittedCase.latestUpdate!.parsedDate,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View details',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateItem(CaseUpdateItem update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  update.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black,
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

class CaseDetailsDialog extends StatelessWidget {
  final SubmittedCase submittedCase;

  const CaseDetailsDialog({super.key, required this.submittedCase});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          submittedCase.fullName,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Updates Timeline',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.grey[300]),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (submittedCase.allUpdates.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No updates available yet.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children:
                            submittedCase.allUpdates.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final update = entry.value;
                              final isLast =
                                  index == submittedCase.allUpdates.length - 1;
                              final isLatest = index == 0;
                              return IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                      width: 12,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color:
                                                  isLatest
                                                      ? _getStatusColor(
                                                        submittedCase.status,
                                                      )
                                                      : Colors
                                                          .grey, 
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          if (!isLast)
                                            Expanded(
                                              child: Container(
                                                width: 2,
                                                color: Colors.grey[300],
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                              ),
                                            )
                                          else
                                            const SizedBox(
                                              height: 8,
                                            ), 
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(
                                          bottom: isLast ? 0 : 16,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroundGrey,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              update.formattedDate,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.darkGreen,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              update.message,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
