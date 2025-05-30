import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/data/models/submitted_case.dart';
import 'package:find_them/logic/cubit/user_submitted_cases_cubit.dart';
import 'package:find_them/logic/cubit/case_updates_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:find_them/data/models/enum.dart';
import 'package:find_them/presentation/helpers/localisation_extenstion.dart';

Color _getStatusColor(SubmissionStatus status, BuildContext context) {
  switch (status.value) {
    case 'active':
      return AppColors.getMissingRedColor(context);
    case 'in_progress':
      return AppColors.getInvestigatingYellowColor(context);
    case 'closed':
      return AppColors.getFoundGreenColor(context);
    case 'rejected':
      return AppColors.getSecondaryTextColor(context);
    default:
      return AppColors.getSecondaryTextColor(context);
  }
}

Color _getStatusBackgroundColor(SubmissionStatus status, BuildContext context) {
  switch (status.value) {
    case 'active':
      return AppColors.getMissingRedBackground(context);
    case 'in_progress':
      return AppColors.getInvestigatingYellowBackground(context);
    case 'closed':
      return AppColors.getFoundGreenBackground(context);
    case 'rejected':
      return AppColors.getDividerColor(context);
    default:
      return AppColors.getBackgroundColor(context);
  }
}

String _getStatusText(SubmissionStatus status, BuildContext context) {
  switch (status.value) {
    case 'active':
      return context.l10n.active;
    case 'in_progress':
      return context.l10n.inProgress;
    case 'closed':
      return context.l10n.closed;
    case 'rejected':
      return context.l10n.rejected;
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
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.getTextColor(context),
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  Center(
                    child: Text(
                      context.l10n.mySubmittedCases,
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
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
                    return Center(
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
                            color: AppColors.getMissingRedColor(context),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${context.l10n.error}: ${state.message}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.getTextColor(context),
                            ),
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
                            child: Text(
                              context.l10n.retry,
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
                              color: AppColors.getSecondaryTextColor(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.l10n.noSubmittedCases,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.getTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.noSubmittedCasesMessage,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.getSecondaryTextColor(context),
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
                      color: AppColors.teal,
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

                  return Center(
                    child: Text(
                      context.l10n.unknownState,
                      style: TextStyle(color: AppColors.getTextColor(context)),
                    ),
                  );
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
      backgroundColor: AppColors.getCardColor(context),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.teal),
            const SizedBox(height: 16),
            Text(
              context.l10n.loadingCaseDetails,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.getTextColor(context),
              ),
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
      backgroundColor: AppColors.getCardColor(context),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.getMissingRedColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.errorLoadingDetails,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.getTextColor(context),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    context.l10n.cancel,
                    style: TextStyle(color: AppColors.teal),
                  ),
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
                  child: Text(
                    context.l10n.retry,
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

  Color _statusColor(BuildContext context) {
    return _getStatusColor(submittedCase.status, context);
  }

  Color _statusBackgroundColor(BuildContext context) {
    return _getStatusBackgroundColor(submittedCase.status, context);
  }

  String _statusText(BuildContext context) {
    return _getStatusText(submittedCase.status, context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.teal, width: 1),
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
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBackgroundColor(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusText(context),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(context),
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
                    color: AppColors.teal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${context.l10n.submittedOn} ${submittedCase.formattedSubmissionDate}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.teal,
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
                      context,
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
                    context.l10n.viewDetails,
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

  Widget _buildUpdateItem(BuildContext context, CaseUpdateItem update) {
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
              color: _statusColor(context),
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
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  update.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.getTextColor(context),
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

  Color _statusColor(BuildContext context) {
    return _getStatusColor(submittedCase.status, context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.getCardColor(context),
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
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close,
                          color: AppColors.getTextColor(context),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      context.l10n.updatesTimeline,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: AppColors.getDividerColor(context)),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (submittedCase.allUpdates.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.getSecondaryTextColor(context),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                context.l10n.noUpdatesAvailable,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.getSecondaryTextColor(
                                    context,
                                  ),
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
                                                      ? _statusColor(context)
                                                      : AppColors.getSecondaryTextColor(
                                                        context,
                                                      ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          if (!isLast)
                                            Expanded(
                                              child: Container(
                                                width: 2,
                                                color:
                                                    AppColors.getDividerColor(
                                                      context,
                                                    ),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                              ),
                                            )
                                          else
                                            const SizedBox(height: 8),
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
                                          color: AppColors.getBackgroundColor(
                                            context,
                                          ),
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
                                                color: AppColors.teal,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              update.message,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
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
