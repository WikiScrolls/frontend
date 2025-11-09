import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/user_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _FeedPage(),
      const _NotificationsPage(),
      ProfilePage(profile: UserProfile.instance),
      const _SettingsPage(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: AppColors.orange.withOpacity(0.15),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Notifications'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _FeedPage extends StatelessWidget {
  const _FeedPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Search millions of topics...',
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Tabs row
            Row(
              children: [
                _TabChip(label: 'Friends'),
                const SizedBox(width: 12),
                _TabChip(label: 'Following'),
                const SizedBox(width: 12),
                const _TabChip(label: 'For You', selected: true),
              ],
            ),
            const SizedBox(height: 16),
            // Content area
            Expanded(
              child: Stack(
                children: [
                  // Center big title
                  Center(
                    child: Text(
                      'The\nContent\nWill Be\nShown\nHere',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                          ),
                    ),
                  ),
                  // Right vertical actions
                  Positioned(
                    right: 8,
                    top: 16,
                    bottom: 16,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _ActionIcon(icon: Icons.favorite_border),
                        SizedBox(height: 18),
                        _ActionIcon(icon: Icons.chat_bubble_outline),
                        SizedBox(height: 18),
                        _ActionIcon(icon: Icons.bookmark_border),
                        SizedBox(height: 18),
                        _ActionIcon(icon: Icons.send_outlined),
                      ],
                    ),
                  ),
                  // Bottom meta
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 56),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('<Post Title>', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          const Text(
                            '<Post Caption>. Lorem Ipsum is simply dummy text of the printing and typesetting industry...',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: -6,
                            children: const [
                              _TagChip('#Post Tag1'),
                              _TagChip('#Post Tag2'),
                              _TagChip('#Post Tag3'),
                              _TagChip('#Post Tag4'),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _TabChip({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final style = selected
        ? const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)
        : const TextStyle(color: Colors.white70);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: style),
        const Icon(Icons.expand_more, size: 18, color: Colors.white54),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  const _ActionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        onPressed: () {},
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  const _TagChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic));
  }
}

class _NotificationsPage extends StatelessWidget {
  const _NotificationsPage();
  @override
  Widget build(BuildContext context) {
    return const _SimpleScaffold(title: 'Notifications');
  }
}

class ProfilePage extends StatefulWidget {
  final UserProfile profile;
  const ProfilePage({super.key, required this.profile});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _username;
  late TextEditingController _pass1;
  late TextEditingController _pass2;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void initState() {
    super.initState();
    _username = TextEditingController(text: widget.profile.username);
    _pass1 = TextEditingController();
    _pass2 = TextEditingController();
  }

  @override
  void dispose() {
    _username.dispose();
    _pass1.dispose();
    _pass2.dispose();
    super.dispose();
  }

  void _save() {
    if (_pass1.text != _pass2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    setState(() {
      widget.profile.username = _username.text.trim();
      if (_pass1.text.isNotEmpty) {
        widget.profile.password = _pass1.text; // In real app: hash & send to API
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.lightBrown,
                      fontWeight: FontWeight.w700,
                    )),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () async {
                  // Placeholder for image picker integration
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image picker not implemented yet.')),
                  );
                },
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 48, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _fieldLabel('Username'),
            TextField(
              controller: _username,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            _fieldLabel('New Password'),
            TextField(
              controller: _pass1,
              obscureText: _obscure1,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Confirm Password'),
            TextField(
              controller: _pass2,
              obscureText: _obscure2,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: _save,
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
      );
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();
  @override
  Widget build(BuildContext context) {
    return const _SimpleScaffold(title: 'Settings');
  }
}

class _SimpleScaffold extends StatelessWidget {
  final String title;
  const _SimpleScaffold({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              title == 'Notifications'
                  ? Icons.notifications
                  : title == 'Profile'
                      ? Icons.person
                      : Icons.settings,
              size: 72,
              color: AppColors.lightBrown,
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('This page is coming soon.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
