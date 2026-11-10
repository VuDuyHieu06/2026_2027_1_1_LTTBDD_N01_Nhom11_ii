import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/mysql_service.dart';
import '../state/app_state_controller.dart';
import 'package:flutter/services.dart';

class TeamSettingsScreen extends StatelessWidget {
  final AppStateController state;

  const TeamSettingsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final lang = state.languageCode;
    final user = state.currentUser;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: user.isAdmin
                            ? Colors.amber[100]
                            : Colors.blue[100],
                        child: Icon(
                          user.isAdmin
                              ? Icons.admin_panel_settings
                              : Icons.person,
                          color: user.isAdmin
                              ? Colors.amber[900]
                              : Colors.blue[900],
                        ),
                      ),
                      title: Text(
                        user.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '@${user.username} • ${user.isAdmin ? AppStrings.tr('role_admin', lang) : AppStrings.tr('role_user', lang)}',
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: state.logout,
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                        ),
                        label: Text(
                          AppStrings.tr('logout_btn', lang),
                          style: const TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.storage_rounded,
                      color: Colors.teal,
                    ),
                    title: const Text(
                      'MySQL Database: ${MySqlService.databaseName}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Host: ${MySqlService.host}:${MySqlService.port} • Queries logged: ${state.mysqlService.queryLogs.length}',
                    ),
                  ),
                  const Divider(),
                  const Text(
                    'Đồng bộ dữ liệu sang mã nguồn (Sau khi thêm/sửa món và ảnh trên Web):',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.code, size: 18),
                        label: const Text(
                          'Copy code cho mock_data.dart',
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: state.exportRecipesToDartCode(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Đã copy hàm getInitialRecipes()! Hãy dán đè vào file lib/data/mock_data.dart',
                              ),
                            ),
                          );
                        },
                      ),
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.storage, size: 18),
                        label: const Text(
                          'Copy lệnh SQL cho mysql_schema.sql',
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: state.exportRecipesToSqlCode(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Đã copy lệnh INSERT SQL! Hãy dán đè vào file database/mysql_schema.sql',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.language,
                      color: Colors.blue,
                    ),
                    title: Text(
                      AppStrings.tr('lang_setting_title', lang),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      AppStrings.tr('lang_setting_sub', lang),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'vi',
                          icon: Icon(Icons.translate),
                          label: Text('Tiếng Việt'),
                        ),
                        ButtonSegment(
                          value: 'en',
                          icon: Icon(Icons.public),
                          label: Text('English'),
                        ),
                      ],
                      selected: {lang},
                      onSelectionChanged: (selection) {
                        state.setLanguage(selection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.school,
                    color: Colors.indigo,
                  ),
                  title: Text(
                    AppStrings.tr('project_info_title', lang),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${AppStrings.tr('course_name', lang)}\n${AppStrings.tr('instructor_name', lang)}',
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.code),
                  title: Text('GitHub Repository'),
                  subtitle: Text(
                    'https://github.com/VuDuyHieu06/2026_2027_1_1_LTTBDD_N01_Nhom11_ii',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.tr('team_section_title', lang),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 8),
          ...state.members.map((member) {
            final initials = member.fullName.isNotEmpty
                ? member.fullName
                      .trim()
                      .split(' ')
                      .last[0]
                      .toUpperCase()
                : 'SV';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        member.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${AppStrings.tr('student_id_label', lang)}: ${member.studentId}\n${member.getLocalizedRole(lang)}',
                      ),
                    ),
                    const Divider(),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: member
                          .getLocalizedTasks(lang)
                          .map(
                            (task) => Chip(
                              visualDensity: VisualDensity.compact,
                              label: Text(
                                task,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}