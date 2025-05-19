import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/core/constants/themes/app_text.dart';
import 'package:find_them/logic/cubit/case_list_cubit.dart';

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
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String? _dateErrorMessage;

  @override
  void initState() {
    super.initState();
    final currentFilters = context.read<CaseCubit>().currentFilters;

    if (currentFilters.ageMin != null && currentFilters.ageMax != null) {
      if (currentFilters.ageMin == 0 && currentFilters.ageMax == 18) {
        _selectedAgeRange = '0-18';
      } else if (currentFilters.ageMin == 19 && currentFilters.ageMax == 25) {
        _selectedAgeRange = '19-25';
      } else if (currentFilters.ageMin == 26) {
        _selectedAgeRange = '>25';
      }
    }

    _selectedGender = currentFilters.gender;

    if (currentFilters.status != null) {
      _selectedStatuses = [currentFilters.status!];
    }

    if (currentFilters.startDate != null) {
      _startDate = _parseDate(currentFilters.startDate!);
      _startDateController.text = _formatDateDisplay(_startDate!);
    }

    if (currentFilters.endDate != null) {
      _endDate = _parseDate(currentFilters.endDate!);
      _endDateController.text = _formatDateDisplay(_endDate!);
    }
    _validateDates();
  }

  bool _validateDates() {
    bool isValid = true;

    setState(() {
      _dateErrorMessage = null;

      if (_startDate != null && _endDate != null) {
        if (_endDate!.isBefore(_startDate!)) {
          _dateErrorMessage = 'End date cannot be before start date';
          isValid = false;
        }
      }

      if (_endDate != null && isValid) {
        if (_endDate!.isAfter(DateTime.now())) {
          _dateErrorMessage = 'End date cannot be in the future';
          isValid = false;
        }
      }
    });

    return _dateErrorMessage == null;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatDateDisplay(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _selectedAgeRange = null;
      _selectedGender = null;
      _selectedStatuses = [];
      _startDate = null;
      _endDate = null;
      _startDateController.clear();
      _endDateController.clear();
      _dateErrorMessage = null;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate
              ? (_startDate ?? DateTime.now())
              : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.darkGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = _formatDateDisplay(picked);
        } else {
          _endDate = picked;
          _endDateController.text = _formatDateDisplay(picked);
        }
        _validateDates();
      });
    }
  }

  void _applyFilters() {
    if (!_validateDates()) {
      return;
    }

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

    String? startDateStr = _startDate != null ? _formatDate(_startDate!) : null;
    String? endDateStr = _endDate != null ? _formatDate(_endDate!) : null;

    context.read<CaseCubit>().updateFilter(
      ageMin: ageMin,
      ageMax: ageMax,
      gender: _selectedGender,
      status: _selectedStatuses.isNotEmpty ? _selectedStatuses[0] : null,
      startDate: startDateStr,
      endDate: endDateStr,
      clearAgeMin: ageMin == null,
      clearAgeMax: ageMax == null,
      clearGender: _selectedGender == null,
      clearStatus: _selectedStatuses.isEmpty,
      clearStartDate: startDateStr == null,
      clearEndDate: endDateStr == null,
    );

    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      color: const Color(0xFFD8F3D6),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 24),

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

                    const SizedBox(height: 24),

                    _buildSectionHeader('Date Range'),
                    const SizedBox(height: 12),

                    Text(
                      'Start Date',
                      style: AppTextStyles.bodyMedium(context),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.darkGreen.withOpacity(0.5),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _startDate != null
                                  ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"
                                  : "Select start date",
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color:
                                    _startDate != null
                                        ? Colors.black
                                        : Colors.grey,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.darkGreen,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text('End Date', style: AppTextStyles.bodyMedium(context)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.darkGreen.withOpacity(0.5),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _endDate != null
                                  ? "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}"
                                  : "Select end date",
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color:
                                    _endDate != null
                                        ? Colors.black
                                        : Colors.grey,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.darkGreen,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_dateErrorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _dateErrorMessage!,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

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
            _selectedStatuses = [value];
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
