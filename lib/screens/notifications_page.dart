import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Notifications',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.lightBrown,
                      fontWeight: FontWeight.w700,
                    )),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 72, color: AppColors.lightBrown.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No notifications yet',
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Stay tuned for updates!',
                      style: TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
