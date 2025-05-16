import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
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
              onPressed: () {},
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

  @override
  Size get preferredSize => const Size.fromHeight(108); 
}
