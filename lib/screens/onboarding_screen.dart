import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/primary_button.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const OnboardingPage(
        backgroundAsset: 'assets/images/bg1.jpg',
        title: 'Learn\nsomething\nnew with\nevery swipe.',
      ),
      const OnboardingPage(
        backgroundAsset: 'assets/images/bg2.jpg',
        title: 'Endless\nknowledge,\nendlessly\nscrolling.',
      ),
      OnboardingPage(
        backgroundAsset: 'assets/images/bg3.jpg',
        title: 'Welcome to\nWikiScrolls!',
        body:
            'WikiScrolls transforms fascinating articles from across the world\'s largest encyclopedia into bite-sized, engaging video summaries. Swipe through history, science, and culture—and make your scrolling time learning time.',
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: pages,
          ),
          // Bottom panel: indicator + CTA + footer
          Positioned.fill(
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SmoothPageIndicator(
                        controller: _controller,
                        count: pages.length,
                        effect: ExpandingDotsEffect(
                          expansionFactor: 3,
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor:
                              Theme.of(context).colorScheme.primary,
                          dotColor: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(label: 'Get Started', onPressed: _goToHome),
                      const SizedBox(height: 8),
                      Opacity(
                        opacity: 0.75,
                        child: Column(
                          children: [
                            Text('Terms and Conditions Apply',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.white)),
                            Text('© WikiScrolls Team, 2025',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
