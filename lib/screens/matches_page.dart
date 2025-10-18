import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/likes_repository.dart';
import '../models/profile_lite.dart';
import '../widgets/reaction_type_display.dart';
import '../widgets/skeletons.dart';
import 'chat_page.dart';
import 'profile_detail_page.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key, this.onExploreTap});

  final VoidCallback? onExploreTap;

  static const String _placeholderAsset = 'assets/images/placeholder.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: Selector<LikesRepository, List<ProfileLite>>(
        selector: (_, repo) => repo.likes,
        shouldRebuild: (previous, next) => !listEquals(previous, next),
        builder: (context, matches, _) {
          if (matches.isEmpty) {
            return _EmptyMatches(onExploreTap: onExploreTap);
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            itemCount: matches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final profile = matches[index];
              return _MatchTile(
                profile: profile,
                placeholderAsset: _placeholderAsset,
                onOpenProfile: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProfileDetailPage(profile: profile),
                    ),
                  );
                },
                onOpenChat: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatPage(
                        profileId: profile.id,
                        profileName: profile.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.profileId,
    required this.imageAsset,
    required this.placeholderAsset,
    required this.backgroundColor,
  });

  final String profileId;
  final String imageAsset;
  final String placeholderAsset;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    const double diameter = 56;
    return CircleAvatar(
      radius: diameter / 2,
      backgroundColor: backgroundColor,
      child: Hero(
        tag: ProfileDetailPage.heroTag(profileId),
        child: ClipOval(
          child: Image.asset(
            imageAsset,
            width: diameter,
            height: diameter,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              placeholderAsset,
              width: diameter,
              height: diameter,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({
    required this.profile,
    required this.placeholderAsset,
    required this.onOpenProfile,
    required this.onOpenChat,
  });

  final ProfileLite profile;
  final String placeholderAsset;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Selector<LikesRepository, Reaction?>(
      selector: (context, repo) {
        final reactions = repo.reactionsFor(profile.id);
        return reactions.isNotEmpty ? reactions.last : null;
      },
      builder: (context, lastReaction, _) {
        return Material(
          color: theme.colorScheme.surface,
          elevation: 1.5,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            leading: _ProfileAvatar(
              profileId: profile.id,
              imageAsset: profile.imageAsset,
              placeholderAsset: placeholderAsset,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            title: Text(
              '${profile.name}, ${profile.age} - ${profile.gender}',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: lastReaction != null
                ? _reactionSummary(theme, profile, lastReaction)
                : null,
            trailing: IconButton(
              tooltip: 'Open chat',
              icon: Icon(
                Icons.chat_bubble,
                color: theme.colorScheme.primary,
              ),
              onPressed: onOpenChat,
            ),
            onTap: onOpenProfile,
          ),
        );
      },
    );
  }

  Widget _reactionSummary(
    ThemeData theme,
    ProfileLite profile,
    Reaction reaction,
  ) {
    final String target = reaction.targetKey;
    final String? trimmedNote = reaction.note?.trim();
    final String noteSuffix =
        trimmedNote != null && trimmedNote.isNotEmpty ? ' - $trimmedNote' : '';

    String description;
    if (target.startsWith('photo:')) {
      final int index = int.tryParse(target.split(':').last) ?? 0;
      description = 'on photo ${index + 1}$noteSuffix';
    } else if (target.startsWith('prompt:')) {
      final String prompt = target.substring('prompt:'.length);
      description = 'on "$prompt"$noteSuffix';
    } else {
      description = 'sent$noteSuffix';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          reaction.type.iconData,
          size: 16,
          color: reaction.type.color(theme),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyMatches extends StatelessWidget {
  const _EmptyMatches({required this.onExploreTap});

  final VoidCallback? onExploreTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MatchListSkeleton(),
              const SizedBox(height: 24),
              Text(
                'No matches yet ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â keep exploring',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Tap explore to find profiles you like. When you both like each other, you\'ll see them here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onExploreTap,
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Explore profiles'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
