import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/user_prefs.dart';
import '../models/user_profile.dart';
import 'onboarding/onboarding_flow.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _openEditor(BuildContext context, UserPrefs prefs) async {
    final bool? updated = await Navigator.of(context).push<bool?>(
      OnboardingFlow.route(
        initialProfile: prefs.profile,
        isEditing: true,
      ),
    );
    if (updated == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPrefs>(
      builder: (context, prefs, _) {
        final UserProfile? profile = prefs.profile;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              if (profile != null)
                TextButton.icon(
                  onPressed: () => _openEditor(context, prefs),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
            ],
          ),
          body: !prefs.isHydrated
              ? const Center(child: CircularProgressIndicator())
              : profile == null
                  ? _EmptyProfile(onStart: () => _openEditor(context, prefs))
                  : _ProfileDetail(
                      profile: profile,
                      onEdit: () => _openEditor(context, prefs),
                    ),
        );
      },
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({
    required this.profile,
    required this.onEdit,
  });

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String genderLabel = _formatGender(profile.gender);
    final String lookingForLabel = _formatLookingFor(profile.lookingFor);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: [
        _PhotoHeader(photos: profile.photos),
        const SizedBox(height: 24),
        Text(
          '${profile.name}, ${profile.age}',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          profile.bio,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit profile'),
        ),
        const SizedBox(height: 24),
        const Divider(),
        if (genderLabel.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.face_retouching_natural_outlined,
            label: 'Gender',
            value: genderLabel,
          ),
        ],
        if (lookingForLabel.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.favorite_outline,
            label: 'Looking for',
            value: lookingForLabel,
          ),
        ],
        if (profile.interests.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Interests',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.interests
                .map((interest) => Chip(label: Text(interest)))
                .toList(growable: false),
          ),
        ],
      ],
    );
  }
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (photos.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.photo_camera_outlined,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Image.asset(
              photos.first,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (photos.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length - 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final asset = photos[index + 1];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image.asset(
                      asset,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyProfile extends StatelessWidget {
  const _EmptyProfile({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.person_outline,
            size: 72,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Create your profile',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Set up your profile to start exploring matches and sharing your vibe.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Start onboarding'),
          ),
        ],
      ),
    );
  }
}

String _formatGender(String? raw) {
  final String value = raw?.trim().toLowerCase() ?? '';
  switch (value) {
    case 'man':
      return 'Man';
    case 'woman':
      return 'Woman';
    case 'nonbinary':
    case 'non-binary':
      return 'Non-binary';
    case 'unspecified':
    case 'prefer not to say':
    case 'other':
      return 'Prefer not to say';
    default:
      return raw?.trim() ?? '';
  }
}

String _formatLookingFor(String? raw) {
  final String value = raw?.trim().toLowerCase() ?? '';
  switch (value) {
    case 'men':
      return 'Men';
    case 'women':
      return 'Women';
    case 'everyone':
      return 'Everyone';
    default:
      return raw?.trim() ?? '';
  }
}
