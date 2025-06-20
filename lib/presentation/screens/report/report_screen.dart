import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:find_them/presentation/helpers/localisation_extenstion.dart';

class Report1Screen extends StatefulWidget {
  const Report1Screen({super.key});

  @override
  State<Report1Screen> createState() => _Report1ScreenState();
}

class _Report1ScreenState extends State<Report1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _continueToNextStep() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushNamed(
        context,
        '/report2',
        arguments: {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'gender': _selectedGender ?? 'Male',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getSurfaceColor(context),
      appBar: AppBar(
        title: Text(
          context.l10n.reportingMissingPerson,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.getTextColor(context),
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.getSurfaceColor(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.getTextColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        // CHANGE 1: Column instead of SingleChildScrollView
        children: [
          // CHANGE 2: Wrap content in Expanded + SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStepCircle(1, true),
                          _buildStepLine(true),
                          _buildStepCircle(2, false),
                          _buildStepLine(false),
                          _buildStepCircle(3, false),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Center(
                        child: Text(
                          context.l10n.basicInformation,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        context.l10n.firstName,
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          hintText: context.l10n.enterFirstNameHere,
                          filled: true,
                          fillColor: AppColors.getSurfaceColor(context),
                          hintStyle: TextStyle(
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.getDividerColor(context),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.getDividerColor(context),
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.pleaseEnterFirstName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      Text(
                        context.l10n.lastName,
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          hintText: context.l10n.enterLastNameHere,
                          filled: true,
                          fillColor: AppColors.getSurfaceColor(context),
                          hintStyle: TextStyle(
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.getDividerColor(context),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.getDividerColor(context),
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.pleaseEnterLastName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      Text(
                        context.l10n.age,
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: '123',
                          filled: true,
                          fillColor: AppColors.getSurfaceColor(context),
                          hintStyle: TextStyle(
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.getDividerColor(context),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: AppColors.getDividerColor(context),
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.pleaseEnterAge;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      Text(
                        context.l10n.gender,
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Male',
                            groupValue: _selectedGender,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                            },
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              Set<WidgetState> states,
                            ) {
                              return AppColors.teal;
                            }),
                          ),
                          Text(
                            context.l10n.male,
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                          const SizedBox(width: 40),
                          Radio<String>(
                            value: 'Female',
                            groupValue: _selectedGender,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                            },
                            fillColor: WidgetStateProperty.resolveWith<Color>((
                              Set<WidgetState> states,
                            ) {
                              return AppColors.teal;
                            }),
                          ),
                          Text(
                            context.l10n.female,
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                        ],
                      ),

                      // CHANGE 3: Add extra bottom padding for scroll clearance
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // CHANGE 4: NEW - Fixed button area at bottom
          Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              100,
            ), // More bottom padding
            color: AppColors.getSurfaceColor(
              context,
            ), // Simple color, no shadow
            child: Center(
              child: SizedBox(
                width: 248,
                height: 50,
                child: ElevatedButton(
                  onPressed: _continueToNextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    context.l10n.continueLabel,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: ButtomNavBar(currentIndex: 2),
      ),
    );
  }

  Widget _buildStepCircle(int step, bool isActive) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.teal : AppColors.getSurfaceColor(context),
        border: Border.all(color: AppColors.teal, width: 2),
      ),
      child: Center(
        child: Text(
          '$step',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppColors.teal,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 50,
      height: 2,
      color: isActive ? AppColors.teal : AppColors.getDividerColor(context),
    );
  }
}
