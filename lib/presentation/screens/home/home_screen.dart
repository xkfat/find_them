import 'package:find_them/presentation/widgets/case/case_card.dart';
import 'package:find_them/presentation/widgets/case/case_filter.dart';
import 'package:find_them/presentation/widgets/home_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/core/constants/themes/app_text.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:find_them/logic/cubit/case_list_cubit.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
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

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      backgroundColor: AppColors.backgroundGrey,

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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
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
                        decoration: InputDecoration(
                          hintText: 'Search',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          border: InputBorder.none,
                          hintStyle: AppTextStyles.bodyMedium(
                            context,
                          ).copyWith(color: Colors.grey),
                        ),
                        onSubmitted: _onSearch,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: AppColors.darkGreen,
                      ),
                      onPressed: () {
                        _onSearch(_searchController.text);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: AppColors.darkGreen,
                      ),
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
        child: ButtomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
        ),
      ),
    );
  }
}
