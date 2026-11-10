import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../state/app_state_controller.dart';

class AuthScreen extends StatefulWidget {
  final AppStateController state;

  const AuthScreen({super.key, required this.state});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  bool _obscurePassword = true;
  String _selectedRole = 'user';

  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController(text: 'admin');
  final _passwordCtrl = TextEditingController(text: '123456');
  final _fullNameCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _fullNameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final lang = widget.state.languageCode;
    if (!_formKey.currentState!.validate()) return;

    if (_isLoginMode) {
      final ok = widget.state.login(_usernameCtrl.text, _passwordCtrl.text);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(AppStrings.tr('auth_error_invalid', lang)),
          ),
        );
      }
    } else {
      final ok = widget.state.register(
        username: _usernameCtrl.text,
        password: _passwordCtrl.text,
        fullName: _fullNameCtrl.text,
        role: _selectedRole,
      );
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(AppStrings.tr('auth_error_exists', lang)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr('app_title', lang)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ActionChip(
              avatar: const Icon(Icons.language, size: 16),
              label: Text(lang.toUpperCase()),
              onPressed: widget.state.toggleLanguage,
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Color(0xFF1D4ED8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.tr('app_title', lang),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.tr('auth_subtitle', lang),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(
                            value: true,
                            icon: const Icon(Icons.login),
                            label: Text(AppStrings.tr('login_tab', lang)),
                          ),
                          ButtonSegment(
                            value: false,
                            icon: const Icon(Icons.person_add_alt_1),
                            label: Text(AppStrings.tr('register_tab', lang)),
                          ),
                        ],
                        selected: {_isLoginMode},
                        onSelectionChanged: (s) {
                          setState(() => _isLoginMode = s.first);
                        },
                      ),
                      const SizedBox(height: 16),
                      if (!_isLoginMode) ...[
                        TextFormField(
                          controller: _fullNameCtrl,
                          decoration: InputDecoration(
                            labelText: AppStrings.tr('fullname_label', lang),
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? AppStrings.tr('form_error', lang)
                              : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                          labelText: AppStrings.tr('username_label', lang),
                          prefixIcon: const Icon(Icons.person_outline),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? AppStrings.tr('form_error', lang)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: AppStrings.tr('password_label', lang),
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? AppStrings.tr('form_error', lang)
                            : null,
                      ),
                      if (!_isLoginMode) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRole,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: AppStrings.tr('role_label', lang),
                            prefixIcon: const Icon(
                              Icons.admin_panel_settings_outlined,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'user',
                              child: Text(
                                AppStrings.tr('role_user', lang),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text(
                                AppStrings.tr('role_admin', lang),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() => _selectedRole = val ?? 'user');
                          },
                        ),
                      ],
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: Icon(_isLoginMode ? Icons.login : Icons.check),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            _isLoginMode
                                ? AppStrings.tr('login_btn', lang)
                                : AppStrings.tr('register_btn', lang),
                          ),
                        ),
                      ),
                      if (_isLoginMode) ...[
                        const Divider(height: 28),
                        Text(
                          AppStrings.tr('quick_demo_accounts', lang),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(
                                Icons.admin_panel_settings,
                                size: 16,
                              ),
                              label: Text(
                                AppStrings.tr('demo_admin_btn', lang),
                              ),
                              onPressed: () {
                                setState(() {
                                  _usernameCtrl.text = 'admin';
                                  _passwordCtrl.text = '123456';
                                });
                              },
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.person, size: 16),
                              label: Text(AppStrings.tr('demo_user_btn', lang)),
                              onPressed: () {
                                setState(() {
                                  _usernameCtrl.text = 'user';
                                  _passwordCtrl.text = '123456';
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
