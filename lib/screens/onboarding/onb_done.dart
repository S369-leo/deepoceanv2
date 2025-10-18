import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import 'widgets/onboarding_scaffold.dart';

class OnbDone extends StatelessWidget {
  const OnbDone({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onFinish,
    required this.onReviewProfile,
    required this.isLoading,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onFinish;
  final VoidCallback onReviewProfile;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: currentStep,
      totalSteps: totalSteps,
      title: "You're all set",
      subtitle: "We've saved your details. Let's dive in.",
      onBack: onBack,
      onNext: onFinish,
      isBackEnabled: true,
      isNextEnabled: !isLoading,
      isNextLoading: isLoading,
      nextLabel: 'Finish',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 12),
          const Icon(Icons.celebration_outlined, color: onOcean, size: 72),
          const SizedBox(height: 16),
          const Text(
            'All set! You can always tweak these details from your profile.',
            textAlign: TextAlign.center,
            style: TextStyle(color: onOcean),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: isLoading ? null : onFinish,
            style: FilledButton.styleFrom(
              backgroundColor: onOcean,
              foregroundColor: oceanEnd,
            ),
            child: const Text('Finish'),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: isLoading ? null : onReviewProfile,
              style: TextButton.styleFrom(foregroundColor: onOcean),
              child: const Text('Review profile'),
            ),
          ),
        ],
      ),
    );
  }
}
