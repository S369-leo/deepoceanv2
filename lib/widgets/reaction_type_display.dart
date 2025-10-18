import 'package:flutter/material.dart';

import '../models/profile_lite.dart';

extension ReactionTypeDisplay on ReactionType {
  String get label {
    switch (this) {
      case ReactionType.like:
        return 'Like';
      case ReactionType.laugh:
        return 'Laugh';
      case ReactionType.fire:
        return 'Fire';
    }
  }

  IconData get iconData {
    switch (this) {
      case ReactionType.like:
        return Icons.favorite;
      case ReactionType.laugh:
        return Icons.emoji_emotions;
      case ReactionType.fire:
        return Icons.local_fire_department;
    }
  }

  Color color(ThemeData theme) {
    switch (this) {
      case ReactionType.like:
        return theme.colorScheme.primary;
      case ReactionType.laugh:
        return theme.colorScheme.secondary;
      case ReactionType.fire:
        return theme.colorScheme.error;
    }
  }
}