import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PrimaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppColors.darkBrown, // darker fill for primary CTA
            foregroundColor: AppColors.lightBrown, // text matches title color
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 2,
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      );
  }
}
