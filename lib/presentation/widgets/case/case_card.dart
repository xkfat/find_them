import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/logic/cubit/case_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:find_them/data/models/case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class CaseListWidget extends StatelessWidget {
  final List<Case> cases;
  final Function(int caseId) onCaseTap;
  final bool isLoading;
  final String? errorMessage;
  final Function() onRefresh;

  const CaseListWidget({
    Key? key,
    required this.cases,
    required this.onCaseTap,
    this.isLoading = false,
    this.errorMessage,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.teal));
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: TextStyle(color: AppColors.getTextColor(context)),
        ),
      );
    }

    if (cases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.getSecondaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No cases found matching your search',
              style: TextStyle(color: AppColors.getTextColor(context)),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final cubit = context.read<CaseCubit>();
                cubit.clearFilters();
                onRefresh();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
              child: Text(
                'Show All Cases',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      color: AppColors.teal,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: cases.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          return _CaseCard(
            caseData: cases[index],
            onTap: (id) {
              Navigator.pushNamed(context, '/case/details', arguments: id);
            },
          );
        },
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final Case caseData;
  final Function(int caseId) onTap;

  const _CaseCard({Key? key, required this.caseData, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (caseData.id != null) {
          onTap(caseData.id!);
        }
      },
      child: Container(
        width: 370,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.teal, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal,
                  image:
                      caseData.photo.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(caseData.photo),
                            fit: BoxFit.cover,
                          )
                          : DecorationImage(
                            image: AssetImage('assets/images/profile.png'),
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseData.fullName,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Missing from',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.getSecondaryTextColor(
                                    context,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  Icon(
                                    PhosphorIcons.calendar_x,
                                    size: 20,
                                    color: AppColors.getTextColor(context),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${caseData.lastSeenDate.day}/${caseData.lastSeenDate.month}/${caseData.lastSeenDate.year}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.getTextColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last seen',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.getSecondaryTextColor(
                                    context,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                caseData.lastSeenLocation,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.getTextColor(context),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
