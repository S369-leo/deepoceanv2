import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/feed_filter.dart';
import '../data/likes_repository.dart';
import '../data/user_prefs.dart';
import '../models/profile_lite.dart';
import '../widgets/reaction_type_display.dart';
import '../widgets/skeletons.dart';
import '../widgets/swipe_deck.dart';
import 'chat_page.dart';
import 'profile_detail_page.dart';

const String _placeholderAsset = 'assets/images/placeholder.jpg';
const String _currentUserAvatar = 'assets/images/placeholder.jpg';
const String kHintAddNote = 'Add a note...';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin<ExplorePage> {
  final List<ProfileLite> _profiles = <ProfileLite>[
    ProfileLite(
      id: 'u1',
      name: 'Noah Smith',
      age: 27,
      gender: 'Male',
      photos: const <String>['assets/images/profiles/profile_01.jpg'],
      promptAnswers: const <String, String>{
        'Two truths and a lie':
            'I have a pilot license, I hate sushi, I ran a marathon in Iceland.',
        'My Sunday ritual': 'Sunrise hike, pour-over coffee, and sketching ideas.',
      },
      verified: true,
    ),
    ProfileLite(
      id: 'u2',
      name: 'Chloe Nguyen',
      age: 31,
      gender: 'Female',
      photos: const <String>['assets/images/profiles/profile_02.jpg'],
      promptAnswers: const <String, String>{
        'Most spontaneous thing I\'ve done':
            'Booked a flight to Seoul because I craved street tteokbokki.',
        'Design hill I\'ll die on': 'Rounded corners make everything friendlier.',
      },
      verified: true,
    ),
    ProfileLite(
      id: 'u3',
      name: 'Ava Johnson',
      age: 26,
      gender: 'Female',
      photos: const <String>['assets/images/profiles/profile_03.jpg'],
      promptAnswers: const <String, String>{
        'Two truths and a lie': 'Owns 300+ books, loves karaoke, allergic to cats.',
        'My love language': 'Quality time and espresso martinis.',
      },
    ),
    ProfileLite(
      id: 'u4',
      name: 'Henry Foster',
      age: 30,
      gender: 'Male',
      photos: const <String>['assets/images/profiles/profile_04.jpg'],
      promptAnswers: const <String, String>{
        'Gym flex': 'Can deadlift 2x my weight but still cries at Pixar movies.',
        'Dream trip': 'Camper van through Patagonia with a film camera.',
      },
    ),
    ProfileLite(
      id: 'u5',
      name: 'Lana Ortiz',
      age: 28,
      gender: 'Female',
      photos: const <String>['assets/images/profiles/profile_05.jpg'],
      promptAnswers: const <String, String>{
        'Signature dish': 'Shrimp tacos with pineapple salsa.',
        'On repeat lately': 'Latin pop remixes and lo-fi when working.',
      },
      verified: true,
    ),
    ProfileLite(
      id: 'u6',
      name: 'Sasha Patel',
      age: 29,
      gender: 'Non-binary',
      photos: const <String>['assets/images/profiles/profile_06.jpg'],
      promptAnswers: const <String, String>{
        'Side quest': 'Turning my balcony into a mini jungle.',
        'Perfect collab': 'Build an AR installation with you in a museum.',
      },
    ),
    ProfileLite(
      id: 'u7',
      name: 'Ethan Brown',
      age: 32,
      gender: 'Male',
      photos: const <String>['assets/images/profiles/profile_07.jpg'],
      promptAnswers: const <String, String>{
        'Camera roll lately': 'Sunsets, sneakers, and my golden retriever, Pixel.',
        'Pet peeve': 'Lukewarm coffee and autocorrect fails.',
      },
    ),
    ProfileLite(
      id: 'u8',
      name: 'Grace Kim',
      age: 25,
      gender: 'Female',
      photos: const <String>['assets/images/profiles/profile_08.jpg'],
      promptAnswers: const <String, String>{
        'My city flex': 'Can find the best dumplings within a 5-block radius.',
        'What friends say': 'I\'m the itinerary queen and snack plug.',
      },
    ),
  ];
  final FeedFilter _feedFilter = const FeedFilter();
  List<ProfileLite> _filteredProfiles = const <ProfileLite>[];
  UserPrefs? _userPrefs;

  final SwipeDeckController _deckController = SwipeDeckController();
  bool _isSwipeOutInFlight = false;
  int _index = 0;
  bool _hasMore = true;
  ProfileLite? _pendingMatch;

  @override
  bool get wantKeepAlive => true;

  ProfileLite? get _currentProfile =>
      _index < _filteredProfiles.length ? _filteredProfiles[_index] : null;

  void _handleSwipeStatusChanged(bool inFlight) {
    if (!mounted || _isSwipeOutInFlight == inFlight) {
      return;
    }
    setState(() {
      _isSwipeOutInFlight = inFlight;
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredProfiles = List<ProfileLite>.from(_profiles);
    _hasMore = _filteredProfiles.isNotEmpty;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    UserPrefs? prefs;
    try {
      prefs = Provider.of<UserPrefs>(context, listen: false);
    } on ProviderNotFoundException {
      prefs = null;
    }
    if (!identical(prefs, _userPrefs)) {
      _userPrefs?.removeListener(_handlePrefsChanged);
      _userPrefs = prefs;
      _userPrefs?.addListener(_handlePrefsChanged);
      _rebuildFeed();
    }
  }

  void _handlePrefsChanged() {
    if (!mounted) {
      return;
    }
    _rebuildFeed();
  }

  void _rebuildFeed() {
    final UserPrefs? prefs = _userPrefs;
    final List<ProfileLite> filtered = prefs == null
        ? List<ProfileLite>.from(_profiles)
        : List<ProfileLite>.from(_feedFilter.apply(_profiles, prefs));
    final int newLength = filtered.length;
    int nextIndex = _index;
    if (nextIndex >= newLength) {
      nextIndex = 0;
    }
    final bool listsMatch = listEquals(filtered, _filteredProfiles);
    final bool hasMore = nextIndex < newLength;
    if (listsMatch && hasMore == _hasMore && nextIndex == _index) {
      return;
    }
    setState(() {
      _filteredProfiles = filtered;
      _index = nextIndex;
      _hasMore = hasMore;
      if (!hasMore) {
        _isSwipeOutInFlight = false;
      }
    });
  }

  @override
  void dispose() {
    _userPrefs?.removeListener(_handlePrefsChanged);
    super.dispose();
  }

  void _updateHasMore() {
    _hasMore = _index < _filteredProfiles.length;
  }

  void _next() {
    if (!mounted) return;
    setState(() {
      if (_index < _filteredProfiles.length) {
        _index++;
      }
      _updateHasMore();
    });
  }

  void _resetDeck() {
    if (!mounted) return;
    setState(() {
      _index = 0;
      _updateHasMore();
      _isSwipeOutInFlight = false;
    });
  }

  void _openDetails(ProfileLite profile) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileDetailPage(profile: profile),
      ),
    );
  }

  Future<void> _openReactionSheet(ProfileLite profile) async {
    final Reaction? reaction = await showModalBottomSheet<Reaction>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ReactionSheet(profile: profile),
    );
    if (!mounted || reaction == null) {
      return;
    }
    context.read<LikesRepository>().addReaction(reaction);
    final String targetLabel = _targetLabelForReaction(profile, reaction.targetKey);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Sent a ${reaction.type.label.toLowerCase()} reaction to $targetLabel'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  String _targetLabelForReaction(ProfileLite profile, String targetKey) {
    if (targetKey.startsWith('photo:')) {
      final String indexString = targetKey.split(':').last;
      final int index = int.tryParse(indexString) ?? 0;
      return 'photo ${index + 1}';
    }
    if (targetKey.startsWith('prompt:')) {
      final String prompt = targetKey.substring('prompt:'.length);
      if (profile.promptAnswers.containsKey(prompt)) {
        return prompt.toLowerCase();
      }
      return 'prompt';
    }
    return 'profile';
  }

  void _showMatchOverlay(ProfileLite profile) {
    if (!mounted) return;
    setState(() {
      _pendingMatch = profile;
    });
  }

  void _dismissMatchOverlay() {
    if (!mounted) return;
    setState(() {
      _pendingMatch = null;
    });
  }

  void _likeCurrent(BuildContext context) {
    if (!_hasMore) return;
    final profile = _currentProfile;
    if (profile == null) return;
    final repo = context.read<LikesRepository>();
    final bool matched = repo.addLike(profile);
    _next();
    if (matched) {
      _showMatchOverlay(profile);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Saved ${profile.name} to matches')),
        );
    }
  }

  void _skipCurrent() {
    if (!_hasMore) return;
    _next();
  }

  Future<void> _startChat(ProfileLite profile) async {
    _dismissMatchOverlay();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatPage(
          profileId: profile.id,
          profileName: profile.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final profile = _currentProfile;
    final bool canInteract =
        _hasMore && !_isSwipeOutInFlight && profile != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            tooltip: 'Filters (coming soon)',
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: Column(
                children: [
                  Expanded(
                    child: _hasMore && profile != null
                        ? Stack(
                            children: [
                              SwipeDeck(
                                key: ValueKey(profile.id),
                                profile: profile,
                                placeholderAsset: _placeholderAsset,
                                onLike: () => _likeCurrent(context),
                                onSkip: _skipCurrent,
                                onResetRequested: _resetDeck,
                                controller: _deckController,
                                onSwipeStatusChange: _handleSwipeStatusChanged,
                                onOpenDetails: () => _openDetails(profile),
                              ),
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: AnimatedOpacity(
                                    opacity: _isSwipeOutInFlight ? 1 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: const ProfileCardSkeleton(),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: FloatingActionButton.small(
                                  heroTag: 'react-${profile.id}',
                                  tooltip: 'React or add note',
                                  onPressed:
                                      canInteract ? () => _openReactionSheet(profile) : null,
                                  child: const Icon(Icons.more_horiz),
                                ),
                              ),
                            ],
                          )
                        : _EndOfDeckCard(onReset: _resetDeck),
                  ),
                  const SizedBox(height: 16),
                  _ActionBar(
                    onSkip: canInteract ? () => _deckController.skip() : null,
                    onLike: canInteract ? () => _deckController.like() : null,
                  ),
                ],
              ),
            ),
          ),
          if (_pendingMatch != null)
            Positioned.fill(
              child: _MatchOverlay(
                profile: _pendingMatch!,
                onKeepBrowsing: _dismissMatchOverlay,
                onStartChat: () => _startChat(_pendingMatch!),
              ),
            ),
        ],
      ),
    );
  }
}

