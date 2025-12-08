import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../state/auth_state.dart';
import '../state/theme_state.dart';
import 'onboarding_screen.dart';
import 'account_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final themeState = context.watch<ThemeState>();
    final isDark = themeState.isDarkMode;
    
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
              );
            },
          ),
          const Divider(color: Colors.white24),
          _SettingTile(
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            title: isDark ? 'Dark Mode' : 'Light Mode',
            subtitle: 'Tap to switch to ${isDark ? 'light' : 'dark'} mode',
            trailing: Switch(
              value: isDark,
              activeColor: AppColors.orange,
              onChanged: (_) => themeState.toggleTheme(),
            ),
            onTap: () => themeState.toggleTheme(),
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
  final Widget? trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: AppColors.orange),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.white54 : Colors.black45)),
      trailing: trailing ?? Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black38),
      onTap: onTap,
    );
  }
}
