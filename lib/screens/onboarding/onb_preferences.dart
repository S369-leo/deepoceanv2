import 'package:flutter/material.dart';

import '../../data/user_prefs.dart';
import '../../models/user_profile.dart';
import '../../ui/theme/app_colors.dart';
import 'onb_step_controller.dart';
import 'widgets/onboarding_scaffold.dart';

class _PreferenceOption {
  const _PreferenceOption({required this.label, required this.value});

  final String label;
  final String value;
}

const List<_PreferenceOption> _genderOptions = <_PreferenceOption>[
  _PreferenceOption(label: 'Man', value: 'man'),
  _PreferenceOption(label: 'Woman', value: 'woman'),
  _PreferenceOption(label: 'Non-binary', value: 'nonbinary'),
  _PreferenceOption(label: 'Prefer not to say', value: 'unspecified'),
];

const List<_PreferenceOption> _lookingForOptions = <_PreferenceOption>[
  _PreferenceOption(label: 'Men', value: 'men'),
  _PreferenceOption(label: 'Women', value: 'women'),
  _PreferenceOption(label: 'Everyone', value: 'everyone'),
];

const List<String> interestOptions = <String>[
  'Music',
  'Travel',
  'Fitness',
  'Movies',
  'Cooking',
  'Outdoors',
  'Books',
  'Gaming',
  'Art',
  'Pets',
];

class _OnboardingChipStyle {
  static const Color _unselectedLabelColor = Colors.white;
  static Color get unselectedBackground => Colors.white.withValues(alpha: 0.18);
  static const Color selectedColor = Colors.white;
  static const BorderSide _unselectedBorder = BorderSide(color: Colors.white24);
  static const BorderSide _selectedBorder = BorderSide(color: Colors.white);

  static const Color checkmarkColor = oceanEnd;

  static BorderSide borderSide(bool isSelected) {
    return isSelected ? _selectedBorder : _unselectedBorder;
  }

  static TextStyle labelStyle(bool isSelected) {
    return TextStyle(
      color: isSelected ? oceanEnd : _unselectedLabelColor,
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
    );
  }
}

class PreferencesStepController extends OnbStepController {
  PreferencesStepController({
    required UserPrefs prefs,
    required UserProfile baseProfile,
  })  : _prefs = prefs,
        _baseProfile = baseProfile {
    _gender = _normalizeGender(baseProfile.gender);
    _lookingFor = _normalizeLookingFor(baseProfile.lookingFor);
    _interests.addAll(_restoreInterests(baseProfile.interests));
  }

  final UserPrefs _prefs;
  final UserProfile _baseProfile;

  final Set<String> _interests = <String>{};
  String? _gender;
  String? _lookingFor;

  String? get gender => _gender;
  String? get lookingFor => _lookingFor;
  List<String> get selectedInterests => interestOptions
      .where((String option) => _interests.contains(option))
      .toList(growable: false);

  int get selectedInterestCount => _interests.length;

  @override
  bool get canProceed => _lookingFor != null;

  void selectGender(String value) {
    if (_gender == value) {
      _gender = null;
    } else {
      _gender = value;
    }
    notifyListeners();
  }

  void selectLookingFor(String value) {
    if (_lookingFor == value) {
      _lookingFor = null;
    } else {
      _lookingFor = value;
    }
    notifyListeners();
  }

  void toggleInterest(String value) {
    if (!interestOptions.contains(value)) {
      return;
    }
    if (_interests.contains(value)) {
      _interests.remove(value);
    } else {
      _interests.add(value);
    }
    notifyListeners();
  }

  @override
  Future<void> save() async {
    final UserProfile base = _prefs.profile ?? _baseProfile;
    final UserProfile updated = UserProfile(
      name: base.name,
      age: base.age,
      bio: base.bio,
      gender: _gender,
      lookingFor: _lookingFor,
      interests: selectedInterests,
      photos: base.photos,
    );
    await _prefs.saveProfile(updated);
  }

