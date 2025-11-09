import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const GradientButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBrown, AppColors.orangeDark],
          ),
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              // Sign Up buttons should use the same color as headings (lightBrown)
              color: AppColors.lightBrown,
            ),
          ),
        ),
      ),
    );
  }
}
