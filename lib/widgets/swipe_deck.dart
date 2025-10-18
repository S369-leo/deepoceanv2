import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../models/profile_lite.dart';
import '../screens/profile_details_page.dart';

class SwipeDeckController {
  _SwipeDeckState? _state;

  bool get isSwipeInFlight => _state?._isSwipeOutInProgress ?? false;

  Future<void> like() {
    final state = _state;
    if (state == null) {
      return Future<void>.value();
    }
    return state._triggerProgrammaticSwipe(liked: true);
  }

  Future<void> skip() {
    final state = _state;
    if (state == null) {
      return Future<void>.value();
    }
    return state._triggerProgrammaticSwipe(liked: false);
  }

  void _attach(_SwipeDeckState state) {
    _state = state;
  }

  void _detach(_SwipeDeckState state) {
    if (identical(_state, state)) {
      _state = null;
    }
  }
}

class SwipeDeck extends StatefulWidget {
  const SwipeDeck({
    super.key,
    required this.profile,
    required this.placeholderAsset,
    required this.onLike,
    required this.onSkip,
    required this.onResetRequested,
    this.onOpenDetails,
    this.controller,
    this.onSwipeStatusChange,
  });

  final ProfileLite profile;
  final String placeholderAsset;
  final VoidCallback onLike;
  final VoidCallback onSkip;
  final VoidCallback onResetRequested;
  final VoidCallback? onOpenDetails;
  final SwipeDeckController? controller;
  final ValueChanged<bool>? onSwipeStatusChange;

  @override
  State<SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<SwipeDeck>
    with SingleTickerProviderStateMixin {
  static const Duration _swipeDuration = Duration(milliseconds: 220);
  static const double _horizontalThresholdFraction = 0.25;
  static const double _velocityThreshold = 900;
  static const SpringDescription _snapBackSpring = SpringDescription(
    mass: 1,
    stiffness: 260,
    damping: 18,
  );

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _swipeDuration,
  );

