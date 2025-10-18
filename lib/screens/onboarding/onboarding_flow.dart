import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/user_prefs.dart';
import '../../models/user_profile.dart';
import '../home_shell.dart';
import '../info/safety_tips_page.dart';
import 'onb_basics.dart';
import 'onb_done.dart';
import 'onb_photos.dart';
import 'onb_preferences.dart';
import 'onb_safety_trust.dart';
import 'onb_welcome.dart';

const List<String> _photoOptions = <String>[
  'assets/images/profiles/profile_01.jpg',
  'assets/images/profiles/profile_02.jpg',
  'assets/images/profiles/profile_03.jpg',
  'assets/images/profiles/profile_04.jpg',
  'assets/images/profiles/profile_05.jpg',
  'assets/images/profiles/profile_06.jpg',
  'assets/images/profiles/profile_07.jpg',
  'assets/images/profiles/profile_08.jpg',
];

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    super.key,
    this.initialProfile,
    this.isEditing = false,
  });

  final UserProfile? initialProfile;
  final bool isEditing;

  static Route<bool?> route({
    UserProfile? initialProfile,
    bool isEditing = false,
  }) {
    return MaterialPageRoute<bool?>(
      fullscreenDialog: isEditing,
      builder: (_) => OnboardingFlow(
        initialProfile: initialProfile,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  static const int _totalSteps = 6;
  static const int _maxPhotoSelection = 3;

  final GlobalKey<FormState> _basicsFormKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  int _currentPage = 0;
  bool _saving = false;
  late List<String> _selectedPhotos;
  late PreferencesStepController _preferencesController;

  @override
  void initState() {
    super.initState();
    final UserPrefs prefs = context.read<UserPrefs>();
    final UserProfile? initial = widget.initialProfile ?? prefs.profile;
    if (initial != null) {
      _nameController.text = initial.name;
      _ageController.text = initial.age > 0 ? initial.age.toString() : '';
      _bioController.text = initial.bio;
      _selectedPhotos =
          List<String>.from(initial.photos.take(_maxPhotoSelection));
    } else {
      _selectedPhotos = <String>[];
    }

    final UserProfile baseProfile = initial ?? UserProfile.empty();
    _preferencesController = PreferencesStepController(
      prefs: prefs,
      baseProfile: baseProfile,
    );
    _preferencesController.addListener(_handlePreferencesChanged);

    _nameController.addListener(_handleFormChanged);
    _ageController.addListener(_handleFormChanged);
    _bioController.addListener(_handleFormChanged);
  }

  @override
  void dispose() {
    _preferencesController.removeListener(_handlePreferencesChanged);
    _preferencesController.dispose();
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleFormChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _handlePreferencesChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _handleNext() async {
    FocusScope.of(context).unfocus();

    if (!_isStepValid(_currentPage)) {
      if (_currentPage == 1) {
        _basicsFormKey.currentState?.validate();
      }
      return;
    }

    switch (_currentPage) {
      case 1:
        await _persistBasics();
        break;
      case 2:
        await _persistPhotos();
        break;
      case 3:
        await _preferencesController.save();
        break;
      case 5:
        await _finishOnboarding();
        return;
    }

    if (_currentPage >= _totalSteps - 1) {
      return;
    }

    await _goToPage(_currentPage + 1);
  }

  void _handleBack() {
    if (_currentPage == 0) {
      if (widget.isEditing) {
        Navigator.of(context).maybePop(false);
      }
      return;
    }
    FocusScope.of(context).unfocus();
    _goToPage(_currentPage - 1);
  }

  void _openSafetyInfo() {
    Navigator.of(context).pushNamed(SafetyTipsPage.routeName);
  }

  Future<void> _goToPage(int index) async {
    if (!_pageController.hasClients || index == _currentPage) {
      return;
    }
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  bool _isStepValid(int step) {
    switch (step) {
      case 1:
        return _isBasicsValid;
      case 2:
        return _selectedPhotos.isNotEmpty;
      case 3:
        return _preferencesController.canProceed;
      case 5:
        return !_saving;
      default:
        return true;
    }
  }

  bool get _isBasicsValid {
    final String name = _nameController.text.trim();
    final int? age = _parseAge(_ageController.text);
    return name.length >= 2 && age != null && _isAgeInRange(age);
  }

  Future<void> _persistBasics() async {
    final UserPrefs prefs = context.read<UserPrefs>();
    final UserProfile baseProfile =
        widget.initialProfile ?? prefs.profile ?? UserProfile.empty();
    final int? parsedAge = _parseAge(_ageController.text);
    final int age = parsedAge != null && _isAgeInRange(parsedAge)
        ? parsedAge
        : baseProfile.age;

    final UserProfile updated = baseProfile.copyWith(
      name: _nameController.text.trim(),
      age: age,
      bio: _bioController.text.trim(),
    );

    await prefs.saveProfile(updated);
  }

  Future<void> _persistPhotos() async {
    final UserPrefs prefs = context.read<UserPrefs>();
    final UserProfile baseProfile =
        widget.initialProfile ?? prefs.profile ?? UserProfile.empty();
    final List<String> photos =
        List<String>.from(_selectedPhotos.take(_maxPhotoSelection));

    final UserProfile updated = baseProfile.copyWith(photos: photos);

    await prefs.saveProfile(updated);
  }

  Future<void> _finishOnboarding({bool reviewProfile = false}) async {
    if (_saving) {
      return;
    }
    setState(() {
      _saving = true;
    });

    final UserPrefs prefs = context.read<UserPrefs>();

    if (widget.isEditing) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
      });
      Navigator.of(context).pop(true);
      return;
    }

    await prefs.setFirstRunFalse();

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
    });

    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomeShell(
          initialIndex: reviewProfile ? 2 : 0,
        ),
      ),
      (_) => false,
    );
  }

  int? _parseAge(String raw) {
    final String trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return int.tryParse(trimmed);
  }

  bool _isAgeInRange(int age) => age >= 18 && age <= 100;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (didPop) {
          return;
        }
        _handleBack();
      },
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _totalSteps,
        onPageChanged: (int index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (BuildContext context, int index) {
          return _buildStep(index);
        },
      ),
    );
  }

  Widget _buildStep(int index) {
    switch (index) {
      case 0:
        return OnbWelcome(
          onNext: _handleNext,
          currentStep: index,
          totalSteps: _totalSteps,
        );
      case 1:
        return _buildBasicsStep(index);
      case 2:
        return _buildPhotosStep(index);
      case 3:
        return _buildPreferencesStep(index);
      case 4:
        return _buildSafetyStep(index);
      case 5:
        return _buildDoneStep(index);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicsStep(int index) {
    return OnbBasics(
      currentStep: index,
      totalSteps: _totalSteps,
      onBack: _handleBack,
      onNext: _handleNext,
      isNextEnabled: _isBasicsValid,
      formKey: _basicsFormKey,
      nameController: _nameController,
      ageController: _ageController,
      bioController: _bioController,
    );
  }

  Widget _buildPhotosStep(int index) {
    return OnbPhotos(
      currentStep: index,
      totalSteps: _totalSteps,
      onBack: _handleBack,
      onNext: _handleNext,
      isNextEnabled: _selectedPhotos.isNotEmpty,
      options: _photoOptions,
      selectedPhotos: _selectedPhotos,
      onTogglePhoto: _togglePhoto,
      maxSelection: _maxPhotoSelection,
    );
  }

  void _togglePhoto(String asset) {
    setState(() {
      if (_selectedPhotos.contains(asset)) {
        _selectedPhotos.remove(asset);
      } else if (_selectedPhotos.length < _maxPhotoSelection) {
        _selectedPhotos.add(asset);
      }
    });
  }

  Widget _buildPreferencesStep(int index) {
    return OnbPreferences(
      currentStep: index,
      totalSteps: _totalSteps,
      controller: _preferencesController,
      onBack: _handleBack,
      onNext: _handleNext,
    );
  }

  Widget _buildSafetyStep(int index) {
    return OnbSafetyTrust(
      currentStep: index,
      totalSteps: _totalSteps,
      onBack: _handleBack,
      onAgree: _handleNext,
      onLearnMore: _openSafetyInfo,
    );
  }

  Widget _buildDoneStep(int index) {
    return OnbDone(
      currentStep: index,
      totalSteps: _totalSteps,
      onBack: _handleBack,
      onFinish: () => _finishOnboarding(),
      onReviewProfile: () => _finishOnboarding(reviewProfile: true),
      isLoading: _saving,
    );
  }
}



















