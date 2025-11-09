import 'package:flutter/material.dart';

/// Resilient background image with graceful fallback if decoding fails (e.g. corrupted PNG on web).
class BackgroundImage extends StatelessWidget {
  final String assetPath;
  final BoxFit fit;
  final Color fallbackColor;
  final Widget? overlay;

  const BackgroundImage(
    this.assetPath, {
    super.key,
    this.fit = BoxFit.cover,
    this.fallbackColor = Colors.black,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          assetPath,
          fit: fit,
          errorBuilder: (context, error, stack) {
            return Container(color: fallbackColor);
          },
        ),
        if (overlay != null) Positioned.fill(child: overlay!),
      ],
    );
  }
}