  Animation<Offset>? _animation;
  Offset _dragOffset = Offset.zero;
  Size _deckSize = Size.zero;
  VoidCallback? _pendingAction;
  Completer<void>? _animationCompleter;
  bool _isSwipeOutInProgress = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _controller
      ..addListener(_handleTick)
      ..addStatusListener(_handleStatus);
  }

  @override
  void didUpdateWidget(covariant SwipeDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (!identical(oldWidget.profile, widget.profile)) {
      _dragOffset = Offset.zero;
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _controller
      ..removeListener(_handleTick)
      ..removeStatusListener(_handleStatus)
      ..dispose();
    super.dispose();
  }

  void _handleTick() {
    if (!mounted || _animation == null) {
      return;
    }
    setState(() {
      _dragOffset = _animation!.value;
    });
  }

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    final action = _pendingAction;
    _pendingAction = null;
    _animation = null;
    _controller.stop();
    _controller.value = 0;

    if (action != null) {
      if (!kIsWeb) {
        HapticFeedback.lightImpact();
      }
      action();
    }

    if (mounted) {
      setState(() {
        _dragOffset = Offset.zero;
      });
    }

    if (_isSwipeOutInProgress) {
      _isSwipeOutInProgress = false;
    }
    widget.onSwipeStatusChange?.call(false);

    if (_animationCompleter != null && !_animationCompleter!.isCompleted) {
      _animationCompleter!.complete();
    }
    _animationCompleter = null;
  }

  Future<void> _animateTo(
    Offset target, {
    VoidCallback? onCompleted,
    Duration? duration,
    Curve curve = Curves.easeOut,
    Simulation? simulation,
  }) {
    if (!_controller.isAnimating && target == _dragOffset) {
      return Future<void>.value();
    }

    _controller.stop();
    final Animation<Offset> animation = Tween<Offset>(
      begin: _dragOffset,
      end: target,
    ).animate(
      simulation == null
          ? CurvedAnimation(parent: _controller, curve: curve)
          : _controller,
    );
    _animation = animation;
    _pendingAction = onCompleted;
    _animationCompleter?.complete();
    final completer = Completer<void>();
    _animationCompleter = completer;

    if (onCompleted != null) {
      _isSwipeOutInProgress = true;
      widget.onSwipeStatusChange?.call(true);
    }

    if (simulation == null) {
      _controller.duration = duration ?? _swipeDuration;
      _controller.forward(from: 0);
    } else {
      _controller.value = 0;
      _controller.animateWith(simulation).whenComplete(() {
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
    }

    return completer.future;
  }

  Future<void> _animateSnapBack({double initialVelocity = 0}) {
    return _animateTo(
      Offset.zero,
      simulation: SpringSimulation(_snapBackSpring, 0, 1, initialVelocity),
    );
  }

  Future<void> _commitSwipe({required bool liked, double velocityY = 0}) {
    final double width = _deckSize.width == 0
        ? MediaQuery.of(context).size.width
        : _deckSize.width;
    final Offset target = Offset(
      (liked ? width : -width) * 1.2,
      _dragOffset.dy + velocityY * 0.1,
    );
    return _animateTo(
      target,
      onCompleted: liked ? widget.onLike : widget.onSkip,
    );
  }

  void _handlePanStart(DragStartDetails details) {
    if (_isSwipeOutInProgress) {
      return;
    }
    if (_controller.isAnimating) {
      _controller.stop();
      _animation = null;
      _pendingAction = null;
      _animationCompleter?.complete();
      _animationCompleter = null;
      widget.onSwipeStatusChange?.call(false);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isSwipeOutInProgress) {
      return;
    }
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isSwipeOutInProgress) {
      return;
    }
    final double velocityX = details.velocity.pixelsPerSecond.dx;
    final double velocityY = details.velocity.pixelsPerSecond.dy;

    final double width = _deckSize.width == 0
        ? MediaQuery.of(context).size.width
        : _deckSize.width;
    final double height = _deckSize.height == 0
        ? MediaQuery.of(context).size.height
        : _deckSize.height;
    final double horizontalThreshold = width * _horizontalThresholdFraction;
    final bool passesDistance = _dragOffset.dx.abs() > horizontalThreshold;
    final bool passesVelocity = velocityX.abs() > _velocityThreshold;

    if (passesDistance || passesVelocity) {
      final bool liked = passesDistance ? _dragOffset.dx > 0 : velocityX > 0;
      _commitSwipe(liked: liked, velocityY: velocityY);
      return;
    }

    if (_dragOffset.dy > height * 0.25 &&
        _dragOffset.dx.abs() < horizontalThreshold / 2) {
      widget.onResetRequested();
    }

    final num normalizedVelocityRaw =
        width == 0 ? 0 : (velocityX / width).clamp(-2.5, 2.5);
    _animateSnapBack(initialVelocity: normalizedVelocityRaw.toDouble());
  }

  Future<void> _triggerProgrammaticSwipe({required bool liked}) {
    if (_isSwipeOutInProgress || _controller.isAnimating) {
      return Future<void>.value();
    }
    return _commitSwipe(liked: liked);
  }

  @override
  Widget build(BuildContext context) {
    final Offset effectiveOffset = _controller.isAnimating && _animation != null
        ? _animation!.value
        : _dragOffset;

    return LayoutBuilder(
      builder: (context, constraints) {
        _deckSize = Size(constraints.maxWidth, constraints.maxHeight);
        final double width = constraints.maxWidth == 0
            ? MediaQuery.of(context).size.width
            : constraints.maxWidth;
        final double rotation = (effectiveOffset.dx / width) * 0.12;
        final double opacity = (1 - (effectiveOffset.dx.abs() / (width * 0.7)))
            .clamp(0.5, 1.0)
            .toDouble();

        return GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: Transform.translate(
            offset: effectiveOffset,
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: opacity,
                child: _ProfileCard(
                  profile: widget.profile,
                  placeholderAsset: widget.placeholderAsset,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatefulWidget {
  const _ProfileCard({
    required this.profile,
    required this.placeholderAsset,
  });

  final ProfileLite profile;
  final String placeholderAsset;

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  bool _isImageLoaded = false;

  void _handleImageLoadStateChanged(bool isLoaded) {
    if (_isImageLoaded == isLoaded) {
      return;
    }
    setState(() {
      _isImageLoaded = isLoaded;
    });
  }

  @override
  void didUpdateWidget(covariant _ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.id != widget.profile.id) {
      _isImageLoaded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        elevation: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: _ProfileImage(
                heroTag: ProfileDetailsPage.heroTag(widget.profile.id),
                imageAsset: widget.profile.imageAsset,
                placeholderAsset: widget.placeholderAsset,
                onLoadStateChanged: _handleImageLoadStateChanged,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00000000),
                      Color(0x66000000),
                      Color(0xA6000000),
                    ],
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _isImageLoaded
                      ? Text(
                          '${widget.profile.name}, ${widget.profile.age} - ${widget.profile.gender}',
                          key: const ValueKey('profile-details'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        )
                      : const _ProfileCardSkeleton(
                          key: ValueKey('profile-skeleton'),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCardSkeleton extends StatelessWidget {
  const _ProfileCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonLine(height: 18),
        SizedBox(height: 6),
        _SkeletonLine(height: 14, widthFactor: 0.45),
      ],
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({
    required this.height,
    this.widthFactor = 1,
  });

  final double height;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final double width = maxWidth * widthFactor;
        return SizedBox(
          width: width,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: const _ShimmerPlaceholder(),
          ),
        );
      },
    );
  }
}

class _ProfileImage extends StatefulWidget {
  const _ProfileImage({
    required this.imageAsset,
    required this.placeholderAsset,
    this.heroTag,
    this.onLoadStateChanged,
  });

  final String imageAsset;
  final String placeholderAsset;
  final String? heroTag;
  final ValueChanged<bool>? onLoadStateChanged;

  @override
  State<_ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<_ProfileImage> {
  bool _lastReportedLoaded = false;

  void _reportIfNeeded(bool isLoaded) {
    if (_lastReportedLoaded == isLoaded) {
      return;
    }
    _lastReportedLoaded = isLoaded;
    widget.onLoadStateChanged?.call(isLoaded);
  }

  @override
  void didUpdateWidget(covariant _ProfileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageAsset != widget.imageAsset) {
      _lastReportedLoaded = false;
      widget.onLoadStateChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildImage() {
      return Image.asset(
        widget.imageAsset,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              _reportIfNeeded(true);
            });
            return child;
          }
          final bool isLoaded = frame != null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _reportIfNeeded(isLoaded);
          });
          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedOpacity(
                opacity: isLoaded ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: const _ShimmerPlaceholder(),
              ),
              AnimatedOpacity(
                opacity: isLoaded ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                child: child,
              ),
            ],
          );
        },
        errorBuilder: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            _reportIfNeeded(true);
          });
          return Image.asset(
            widget.placeholderAsset,
            fit: BoxFit.cover,
          );
        },
      );
    }

    final Widget imageWidget = buildImage();
    if (widget.heroTag == null) {
      return imageWidget;
    }
    return Hero(tag: widget.heroTag!, child: imageWidget);
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  const _ShimmerPlaceholder();

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color baseColor =
        isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final Color highlightColor =
        isDark ? Colors.grey.shade600 : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double value = _controller.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(decoration: BoxDecoration(color: baseColor)),
            Align(
              alignment: Alignment(-1 + (value * 2), 0),
              child: FractionallySizedBox(
                widthFactor: 0.6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        highlightColor,
                        Colors.transparent,
                      ],
                      stops: const [0, 0.5, 1],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
