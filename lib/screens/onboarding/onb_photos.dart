import 'package:flutter/material.dart';

import '../../ui/theme/app_colors.dart';
import 'widgets/onboarding_scaffold.dart';

class OnbPhotos extends StatelessWidget {
  const OnbPhotos({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.options,
    required this.selectedPhotos,
    required this.onTogglePhoto,
    required this.onBack,
    required this.onNext,
    required this.isNextEnabled,
    this.maxSelection = 3,
  });

  final int currentStep;
  final int totalSteps;
  final List<String> options;
  final List<String> selectedPhotos;
  final ValueChanged<String> onTogglePhoto;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool isNextEnabled;
  final int maxSelection;

  @override
  Widget build(BuildContext context) {
    final Set<String> selected = selectedPhotos.toSet();
    final int selectedCount = selected.length;
    final bool selectionLimitReached = selectedCount >= maxSelection;

    return OnboardingScaffold(
      currentStep: currentStep,
      totalSteps: totalSteps,
      title: 'Photos',
      subtitle:
          'Select the shots that capture you best (choose up to $maxSelection).',
      onBack: onBack,
      onNext: onNext,
      isBackEnabled: true,
      isNextEnabled: isNextEnabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Tap to select or deselect. Your first photo becomes your cover.',
            style: TextStyle(color: onOcean),
          ),
          const SizedBox(height: 12),
          Text(
            '$selectedCount of $maxSelection selected',
            style: const TextStyle(color: onOcean),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (BuildContext context, int photoIndex) {
              final String asset = options[photoIndex];
              final bool isSelected = selected.contains(asset);
              final bool showLockedOverlay =
                  !isSelected && selectionLimitReached;

              return GestureDetector(
                key: ValueKey<String>('photo_option_$photoIndex'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onTogglePhoto(asset),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.25),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: <BoxShadow>[
                      if (isSelected)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          asset,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0x66000000),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      if (showLockedOverlay)
                        IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black.withValues(alpha: 0.2),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
