class TeamMember {
  final String studentId;
  final String fullName;
  final String roleVi;
  final String roleEn;
  final String email;
  final String githubUrl;
  final String avatarAsset;
  final List<String> tasksVi;
  final List<String> tasksEn;

  TeamMember({
    required this.studentId,
    required this.fullName,
    required this.roleVi,
    required this.roleEn,
    required this.email,
    required this.githubUrl,
    this.avatarAsset = '',
    required this.tasksVi,
    required this.tasksEn,
  });

  String getLocalizedRole(String langCode) {
    return langCode == 'en' ? roleEn : roleVi;
  }

  List<String> getLocalizedTasks(String langCode) {
    return langCode == 'en' ? tasksEn : tasksVi;
  }
}