  static String? _normalizeGender(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return null;
    }
    if (normalized == 'man' || normalized == 'male') {
      return 'man';
    }
    if (normalized == 'woman' || normalized == 'female') {
      return 'woman';
    }
    if (normalized == 'nonbinary' || normalized == 'non-binary') {
      return 'nonbinary';
    }
    if (normalized == 'unspecified' ||
        normalized == 'prefer not to say' ||
        normalized == 'other') {
      return 'unspecified';
    }
    return null;
  }

  static String? _normalizeLookingFor(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    if (normalized.isEmpty) {
      return null;
    }
    if (normalized == 'men' || normalized == 'man') {
      return 'men';
    }
    if (normalized == 'women' || normalized == 'woman') {
      return 'women';
    }
    if (normalized == 'everyone' || normalized == 'all') {
      return 'everyone';
    }
    return null;
  }

  static Set<String> _restoreInterests(List<String> values) {
    final Set<String> restored = <String>{};
    for (final String value in values) {
      final String trimmed = value.trim();
      if (interestOptions.contains(trimmed)) {
        restored.add(trimmed);
      }
    }
    return restored;
  }
}

class OnbPreferences extends StatelessWidget {
  const OnbPreferences({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.controller,
    required this.onBack,
    required this.onNext,
  });

  final int currentStep;
  final int totalSteps;
  final PreferencesStepController controller;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        return OnboardingScaffold(
          currentStep: currentStep,
          totalSteps: totalSteps,
          title: 'Preferences',
          subtitle: 'Share who you are and who you\'re into.',
          onBack: onBack,
          onNext: onNext,
          isBackEnabled: true,
          isNextEnabled: controller.canProceed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text('I identify as', style: TextStyle(color: onOcean)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List<Widget>.generate(_genderOptions.length, (int index) {
                  final _PreferenceOption option = _genderOptions[index];
                  final bool isSelected = controller.gender == option.value;
                  return ChoiceChip(
                    key: ValueKey<String>('gender_option_$index'),
                    label: Text(option.label),
                    selected: isSelected,
                    selectedColor: _OnboardingChipStyle.selectedColor,
                    backgroundColor: _OnboardingChipStyle.unselectedBackground,
                    labelStyle: _OnboardingChipStyle.labelStyle(isSelected),
                    side: _OnboardingChipStyle.borderSide(isSelected),
                    showCheckmark: true,
                    checkmarkColor: _OnboardingChipStyle.checkmarkColor,
                    onSelected: (_) => controller.selectGender(option.value),
                  );
                }),
              ),
              const SizedBox(height: 24),
              const Text("I'm looking for", style: TextStyle(color: onOcean)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List<Widget>.generate(_lookingForOptions.length, (int index) {
                  final _PreferenceOption option = _lookingForOptions[index];
                  final bool isSelected = controller.lookingFor == option.value;
                  return ChoiceChip(
                    key: ValueKey<String>('looking_option_$index'),
                    label: Text(option.label),
                    selected: isSelected,
                    selectedColor: _OnboardingChipStyle.selectedColor,
                    backgroundColor: _OnboardingChipStyle.unselectedBackground,
                    labelStyle: _OnboardingChipStyle.labelStyle(isSelected),
                    side: _OnboardingChipStyle.borderSide(isSelected),
                    showCheckmark: true,
                    checkmarkColor: _OnboardingChipStyle.checkmarkColor,
                    onSelected: (_) =>
                        controller.selectLookingFor(option.value),
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  const Text('Interests', style: TextStyle(color: onOcean)),
                  const SizedBox(width: 8),
                  Text(
                    '(${controller.selectedInterestCount}/${interestOptions.length})',
                    style: TextStyle(
                        color: onOcean.withValues(alpha: 0.7), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List<Widget>.generate(interestOptions.length, (int index) {
                  final String option = interestOptions[index];
                  final bool isSelected =
                      controller.selectedInterests.contains(option);
                  return FilterChip(
                    key: ValueKey<String>('interest_chip_$index'),
                    label: Text(option),
                    selected: isSelected,
                    selectedColor: _OnboardingChipStyle.selectedColor,
                    backgroundColor: _OnboardingChipStyle.unselectedBackground,
                    labelStyle: _OnboardingChipStyle.labelStyle(isSelected),
                    side: _OnboardingChipStyle.borderSide(isSelected),
                    checkmarkColor: _OnboardingChipStyle.checkmarkColor,
                    showCheckmark: true,
                    onSelected: (_) => controller.toggleInterest(option),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}



























