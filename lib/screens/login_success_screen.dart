import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import '../state/user_profile.dart';

class LoginSuccessScreen extends StatefulWidget {
  final String username;
  const LoginSuccessScreen({super.key, required this.username});

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    UserProfile.instance.username = widget.username;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            tween: Tween<double>(begin: 0.66, end: 1.0),
            builder: (context, value, child) {
              return Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.3),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: _controller == null
            ? const SizedBox.shrink()
            : AnimatedBuilder(
                animation: _controller!,
                builder: (context, child) {
                  final fadeValue = Curves.easeIn.transform(_controller!.value);
                  final slideValue = Curves.easeOut.transform(_controller!.value);
                  return Opacity(
                    opacity: fadeValue,
                    child: Transform.translate(
                      offset: Offset(0, (1 - slideValue) * 30),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You Have\nSuccessfully\nLogged in!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.lightBrown,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 32),
                    Container(
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
                          Text('Welcome back ${widget.username}!',
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
                    const SizedBox(height: 32),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: SizedBox(
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
                      ),
                    ),
                  ],
                ),
              ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
