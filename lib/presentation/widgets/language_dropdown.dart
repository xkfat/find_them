import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageDropdown extends StatefulWidget {
  final String selectedLanguage;
  final Function(String) onChanged;
  final List<String> languages;

  const LanguageDropdown({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
    required this.languages,
  });

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  final GlobalKey _dropdownKey = GlobalKey();
  bool isDropdownOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    isDropdownOpen = false;
  }

  void _toggleDropdown() {
    if (isDropdownOpen) {
      _removeOverlay();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    final RenderBox renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            left: position.dx,
            top: position.dy + size.height,
            width: 90,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              child: Container(
                height: 105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children:
                      widget.languages.map((language) {
                        return InkWell(
                          onTap: () {
                            widget.onChanged(language);
                            _removeOverlay();
                          },
                          child: Container(
                            height: 35,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              language,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    isDropdownOpen = true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleDropdown,
      child: Container(
        key: _dropdownKey,
        width: 90,
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.teal,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.selectedLanguage,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            Icon(
              isDropdownOpen
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
