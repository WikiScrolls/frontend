import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../state/auth_state.dart';
import 'liked_articles_screen.dart';
import 'saved_articles_screen.dart';
import 'friends_list_screen.dart';
import 'following_list_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    final username = user?.username ?? 'Guest';
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Centered title
            Text(
              'Profile',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.lightBrown,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Avatar
            CircleAvatar(
              radius: 56,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: const Icon(Icons.person, size: 56, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            
            // Username
            Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Bio (template)
            Text(
              'Love learning new things every day! 📚✨',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Friends and Followers stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FriendsListScreen()),
                    );
                  },
                  child: _StatItem(count: '0', label: 'Friends'),
                ),
                Container(
                  width: 1,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  color: Colors.white24,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FollowingListScreen()),
                    );
                  },
                  child: _StatItem(count: '0', label: 'Followers'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Activity tabs
            _ActivitySection(
              icon: Icons.comment_outlined,
              title: 'Past Comments',
              count: '0',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comments feature coming soon')),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActivitySection(
              icon: Icons.favorite_border,
              title: 'Past Likes',
              count: '?',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LikedArticlesScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActivitySection(
              icon: Icons.bookmark_border,
              title: 'Saved Posts',
              count: '?',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedArticlesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;
  final VoidCallback onTap;

  const _ActivitySection({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.orange, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
