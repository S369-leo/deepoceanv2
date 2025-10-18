import 'package:flutter/material.dart';

import 'widgets/onboarding_scaffold.dart';

class OnbSafetyTrust extends StatelessWidget {
  const OnbSafetyTrust({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onAgree,
    required this.onLearnMore,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onAgree;
  final VoidCallback onLearnMore;

  static const List<String> _reminders = <String>[
    'Be respectful',
    'Be authentic',
    'Report bad behavior',
    'Meet in public first',
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return OnboardingScaffold(
      currentStep: currentStep,
      totalSteps: totalSteps,
      title: 'Safety & Trust',
      subtitle: 'Keep these essentials in mind before you meet matches.',
      onBack: onBack,
      onNext: onAgree,
      nextLabel: 'I agree',
      isBackEnabled: true,
      isNextEnabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'We\'re committed to a respectful, secure community. Agree to these quick reminders.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 24),
          ..._reminders.map(
            (String reminder) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reminder,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onLearnMore,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Learn more'),
            ),
          ),
        ],
      ),
    );
  }
}

