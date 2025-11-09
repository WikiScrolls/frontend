class UserProfile {
  String username;
  String? password; // Do NOT store plaintext in production; use hashing or secure storage.
  List<int>? avatarBytes; // Placeholder for in-memory avatar image.

  UserProfile({required this.username, this.password, this.avatarBytes});

  static final UserProfile instance = UserProfile(username: 'Account Name');
}
