class AppUser {
  final String id;
  final String username;
  final String password;
  final String fullName;
  final String role;

  AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';
}
