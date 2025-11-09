import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';
import '../api/auth_service.dart';
import '../state/user_profile.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background dark texture can be added later as an image if needed
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let's Create Your\nAccount!",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.lightBrown,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "By creating an account, you'll get a personalized 'For You' feed that learns what you love. You can also save interesting topics for later and track all the new things you've discovered. Let's get your learning adventure started!",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _LabeledField(
                    label: 'Username',
                    icon: Icons.person_outline,
                    controller: _username,
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: 'Email',
                    icon: Icons.email_outlined,
                    controller: _email,
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    controller: _password,
                    obscure: _obscure1,
                    onToggle: () => setState(() => _obscure1 = !_obscure1),
                  ),
                  const SizedBox(height: 12),
                  _LabeledField(
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    controller: _confirm,
                    obscure: _obscure2,
                    onToggle: () => setState(() => _obscure2 = !_obscure2),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                      label: _loading ? 'Signing Up…' : 'Sign Up',
                      onPressed: _loading
                          ? null
                          : () async {
                              if (_password.text != _confirm.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Passwords do not match')),
                                );
                                return;
                              }
                              setState(() => _loading = true);
                              try {
                                final auth = AuthService();
                                final res = await auth.signup(
                                  username: _username.text.trim(),
                                  email: _email.text.trim(),
                                  password: _password.text,
                                );
                                final user = res.$2;
                                UserProfile.instance.username = (user['username'] ?? _username.text.trim()).toString();
                                if (!mounted) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              } finally {
                                if (mounted) setState(() => _loading = false);
                              }
                            }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBrown,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text('Log In Here', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    ),
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
