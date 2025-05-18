import 'package:flutter/material.dart';
import '../../core/constants/themes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        color: AppColors.lighterMint,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, 
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 34,
              top: 90,
            ), 
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34, 
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
                const SizedBox(width: 16), 
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, 
                  children: [
                    Text(
                      'Sophia Rose',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      '@username',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          const Divider(height: 1, thickness: 1),
          _buildMenuItemWithImageIcon(
            0,
            'assets/icons/submit.png',
            'assets/icons/submitF.png',
            'My submitted cases',
          ),
          _buildMenuItemWithImageIcon(
            1,
            'assets/icons/location.png',
            'assets/icons/locationF.png',
            'Location sharing',
          ),
          _buildMenuItemWithImageIcon(
            2,
            'assets/icons/notification.png',
            'assets/icons/notificationF.png',
            'Notifications',
          ),
          _buildMenuItemWithImageIcon(
            3,
            'assets/icons/logout.png',
            'assets/icons/logoutF.png',
            'Log out',
          ),
          const Spacer(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    int index,
    IconData outlinedIcon,
    IconData filledIcon,
    String title,
  ) {
    bool isSelected = index == _selectedIndex;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        Future.delayed(Duration(milliseconds: 150), () {
          Navigator.pop(context);
        });
      },
      onHover: (hovering) {
        if (hovering && !isSelected) {
          setState(() {
            _selectedIndex = index;
          });
        } else if (!hovering && isSelected) {
          setState(() {
            _selectedIndex = -1;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected ? AppColors.darkGreen : Colors.black,
            size: 24,
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color: isSelected ? AppColors.darkGreen : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemWithImageIcon(
    int index,
    String outlinedIconPath,
    String filledIconPath,
    String title,
  ) {
    bool isSelected = index == _selectedIndex;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        Future.delayed(Duration(milliseconds: 150), () {
          Navigator.pop(context);
        });
      },
      onHover: (hovering) {
        if (hovering && !isSelected) {
          setState(() {
            _selectedIndex = index;
          });
        } else if (!hovering && isSelected) {
          setState(() {
            _selectedIndex = -1;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Image.asset(
            isSelected ? filledIconPath : outlinedIconPath,
            width: 24,
            height: 24,
            color: isSelected ? AppColors.darkGreen : Colors.black,
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color: isSelected ? AppColors.darkGreen : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
