import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.appVersion});

  final String appVersion;

  static const String _contactEmail = 'support@deepoceandating.app';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Deep Ocean')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deep Ocean Dating',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Version $appVersion',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'Deep Ocean helps thoughtful people make meaningful connections. '
                'We focus on intentional conversations, proactive safety cues, and '
                'features that respect personal boundaries.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Our pledge',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'We iterate with community feedback, keep sensitive data on-device, '
                'and build tools that celebrate authenticity over endless swiping.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Contact us at ',
                    style: theme.textTheme.bodyMedium,
                  ),
                  InkWell(
                    onTap: () => _copyEmailToClipboard(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'mailto:$_contactEmail',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _copyEmailToClipboard(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: 'mailto:$_contactEmail'));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Mail link copied to clipboard.')),
      );
  }
}
