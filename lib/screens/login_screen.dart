import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../api/auth_service.dart';
import '../api/models/user.dart';
import '../state/user_profile.dart';
import '../state/auth_state.dart';
import '../state/interaction_state.dart';
import '../widgets/gradient_button.dart';
import 'register_screen.dart';
import 'login_success_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            tween: Tween<double>(begin: 0.33, end: 0.66),
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
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/bg4.png', fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.1))),
          SafeArea(
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
                helperText: 'Enter your registered email address',
              ),
              const SizedBox(height: 12),
              _LabeledField(
                label: 'Password',
                icon: Icons.lock_outline,
                controller: _password,
                obscure: _obscure,
                onToggle: () => setState(() => _obscure = !_obscure),
                helperText: 'Enter your account password',
              ),
              const SizedBox(height: 24),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: SizedBox(
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
                              email: _username.text.trim(),
                              password: _password.text,
                            );
                            final token = res.$1;
                            final userJson = res.$2;
                            final user = UserModel.fromJson(userJson);
                            if (!mounted) return;
                            await context.read<AuthState>().setSession(token: token, user: user);
                            // Set userId for PageRank interactions
                            context.read<InteractionState>().setUserId(user.id);
                            UserProfile.instance.username = user.username;
                            if (!mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LoginSuccessScreen(username: user.username),
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
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Don't have an account yet?",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      label: 'Sign Up Here',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _LegalFooter(),
                        ],
                      ),
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
  final String? helperText;

  const _LabeledField({
    required this.label,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.onToggle,
    this.helperText,
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
        if (helperText != null) const SizedBox(height: 4),
        if (helperText != null)
          Text(
            helperText!,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
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
            Text('Terms of Service', style: style?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
            Text(' and ', style: style),
            Text('Privacy Policy', style: style?.copyWith(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}
