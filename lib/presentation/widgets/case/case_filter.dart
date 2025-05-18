import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/core/constants/themes/app_text.dart';
import 'package:find_them/logic/cubit/case_list_cubit.dart';
import 'package:find_them/logic/cubit/case_filter_state.dart';

class FilterDrawer extends StatefulWidget {
  final Function onClose;

  const FilterDrawer({Key? key, required this.onClose}) : super(key: key);

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  String? _selectedAgeRange;
  String? _selectedGender;
  List<String> _selectedStatuses = [];

  @override
  void initState() {
    super.initState();
    // Initialize filters from current state
    final currentFilters = context.read<CaseCubit>().currentFilters;

    // Set age range
    if (currentFilters.ageMin != null && currentFilters.ageMax != null) {
      if (currentFilters.ageMin == 0 && currentFilters.ageMax == 18) {
        _selectedAgeRange = '0-18';
      } else if (currentFilters.ageMin == 19 && currentFilters.ageMax == 25) {
        _selectedAgeRange = '19-25';
      } else if (currentFilters.ageMin == 26) {
        _selectedAgeRange = '>25';
      }
    }

    // Set gender
    _selectedGender = currentFilters.gender;

    // Set status
    if (currentFilters.status != null) {
      _selectedStatuses = [currentFilters.status!];
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedAgeRange = null;
      _selectedGender = null;
      _selectedStatuses = [];
    });
  }

  void _applyFilters() {
    // Convert selected age range to min/max values
    int? ageMin;
    int? ageMax;

    if (_selectedAgeRange == '0-18') {
      ageMin = 0;
      ageMax = 18;
    } else if (_selectedAgeRange == '19-25') {
      ageMin = 19;
      ageMax = 25;
    } else if (_selectedAgeRange == '>25') {
      ageMin = 26;
      ageMax = null;
    }

    // Apply filters
    context.read<CaseCubit>().updateFilter(
      ageMin: ageMin,
      ageMax: ageMax,
      gender: _selectedGender,
      status: _selectedStatuses.isNotEmpty ? _selectedStatuses[0] : null,
      clearAgeMin: ageMin == null,
      clearAgeMax: ageMax == null,
      clearGender: _selectedGender == null,
      clearStatus: _selectedStatuses.isEmpty,
    );

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      color: const Color(0xFFD8F3D6), // Light mint background
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => widget.onClose(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    'Filter searching',
                    style: AppTextStyles.bodyLarge(
                      context,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    child: Text(
                      'Reset',
                      style: AppTextStyles.bodyMedium(
                        context,
                      ).copyWith(color: AppColors.darkGreen),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Age Range section
              _buildSectionHeader('Age Range'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAgeRangeChip('0-18'),
                  const SizedBox(width: 8),
                  _buildAgeRangeChip('19-25'),
                  const SizedBox(width: 8),
                  _buildAgeRangeChip('>25'),
                ],
              ),

              const SizedBox(height: 24),

              // Gender section
              _buildSectionHeader('Gender'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildGenderChip('Female'),
                  const SizedBox(width: 8),
                  _buildGenderChip('Male'),
                ],
              ),

              const SizedBox(height: 24),

              // Status section
              _buildSectionHeader('Status'),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildStatusChip('missing', 'Missing', Colors.red),
                  const SizedBox(height: 8),
                  _buildStatusChip(
                    'under_investigation',
                    'Investigating',
                    Colors.amber,
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip('found', 'Found', Colors.green),
                ],
              ),

              const Spacer(),

              // Apply filter button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Apply filter',
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge(
        context,
      ).copyWith(fontWeight: FontWeight.w500),
    );
  }

  Widget _buildAgeRangeChip(String range) {
    final isSelected = _selectedAgeRange == range;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAgeRange = isSelected ? null : range;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkGreen),
        ),
        child: Text(
          range,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.darkGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(String gender) {
    final isSelected = _selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = isSelected ? null : gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkGreen),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.darkGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String value, String label, Color dotColor) {
    final isSelected = _selectedStatuses.contains(value);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedStatuses.remove(value);
          } else {
            _selectedStatuses = [value]; // Only allow one status at a time
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? dotColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
