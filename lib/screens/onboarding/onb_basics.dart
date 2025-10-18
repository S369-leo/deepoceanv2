import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import 'widgets/onboarding_scaffold.dart';

class OnbBasics extends StatelessWidget {
  const OnbBasics({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
    required this.isNextEnabled,
    required this.formKey,
    required this.nameController,
    required this.ageController,
    required this.bioController,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool isNextEnabled;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController bioController;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: currentStep,
      totalSteps: totalSteps,
      title: 'Basics',
      subtitle: 'Tell us a little about yourself to personalize matches.',
      onBack: onBack,
      onNext: onNext,
      isBackEnabled: true,
      isNextEnabled: isNextEnabled,
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: onOcean),
              decoration: const InputDecoration(labelText: 'Name'),
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: ageController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: onOcean),
              decoration: const InputDecoration(labelText: 'Age'),
              validator: _validateAge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: bioController,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(color: onOcean),
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Share a short introduction (optional)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _validateName(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter your name';
    }
    if (text.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? _validateAge(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter a valid age';
    }
    final int? parsed = int.tryParse(text);
    if (parsed == null) {
      return 'Please enter a valid age';
    }
    if (parsed < 18 || parsed > 100) {
      return 'Age must be between 18 and 100';
    }
    return null;
  }
}
