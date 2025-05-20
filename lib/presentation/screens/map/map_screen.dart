import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:find_them/presentation/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 48.0,
              left: 31.0,
              right: 31.0,
              bottom: 16,
            ),
            child: Column(
              children: [
                const Text(
                  'Map view',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterOptions(),
              ],
            ),
          ),
          Expanded(child: _buildMapContainer()),
          ButtomNavBar(currentIndex: 1),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Row(
      children: [
        Expanded(child: _buildFilterButton('All')),
        const SizedBox(width: 8),
        Expanded(child: _buildFilterButton('Missing persons')),
        const SizedBox(width: 8),
        Expanded(child: _buildFilterButton('Location sharing')),
      ],
    );
  }

  Widget _buildFilterButton(String label) {
    final isSelected = _selectedFilter == label;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.darkGreen : AppColors.teal,
        foregroundColor: isSelected ? AppColors.white : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label),
    );
  }

  Widget _buildMapContainer() {
    return Container(color: AppColors.white);
  }
}
