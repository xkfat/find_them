import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/core/constants/themes/app_text.dart';
import 'package:find_them/core/constants/strings/string_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This will be replaced with actual data from your case list implementation
  final List<Map<String, dynamic>> dummyData = [
    {'name': 'Full Name', 'date': '2023-04-11'},
    {'name': 'Full Name', 'date': '2023-04-11'},
    {'name': 'Full Name', 'date': '2023-04-11'},
    {'name': 'Full Name', 'date': '2023-04-11'},
    {'name': 'Full Name', 'date': '2023-04-11'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: AppColors.backgroundGrey,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              StringConstants.appName,
              style: AppTextStyles.headingMedium(context).copyWith(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.darkGreen),
              onPressed: () {
                // Menu functionality will go here
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
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
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.darkGreen),
                    onPressed: () {
                      // Search functionality will go here
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: AppColors.darkGreen,
                    ),
                    onPressed: () {
                      // Filter functionality will go here
                    },
                  ),
                ],
              ),
            ),
          ),

          // Case list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: dummyData.length,
              itemBuilder: (context, index) {
                return _buildPersonCard(dummyData[index]);
              },
            ),
          ),
        ],
      ),
      // We'll leave the bottom navigation implementation for later
    );
  }

  Widget _buildPersonCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.lightMint,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Profile image with circular border
            Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.darkGreen, width: 1.5),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/default_profile.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16.0),

            // Person details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full Name',
                    style: AppTextStyles.titleMedium(
                      context,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Text(
                        'Missing Date:',
                        style: TextStyle(color: Colors.black54, fontSize: 12.0),
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '2023-04-11',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Download button
            IconButton(
              icon: const Icon(Icons.download, color: AppColors.darkGreen),
              onPressed: () {
                // Download functionality will go here
              },
            ),
          ],
        ),
      ),
    );
  }
}
