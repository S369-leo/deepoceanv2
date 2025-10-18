import 'package:flutter/material.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color base = theme.colorScheme.surfaceContainerHigh
        .withValues(alpha: isDark ? 0.28 : 0.5);
    final Color highlight = theme.colorScheme.surfaceContainerHighest
        .withValues(alpha: isDark ? 0.45 : 0.32);

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[base, highlight, base],
          ),
        ),
      ),
    );
  }
}

class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonBox(
      borderRadius: BorderRadius.all(Radius.circular(28)),
    );
  }
}

class MatchListSkeleton extends StatelessWidget {
  const MatchListSkeleton({super.key, this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 12),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SkeletonBox(
                width: 56,
                height: 56,
                borderRadius: BorderRadius.all(Radius.circular(28)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                      height: 14,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    SizedBox(height: 8),
                    SkeletonBox(
                      height: 12,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