class _EndOfDeckCard extends StatelessWidget {
  final VoidCallback onReset;

  const _EndOfDeckCard({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            "You're all caught up",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Reset the deck to browse profiles again.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onReset,
            child: const Text('Reset deck'),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final VoidCallback? onSkip;
  final VoidCallback? onLike;

  const _ActionBar({required this.onSkip, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CircleActionButton(
          icon: Icons.close_rounded,
          background: theme.colorScheme.surface,
          foreground: theme.colorScheme.onSurface,
          onPressed: onSkip,
          semanticsLabel: 'Skip profile',
        ),
        _CircleActionButton(
          icon: Icons.favorite_rounded,
          background: theme.colorScheme.primaryContainer,
          foreground: theme.colorScheme.onPrimaryContainer,
          onPressed: onLike,
          semanticsLabel: 'Like profile',
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;
  final String semanticsLabel;

  const _CircleActionButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onPressed,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null;
    final Color resolvedBackground =
        isDisabled ? background.withValues(alpha: 0.4) : background;
    final Color resolvedForeground =
        isDisabled ? foreground.withValues(alpha: 0.4) : foreground;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: semanticsLabel,
      child: Tooltip(
        message: semanticsLabel,
        child: Material(
          color: resolvedBackground,
          shape: const CircleBorder(),
          elevation: isDisabled ? 0 : 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Icon(icon, color: resolvedForeground, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchOverlay extends StatelessWidget {
  const _MatchOverlay({
    required this.profile,
    required this.onStartChat,
    required this.onKeepBrowsing,
  });

  final ProfileLite profile;
  final VoidCallback onStartChat;
  final VoidCallback onKeepBrowsing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: Colors.black54,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Card(
              elevation: 4,
              color: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "It's a match!",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _MatchAvatar(asset: _currentUserAvatar),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        _MatchAvatar(asset: profile.imageAsset),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'You and ${profile.name} liked each other. Start a chat?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: onStartChat,
                      child: const Text('Start chat'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onKeepBrowsing,
                      child: const Text('Keep browsing'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchAvatar extends StatelessWidget {
  const _MatchAvatar({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 36,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ClipOval(
        child: Image.asset(
          asset,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            _placeholderAsset,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _ReactionSheet extends StatefulWidget {
  const _ReactionSheet({required this.profile});

  final ProfileLite profile;

  @override
  State<_ReactionSheet> createState() => _ReactionSheetState();
}

class _ReactionSheetState extends State<_ReactionSheet> {
  static const List<ReactionType> _reactionTypes = ReactionType.values;

  late String _selectedTarget;
  ReactionType? _pendingType;
  final TextEditingController _noteController = TextEditingController();

  List<_ReactionTarget> get _targets {
    final List<_ReactionTarget> targets = <_ReactionTarget>[];
    for (int index = 0; index < widget.profile.photos.length; index++) {
      targets.add(
        _ReactionTarget(
          key: 'photo:$index',
          label: 'Photo ${index + 1}',
        ),
      );
    }
    widget.profile.promptAnswers.forEach((question, _) {
      targets.add(
        _ReactionTarget(
          key: 'prompt:$question',
          label: question,
        ),
      );
    });
    return targets;
  }

  @override
  void initState() {
    super.initState();
    final targets = _targets;
    _selectedTarget =
        targets.isNotEmpty ? targets.first.key : 'profile:${widget.profile.id}';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleReactionTap(ReactionType type) {
    final String note = _noteController.text.trim();
    if (note.isEmpty) {
      _submit(type, null);
    } else {
      setState(() => _pendingType = type);
    }
  }

  void _submit(ReactionType type, String? note) {
    Navigator.of(context).pop(
      Reaction(
        profileId: widget.profile.id,
        targetKey: _selectedTarget,
        type: type,
        note: note,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool hasNote = _noteController.text.trim().isNotEmpty;
    final bool canSendNote = hasNote && _pendingType != null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          24 + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Send a reaction to ${widget.profile.name}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text('React to', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _targets
                  .map(
                    (target) => ChoiceChip(
                      label: Text(target.label),
                      selected: _selectedTarget == target.key,
                      onSelected: (_) => setState(() {
                        _selectedTarget = target.key;
                      }),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            Text('Quick reactions', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _reactionTypes
                  .map(
                    (type) {
                      final Color tint = type.color(theme);
                      final bool isPending = _pendingType == type;
                      final Color backgroundColor = isPending
                          ? tint.withValues(alpha: 0.12)
                          : theme.colorScheme.surfaceContainerHighest;
                      return Semantics(
                        label: "${type.label} reaction",
                        button: true,
                        child: IconButton(
                          onPressed: () => _handleReactionTap(type),
                          icon: Icon(type.iconData),
                          tooltip: "Send ${type.label.toLowerCase()} reaction",
                          isSelected: isPending,
                          style: IconButton.styleFrom(
                            foregroundColor: tint,
                            backgroundColor: backgroundColor,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      );
                    },
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              onChanged: (_) => setState(() {
                if (_noteController.text.trim().isEmpty) {
                  _pendingType = null;
                }
              }),
              decoration: const InputDecoration(
                labelText: kHintAddNote,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: canSendNote
                  ? () => _submit(_pendingType!, _noteController.text.trim())
                  : null,
              child: Text(
                _pendingType == null
                    ? 'Pick a reaction icon to send your note'
                    : 'Send ${_pendingType!.label.toLowerCase()} with note',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionTarget {
  const _ReactionTarget({required this.key, required this.label});

  final String key;
  final String label;
}




















