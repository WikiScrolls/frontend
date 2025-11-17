import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../state/auth_state.dart';
import 'onboarding_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.lightBrown,
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 24),
          _SettingTile(
            icon: Icons.person,
            title: 'Account',
            subtitle: authState.user?.email ?? 'Not logged in',
            onTap: () {},
          ),
          const Divider(color: Colors.white24),
          _SettingTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Always on',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme toggle coming soon')),
              );
            },
          ),
          const Divider(color: Colors.white24),
          _SettingTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification settings coming soon')),
              );
            },
          ),
          const Divider(color: Colors.white24),
          _SettingTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'WikiScrolls v1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'WikiScrolls',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 WikiScrolls Team',
              );
            },
          ),
          const Divider(color: Colors.white24),
          if (authState.isAuthenticated)
            _SettingTile(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              onTap: () async {
                await authState.clear();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  (_) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.orange),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}
