import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import 'widgets/onboarding_scaffold.dart';

class OnbWelcome extends StatelessWidget {
  const OnbWelcome({
    super.key,
    required this.onNext,
    required this.currentStep,
    required this.totalSteps,
  });

  final VoidCallback onNext;
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: currentStep,
      totalSteps: totalSteps,
      title: 'Welcome to Deep Ocean',
      subtitle:
          "Let's set up the basics so you can dive into meaningful matches.",
      onBack: null,
      isBackEnabled: false,
      onNext: onNext,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: onOcean,
              foregroundColor: oceanEnd,
            ),
            child: const Text('Get started'),
          ),
        ],
      ),
    );
  }
}
