import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import '../state/user_profile.dart';

class LoginSuccessScreen extends StatelessWidget {
  final String username;
  const LoginSuccessScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    // Persist username into simple session model
    UserProfile.instance.username = username;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You Have\nSuccessfully\nLogged in!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.lightBrown,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 72, color: Colors.white70),
                        const SizedBox(height: 12),
                        Text('Welcome back $username!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                        const SizedBox(height: 12),
                        Text(
                          "We're preparing your personalized 'For You' page with fascinating new topics we think you'll love. Your next learning adventure is just a swipe away.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Continue to Home', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
