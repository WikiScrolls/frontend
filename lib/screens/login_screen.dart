import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/auth_service.dart';
import '../state/user_profile.dart';
import '../widgets/gradient_button.dart';
import 'register_screen.dart';
import 'login_success_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
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
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/bg4.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.1))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Text(
                "Let's Login to Your\nAccount!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.lightBrown,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                "Welcome back! Your personalized feed is ready and waiting with new topics we think you'll find fascinating. Pick up right where you left off, explore your saved scrolls, and continue your journey of discovery.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 24),
              _LabeledField(
                label: 'Email',
                icon: Icons.email_outlined,
                controller: _username,
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Password',
                icon: Icons.lock_outline,
                controller: _password,
                obscure: _obscure,
                onToggle: () => setState(() => _obscure = !_obscure),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightBrown,
                    foregroundColor: AppColors.darkBrown, // dark brown text color per design
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          try {
                            final auth = AuthService();
                            final res = await auth.login(
                              email: _username.text.trim(), // using email field per API
                              password: _password.text,
                            );
                            final user = res.$2;
                            UserProfile.instance.username = (user['username'] ?? 'Account Name').toString();
                            if (!mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LoginSuccessScreen(username: UserProfile.instance.username),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        },
                  child: Text(_loading ? 'Logging in…' : 'Log In', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 12),
              GradientButton(
                label: 'Sign Up Here',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _LegalFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback? onToggle;

  const _LabeledField({
    required this.label,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white70),
            suffixIcon: onToggle != null
                ? IconButton(
                    onPressed: onToggle,
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                  )
                : null,
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class _LegalFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70);
    return Column(
      children: [
        const SizedBox(height: 4),
        Text('By continuing you accept our', style: style),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Terms of Service', style: style?.copyWith(decoration: TextDecoration.underline)),
            Text(' and ', style: style),
            Text('Privacy Policy', style: style?.copyWith(decoration: TextDecoration.underline)),
          ],
        )
      ],
    );
  }
}
