import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/likes_repository.dart';
import '../models/profile_lite.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key, required this.profile});

  final ProfileLite profile;

  static String heroTag(String id) => 'profile-image-$id';

  static final Map<String, String> _bios = <String, String>{
    'u1': 'Adventure seeker who never misses a sunrise hike.',
    'u2': 'Product designer by day, foodie by night.',
    'u3': 'Bookworm, coffee enthusiast, and weekend painter.',
    'u4': 'Fitness trainer who loves board games and travel.',
    'u5': 'Ocean lover, aspiring chef, and karaoke queen.',
    'u6': 'Tech nerd with a green thumb and a love for sci-fi.',
    'u7': 'Photographer chasing the golden hour in every city.',
    'u8': 'Startup marketer obsessed with street food and museums.',
  };

  static final Map<String, List<String>> _interests = <String, List<String>>{
    'u1': <String>['Hiking', 'Cycling', 'Travel'],
    'u2': <String>['Foodies', 'Design', 'Yoga'],
    'u3': <String>['Reading', 'Art', 'Coffee'],
    'u4': <String>['Fitness', 'Board games', 'Travel'],
    'u5': <String>['Cooking', 'Beach days', 'Karaoke'],
    'u6': <String>['Tech', 'Gardening', 'Sci-fi'],
    'u7': <String>['Photography', 'Road trips', 'Music'],
    'u8': <String>['Startups', 'Street food', 'Museums'],
  };

  String get _bio => _bios[profile.id] ?? 'Looking forward to new connections!';

  List<String> get _tags =>
      _interests[profile.id] ?? const <String>['Community', 'Good vibes'];

  List<_DetailEntry> _buildEntries() {
    final List<_DetailEntry> entries = <_DetailEntry>[];
    final photos = profile.photos;
    final prompts = profile.promptAnswers.entries.toList(growable: false);
    int promptIndex = 0;

    for (int i = 0; i < photos.length; i++) {
      entries.add(_PhotoEntry(index: i, asset: photos[i]));
      if (promptIndex < prompts.length) {
        final entry = prompts[promptIndex++];
        entries.add(
          _PromptEntry(question: entry.key, answer: entry.value),
        );
      }
    }

    while (promptIndex < prompts.length) {
      final entry = prompts[promptIndex++];
      entries.add(
        _PromptEntry(question: entry.key, answer: entry.value),
      );
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLiked = context.select<LikesRepository, bool>(
      (repo) => repo.likes.any((p) => p.id == profile.id),
    );
    final entries = _buildEntries();

    final List<_DetailEntry> remainingEntries = entries.skip(1).toList(growable: false);
    final _PhotoEntry? heroEntry = entries.isNotEmpty && entries.first is _PhotoEntry
        ? entries.first as _PhotoEntry
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Report',
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Report profile'),
                  content: const Text(
                    'Reporting is not available in this build. Thanks for your patience!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.flag_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (heroEntry != null)
            _PhotoCard(
              index: heroEntry.index,
              asset: heroEntry.asset,
              isHero: true,
              profileId: profile.id,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${profile.name}, ${profile.age}',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    if (profile.verified)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Verified',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  profile.gender,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _bio,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          if (_tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor:
                            theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.25,
                        ),
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          for (final entry in remainingEntries)
            if (entry is _PhotoEntry)
              _PhotoCard(
                index: entry.index,
                asset: entry.asset,
                isHero: false,
                profileId: profile.id,
              )
            else if (entry is _PromptEntry)
              _PromptCard(
                question: entry.question,
                answer: entry.answer,
              ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final repo = context.read<LikesRepository>();
                      if (isLiked) {
                        repo.removeLike(profile.id);
                      } else {
                        final matched = repo.addLike(profile);
                        if (matched) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text("It's a match with ${profile.name}!"),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                        }
                      }
                    },
                    child: Text(isLiked ? 'Unlike' : 'Like'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Messaging not wired yet (stub).'),
                        ),
                      );
                    },
                    child: const Text('Message'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

abstract class _DetailEntry {
  const _DetailEntry();
}

class _PhotoEntry extends _DetailEntry {
  const _PhotoEntry({required this.index, required this.asset}) : super();
  final int index;
  final String asset;
}

class _PromptEntry extends _DetailEntry {
  const _PromptEntry({required this.question, required this.answer}) : super();
  final String question;
  final String answer;
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.index,
    required this.asset,
    required this.isHero,
    required this.profileId,
  });

  final int index;
  final String asset;
  final bool isHero;
  final String profileId;

  @override
  Widget build(BuildContext context) {
    final Widget image = ClipRRect(
      borderRadius: index == 0 && isHero
          ? const BorderRadius.vertical(bottom: Radius.circular(24))
          : BorderRadius.circular(24),
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/placeholder.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );

    final Widget content = AspectRatio(
      aspectRatio: 16 / 10,
      child: image,
    );

    if (isHero) {
      return Hero(tag: ProfileDetailPage.heroTag(profileId), child: content);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: content,
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                answer,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileDetailsPage extends ProfileDetailPage {
  const ProfileDetailsPage({super.key, required super.profile});

  static String heroTag(String id) => ProfileDetailPage.heroTag(id);
}

