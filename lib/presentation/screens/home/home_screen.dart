import 'package:find_them/presentation/screens/report/report_screen.dart';
import 'package:find_them/presentation/widgets/case/case_card.dart';
import 'package:find_them/presentation/widgets/case/case_filter.dart';
import 'package:find_them/presentation/widgets/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/core/constants/themes/app_text.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:find_them/logic/cubit/case_list_cubit.dart';
import 'package:find_them/presentation/helpers/localisation_extenstion.dart';
//import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  String _searchQuery = '';
  // ignore: unused_field
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<CaseCubit>().getCases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ignore: unused_element
  void _onNavItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Report1Screen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    context.read<CaseCubit>().searchByNameOrLocation(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.getBackgroundColor(context),

      endDrawer: FilterDrawer(
        onClose: () {
          Navigator.pop(context);
        },
      ),

      body: Column(
        children: [
          const HomeAppBar(),

          const SizedBox(height: 10),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(context),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.grey,
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: AppTextStyles.bodyMedium(
                          context,
                        ).copyWith(color: AppColors.getTextColor(context)),
                        decoration: InputDecoration(
                          hintText: context.l10n.search,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          border: InputBorder.none,
                          hintStyle: AppTextStyles.bodyMedium(context).copyWith(
                            color: AppColors.getSecondaryTextColor(context),
                          ),
                        ),
                        onSubmitted: _onSearch,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: AppColors.teal),
                      onPressed: () {
                        _onSearch(_searchController.text);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_list, color: AppColors.teal),
                      onPressed: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          Expanded(
            child: BlocBuilder<CaseCubit, CaseListState>(
              builder: (context, state) {
                return CaseListWidget(
                  cases: state is CaseLoaded ? state.cases : [],
                  isLoading: state is CaseLoading,
                  errorMessage: state is CaseError ? state.message : null,
                  onCaseTap: (caseId) {},
                  onRefresh: () {
                    context.read<CaseCubit>().getCases();
                  },
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 0),
        child: ButtomNavBar(currentIndex: 0),
      ),
    );
  }
}
