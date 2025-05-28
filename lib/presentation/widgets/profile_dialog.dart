import 'package:flutter/material.dart';
import 'package:find_them/core/constants/themes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileDialog extends StatelessWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback? onDismiss;

  const ProfileDialog({
super.key
,    required this.message,
    this.isSuccess = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.black,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check : Icons.close,
              color: isSuccess ? Colors.green : Colors.red,
              size: 35,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            message,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 100,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDismiss != null) {
                  onDismiss!();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showProfileDialog({
  required BuildContext context,
  required String message,
  bool isSuccess = true,
  VoidCallback? onDismiss,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ProfileDialog(
        message: message,
        isSuccess: isSuccess,
        onDismiss: onDismiss,
      );
    },
  );
}