import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How we handle your data',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Deep Ocean is designed to be privacy-first. Likes, matches, notes, and '
                'chat memories stay on your device. We do not sync them to a server '
                'or share them with partners.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Your controls',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'You can clear saved likes and chat history from Settings at any time. '
                'Deleting the app erases all stored information. Future versions may '
                'introduce optional backups, and we will update this policy before any '
                'change goes live.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Diagnostics',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'When enabled from developer tools, lightweight debug logs help our '
                'team investigate issues. Logs remain local and can be deleted by '
                'toggling the setting off or uninstalling the app.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
