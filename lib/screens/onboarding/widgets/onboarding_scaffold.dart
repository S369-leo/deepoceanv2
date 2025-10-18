import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../ui/theme/app_colors.dart';

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
    this.onNext,
    this.isBackEnabled = true,
    this.isNextEnabled = true,
    this.isNextLoading = false,
    this.nextLabel,
    this.backLabel,
  });

  final int currentStep;
  final int totalSteps;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool isBackEnabled;
  final bool isNextEnabled;
  final bool isNextLoading;
  final String? nextLabel;
  final String? backLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color fieldFill =
        Colors.white.withValues(alpha: isDark ? 0.08 : 0.12);

    final ThemeData themed = theme.copyWith(
      textTheme: theme.textTheme.apply(
        bodyColor: onOcean,
        displayColor: onOcean,
      ),
      iconTheme: theme.iconTheme.copyWith(color: onOcean),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: fieldFill,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: onOcean.withValues(alpha: 0.9),
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: onOcean.withValues(alpha: 0.7),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: onOcean.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: onOcean, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      chipTheme: theme.chipTheme.copyWith(
        backgroundColor: onOcean.withValues(alpha: 0.12),
        selectedColor: onOcean,
        disabledColor: onOcean.withValues(alpha: 0.1),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: onOcean),
        secondaryLabelStyle:
            theme.textTheme.bodyMedium?.copyWith(color: oceanEnd),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        key: const ValueKey('onboarding_scaffold_gradient'),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[oceanStart, oceanEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Theme(
            data: themed,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                      builder:
                          (BuildContext context, double value, Widget? child) {
                        return Opacity(opacity: value, child: child);
                      },
                      child: Image.asset(
                        'assets/images/logo_white.png',
                        key: const ValueKey('onboarding_logo'),
                        height: 48,
                        semanticLabel: 'Deep Ocean logo',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final double minHeight = math.max(
                        0,
                        constraints.hasBoundedHeight &&
                                constraints.maxHeight.isFinite
                            ? constraints.maxHeight
                            : 0,
                      );
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          24,
                          32,
                          24,
                          32 + kBottomNavigationBarHeight,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: minHeight),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style:
                                    themed.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ) ??
                                        const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w600,
                                          color: onOcean,
                                        ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: themed.textTheme.bodyLarge?.copyWith(
                                      color: onOcean.withValues(alpha: 0.86),
                                    ) ??
                                    TextStyle(
                                      fontSize: 16,
                                      color: onOcean.withValues(alpha: 0.86),
                                    ),
                              ),
                              const SizedBox(height: 32),
                              Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 520),
                                  child: child,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _BottomBar(
                  currentStep: currentStep,
                  totalSteps: totalSteps,
                  onBack: onBack,
                  onNext: onNext,
                  isBackEnabled: isBackEnabled,
                  isNextEnabled: isNextEnabled,
                  isNextLoading: isNextLoading,
                  nextLabel: nextLabel,
                  backLabel: backLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onNext,
    required this.isBackEnabled,
    required this.isNextEnabled,
    required this.isNextLoading,
    required this.nextLabel,
    required this.backLabel,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool isBackEnabled;
  final bool isNextEnabled;
  final bool isNextLoading;
  final String? nextLabel;
  final String? backLabel;

  @override
  Widget build(BuildContext context) {
    const Duration progressDuration = Duration(milliseconds: 200);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(totalSteps, (int index) {
              final bool isActive = index == currentStep;
              return AnimatedContainer(
                key: ValueKey<String>('onboarding_progress_dot_$index'),
                duration: progressDuration,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? onOcean : onOcean.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Tooltip(
                message: backLabel ?? 'Back',
                child: Semantics(
                  label: backLabel ?? 'Back',
                  button: true,
                  enabled: isBackEnabled && onBack != null,
                  child: OutlinedButton(
                    onPressed: isBackEnabled && onBack != null ? onBack : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: onOcean,
                      side: BorderSide(
                        color: onOcean.withValues(alpha: 0.65),
                      ),
                    ),
                    child: Text(backLabel ?? 'Back'),
                  ),
                ),
              ),
              const Spacer(),
              Tooltip(
                message: nextLabel ?? 'Next',
                child: Semantics(
                  label: nextLabel ?? 'Next',
                  button: true,
                  enabled: isNextEnabled && !isNextLoading && onNext != null,
                  child: FilledButton(
                    onPressed: isNextEnabled && !isNextLoading && onNext != null
                        ? onNext
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: onOcean,
                      foregroundColor: oceanEnd,
                      disabledBackgroundColor: onOcean.withValues(alpha: 0.3),
                      disabledForegroundColor: oceanEnd.withValues(alpha: 0.4),
                    ),
                    child: isNextLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(oceanEnd),
                            ),
                          )
                        : Text(nextLabel ?? 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
