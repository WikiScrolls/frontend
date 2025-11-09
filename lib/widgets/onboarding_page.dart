import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String backgroundAsset;
  final String title;
  final String? body;

  const OnboardingPage({
    super.key,
    required this.backgroundAsset,
    required this.title,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image
        DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundAsset),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Dark overlay
        Container(color: Colors.black.withOpacity(0.55)),
        // Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 10),
                // Title
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontSize: size.width * 0.12,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                      ) ??
                      TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.12,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    body!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.35,
                        ),
                  ),
                ],
                const Spacer(flex: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
