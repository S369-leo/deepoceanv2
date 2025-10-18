import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/theme_mode_controller.dart';
import '../data/likes_repository.dart';
import 'info/about_page.dart';
import 'info/privacy_policy_page.dart';
import 'info/terms_of_service_page.dart';
import 'info/safety_tips_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _debugLogsKey = 'settings_debug_logs_enabled';
  static const String _notificationsKey = 'settings_notifications_enabled';
  static const String _visibilityKey = 'settings_account_visibility_public';
  static const String _appVersion = 'v1.0.0';

  bool _loading = true;
  bool _debugLogsEnabled = false;
  bool _notificationsEnabled = true;
  bool _accountPublic = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _debugLogsEnabled = prefs.getBool(_debugLogsKey) ?? false;
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _accountPublic = prefs.getBool(_visibilityKey) ?? true;
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await context.read<ThemeModeController>().setThemeMode(mode);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Theme set to ${_describeThemeMode(mode)}.')),
    );
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notifications ${value ? 'enabled' : 'disabled'}.',
        ),
      ),
    );
  }

  Future<void> _toggleAccountVisibility(bool value) async {
    setState(() => _accountPublic = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_visibilityKey, value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Your profile is public.' : 'Your profile is hidden.',
        ),
      ),
    );
  }

  Future<void> _toggleDebugLogs(bool value) async {
    setState(() => _debugLogsEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_debugLogsKey, value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug logs ${value ? 'enabled' : 'disabled'}.'),
      ),
    );
  }

  Future<void> _confirmResetLikes() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset likes?'),
        content: const Text('This removes all saved likes from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final cleared = context.read<LikesRepository>().clear();
    final snackBarText =
        cleared ? 'Likes have been cleared.' : 'No likes saved yet.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(snackBarText)),
    );
  }

  String _describeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    final style = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        resizeToAvoidBottomInset: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final themeMode = context.select<ThemeModeController, ThemeMode>(
      (controller) => controller.themeMode,
    );
    final isDarkMode = themeMode == ThemeMode.dark;
    final subtitleStyle = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: kBottomNavigationBarHeight + 24,
          ),
          children: [
            _buildSectionHeader(context, 'Preferences'),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('Push notifications'),
              subtitle: Text(
                'Get updates about matches and messages',
                style: subtitleStyle,
              ),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark mode'),
              subtitle: Text(
                isDarkMode
                    ? 'Using the dark theme'
                    : 'Using the light theme',
                style: subtitleStyle,
              ),
              value: isDarkMode,
              onChanged: (value) =>
                  _setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.visibility_outlined),
              title: const Text('Account visibility'),
              subtitle: Text(
                _accountPublic
                    ? 'Your profile is visible to others'
                    : 'Your profile is hidden',
                style: subtitleStyle,
              ),
              value: _accountPublic,
              onChanged: _toggleAccountVisibility,
            ),
            const Divider(),
            _buildSectionHeader(context, 'Account'),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Reset likes'),
              subtitle: Text(
                'Remove all liked profiles saved on this device',
                style: subtitleStyle,
              ),
              onTap: _confirmResetLikes,
            ),
            if (!kReleaseMode) ...[
              const Divider(),
              _buildSectionHeader(context, 'Developer tools'),
              SwitchListTile(
                secondary: const Icon(Icons.bug_report_outlined),
                title: const Text('Enable debug logs'),
                subtitle: Text(
                  'Useful during development for verbose logs',
                  style: subtitleStyle,
                ),
                value: _debugLogsEnabled,
                onChanged: _toggleDebugLogs,
              ),
            ],
            const Divider(),
            _buildSectionHeader(context, 'Legal'),
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text('Terms of Service'),
              subtitle: Text(
                'Review how Deep Ocean expects you to use the app',
                style: subtitleStyle,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TermsOfServicePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              subtitle: Text(
                'Understand how your data stays on device',
                style: subtitleStyle,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyPolicyPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Deep Ocean'),
              subtitle: Text(
                'Read our mission, version, and contact details',
                style: subtitleStyle,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AboutPage(appVersion: _appVersion),
                  ),
                );
              },
            ),
            const Divider(),
            _buildSectionHeader(context, 'Info'),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Safety tips'),
              subtitle: Text(
                'Read best practices for meeting matches',
                style: subtitleStyle,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SafetyTipsPage(),
                  ),
                );
              },
            ),
            const Divider(),
            _buildSectionHeader(context, 'About'),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              subtitle: Text(
                _appVersion,
                style: subtitleStyle,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Credits'),
              subtitle: Text(
                'Crafted by the Deep Ocean team.',
                style: subtitleStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


















