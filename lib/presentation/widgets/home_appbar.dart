import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/data/repositories/profile_repo.dart';
import 'package:find_them/logic/cubit/profile_cubit.dart';
import 'package:find_them/presentation/widgets/side_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 220,
      color: AppColors.backgroundGrey,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(
                Icons.menu,
                size: 24,
                color: AppColors.darkGreen,
              ),
              onPressed: () {
                _showSideBar(context);
              },
            ),
          ),

          Positioned(
            top: 70,
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                'assets/images/text_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSideBar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return BlocProvider(
          create: (_) => ProfileCubit(ProfileRepository())..loadProfile(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Row(
              children: [
                const SideBar(),

                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
