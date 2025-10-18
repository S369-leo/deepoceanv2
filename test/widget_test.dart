import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:deep_ocean_v2/controllers/theme_mode_controller.dart';
import 'package:deep_ocean_v2/data/likes_repository.dart';
import 'package:deep_ocean_v2/data/chat_memory_store.dart';
import 'package:deep_ocean_v2/data/user_prefs.dart';
import 'package:deep_ocean_v2/models/user_profile.dart';
import 'package:deep_ocean_v2/main.dart' show RootRouter;
import 'package:deep_ocean_v2/screens/home_shell.dart';
import 'package:deep_ocean_v2/screens/chat_page.dart';
import 'package:deep_ocean_v2/screens/explore_page.dart';
import 'package:deep_ocean_v2/screens/info/safety_tips_page.dart';
import 'package:deep_ocean_v2/screens/onboarding/onboarding_flow.dart';
import 'package:deep_ocean_v2/ui/theme/app_colors.dart';

class _OnboardingHarness {
  const _OnboardingHarness({
    required this.prefs,
    required this.likes,
    required this.theme,
  });

  final UserPrefs prefs;
  final LikesRepository likes;
  final ThemeModeController theme;
}

class _TestAssetBundle extends CachingAssetBundle {
  static final Uint8List _transparentImageBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/P6kG/gAAAABJRU5ErkJggg==',
  );
  static final ByteData _transparentImageData =
      ByteData.view(_transparentImageBytes.buffer);
  static final ByteData _emptyManifestBinary =
      const StandardMessageCodec().encodeMessage(<String, List<String>>{})!;
  static final ByteData _emptyMapJsonData =
      ByteData.view(Uint8List.fromList(utf8.encode('{}')).buffer);
  static final ByteData _emptyListJsonData =
      ByteData.view(Uint8List.fromList(utf8.encode('[]')).buffer);
  static final ByteData _emptyNoticesData =
      ByteData.view(Uint8List(0).buffer);

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.json') {
      return _emptyMapJsonData;
    }
    if (key == 'FontManifest.json') {
      return _emptyListJsonData;
    }
    if (key == 'NOTICES') {
      return _emptyNoticesData;
    }
    return _transparentImageData;
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'AssetManifest.json') {
      return '{}';
    }
    if (key == 'FontManifest.json') {
      return '[]';
    }
    if (key == 'NOTICES') {
      return '';
    }
    return '';
  }

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async {
    if (key == 'AssetManifest.bin') {
      return parser(_emptyManifestBinary);
    }
    return super.loadStructuredBinaryData(key, parser);
  }
}


Future<_OnboardingHarness> _pumpOnboardingFlow(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(const <String, Object>{});

  final UserPrefs prefs = UserPrefs();
    await prefs.hydrate();
  await prefs.hydrate();
  final LikesRepository likes = LikesRepository();
  await likes.hydrate();
  final ThemeModeController theme = ThemeModeController();
  await theme.hydrate();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserPrefs>.value(value: prefs),
        ChangeNotifierProvider<LikesRepository>.value(value: likes),
        ChangeNotifierProvider<ThemeModeController>.value(value: theme),
      ],
      child: MaterialApp(
        routes: {
          SafetyTipsPage.routeName: (context) => const SafetyTipsPage(),
        },
        home: const OnboardingFlow(),
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  return _OnboardingHarness(prefs: prefs, likes: likes, theme: theme);
}

Future<void> _pumpRootRouter(
  WidgetTester tester,
  _OnboardingHarness harness,
) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserPrefs>.value(value: harness.prefs),
        ChangeNotifierProvider<LikesRepository>.value(value: harness.likes),
        ChangeNotifierProvider<ThemeModeController>.value(value: harness.theme),
      ],
      child: MaterialApp(
        routes: {
          SafetyTipsPage.routeName: (context) => const SafetyTipsPage(),
        },
        home: const RootRouter(),
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

Future<void> _completeStep(WidgetTester tester, int step) async {
  switch (step) {
    case 0:
      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      break;
    case 1:
      await tester.enterText(find.bySemanticsLabel('Name'), 'Alex');
      await tester.enterText(find.bySemanticsLabel('Age'), '28');
      await tester.enterText(
        find.bySemanticsLabel('Bio'),
        'Designer exploring meaningful connections.',
      );
      break;
    case 2:
      await tester.tap(find.byKey(const ValueKey<String>('photo_option_0')));
      break;
    case 3:
      await tester.tap(find.byKey(const ValueKey<String>('gender_option_0')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('looking_option_2')));
      await tester.pump();
      final Finder firstInterest =
          find.byKey(const ValueKey<String>('interest_chip_0'));
      await tester.ensureVisible(firstInterest);
      await tester.tap(firstInterest, warnIfMissed: false);
      final Finder secondInterest =
          find.byKey(const ValueKey<String>('interest_chip_1'));
      await tester.ensureVisible(secondInterest);
      await tester.tap(secondInterest, warnIfMissed: false);
      break;
    case 4:
      break;
    default:
      break;
  }

  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  String? nextLabel;
  switch (step) {
    case 0:
    case 1:
    case 2:
    case 3:
      nextLabel = 'Next';
      break;
    case 4:
      nextLabel = 'I agree';
      break;
    default:
      nextLabel = null;
  }

  if (nextLabel != null) {
    await tester.tap(find.widgetWithText(FilledButton, nextLabel));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }
}

void main() {
  testWidgets(
      'OnboardingFlow uses shared scaffold and brand visuals across steps',
      (WidgetTester tester) async {
    await _pumpOnboardingFlow(tester);

    for (int step = 0; step < 5; step++) {
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(
        find.byKey(const ValueKey<String>('onboarding_scaffold_gradient')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('onboarding_logo')),
        findsOneWidget,
      );

      final Finder activeDotFinder =
          find.byKey(ValueKey<String>('onboarding_progress_dot_$step'));
      final AnimatedContainer activeDot =
          tester.widget<AnimatedContainer>(activeDotFinder);
      final BoxDecoration decoration =
          activeDot.decoration! as BoxDecoration;
      expect(decoration.color, equals(onOcean));

      if (step < 4) {
        await _completeStep(tester, step);
      }
    }
  });

  testWidgets('Progress dots update as steps advance',
      (WidgetTester tester) async {
    await _pumpOnboardingFlow(tester);

    Color? dotColor(int index) {
      final AnimatedContainer dot = tester.widget<AnimatedContainer>(
        find.byKey(ValueKey<String>('onboarding_progress_dot_$index')),
      );
      return (dot.decoration! as BoxDecoration).color;
    }

    expect(dotColor(0), onOcean);
    expect(dotColor(1), onOcean.withValues(alpha: 0.35));

    await _completeStep(tester, 0);
    expect(dotColor(0), onOcean.withValues(alpha: 0.35));
    expect(dotColor(1), onOcean);

    await _completeStep(tester, 1);
    expect(dotColor(2), onOcean);

    await _completeStep(tester, 2);
    expect(dotColor(3), onOcean);

    await _completeStep(tester, 3);
    expect(dotColor(4), onOcean);

    await _completeStep(tester, 4);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(dotColor(5), onOcean);
  });

  testWidgets('Onboarding shows Safety & Trust before Done and I agree completes', (WidgetTester tester) async {
    await _pumpOnboardingFlow(tester);

    expect(find.text('Welcome to Deep Ocean'), findsOneWidget);

    await _completeStep(tester, 0);
    expect(find.text('Basics'), findsOneWidget);

    await _completeStep(tester, 1);
    expect(find.text('Photos'), findsOneWidget);

    await _completeStep(tester, 2);
    expect(find.text('Preferences'), findsOneWidget);

    await _completeStep(tester, 3);
    expect(find.text('Safety & Trust'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'I agree'), findsOneWidget);

    await _completeStep(tester, 4);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.text("You're all set"), findsOneWidget);
  });
  testWidgets('Basics step persists values to UserPrefs when advancing',
      (WidgetTester tester) async {
    final _OnboardingHarness harness = await _pumpOnboardingFlow(tester);

    await _completeStep(tester, 0);

    await tester.enterText(find.bySemanticsLabel('Name'), 'Jamie');
    await tester.enterText(find.bySemanticsLabel('Age'), '105');
    await tester.pump();

    final Finder nextButtonFinder = find.widgetWithText(FilledButton, 'Next');
    expect(
      tester.widget<FilledButton>(nextButtonFinder).onPressed,
      isNull,
    );

    await tester.enterText(find.bySemanticsLabel('Age'), '29');
    await tester.pump();

    expect(
      tester.widget<FilledButton>(nextButtonFinder).onPressed,
      isNotNull,
    );

    await tester.enterText(
      find.bySemanticsLabel('Bio'),
      'Ocean lover and coffee fan.',
    );

    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    final UserProfile? profile = harness.prefs.profile;
    expect(profile, isNotNull);
    expect(profile!.name, 'Jamie');
    expect(profile.age, 29);
    expect(profile.bio, 'Ocean lover and coffee fan.');
  });

  testWidgets('Photos step limits selection to three and persists',
      (WidgetTester tester) async {
    final _OnboardingHarness harness = await _pumpOnboardingFlow(tester);

    await _completeStep(tester, 0);
    await _completeStep(tester, 1);

    BoxDecoration decorationForTile(int index) {
      final Finder tileFinder = find.descendant(
        of: find.byKey(ValueKey<String>('photo_option_$index')),
        matching: find.byType(AnimatedContainer),
      );
      final AnimatedContainer container =
          tester.widget<AnimatedContainer>(tileFinder);
      return container.decoration! as BoxDecoration;
    }

    Future<void> selectPhoto(int index) async {
      final Finder tile = find.byKey(ValueKey<String>('photo_option_$index'));
      await tester.ensureVisible(tile);
      await tester.tap(tile, warnIfMissed: false);
      await tester.pump();
    }

    await selectPhoto(0);
    await selectPhoto(1);
    await selectPhoto(2);

    final Border selectedBorder = decorationForTile(2).border! as Border;
    expect(selectedBorder.top.width, 3);

    await selectPhoto(3);

    final Border fourthBorder = decorationForTile(3).border! as Border;
    expect(fourthBorder.top.width, 1);

    final Finder nextButtonFinder = find.widgetWithText(FilledButton, 'Next');
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    final UserProfile? profile = harness.prefs.profile;
    expect(profile, isNotNull);
    expect(
      profile!.photos,
      <String>[
        'assets/images/profiles/profile_01.jpg',
        'assets/images/profiles/profile_02.jpg',
        'assets/images/profiles/profile_03.jpg',
      ],
    );
  });

  testWidgets('Preferences step requires a match goal and persists selections',
      (WidgetTester tester) async {
    final _OnboardingHarness harness = await _pumpOnboardingFlow(tester);

    await _completeStep(tester, 0);
    await _completeStep(tester, 1);
    await _completeStep(tester, 2);

    final Finder nextButtonFinder = find.widgetWithText(FilledButton, 'Next');
    expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey<String>('looking_option_2')));
    await tester.pump();

    expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNotNull);

    await tester.tap(find.byKey(const ValueKey<String>('gender_option_1')));
    final Finder moviesChip =
        find.byKey(const ValueKey<String>('interest_chip_3'));
    await tester.ensureVisible(moviesChip);
    await tester.tap(moviesChip, warnIfMissed: false);
    await tester.pump();

    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    final UserProfile? profile = harness.prefs.profile;
    expect(profile, isNotNull);
    expect(profile!.gender, 'woman');
    expect(profile.lookingFor, 'everyone');
    expect(profile.interests, contains('Movies'));
  });

  testWidgets('Preferences chips update label colors when toggled',
      (WidgetTester tester) async {
    await _pumpOnboardingFlow(tester);

    await _completeStep(tester, 0);
    await _completeStep(tester, 1);
    await _completeStep(tester, 2);

    const Color selectedLabelColor = oceanEnd;
    const Color unselectedLabelColor = Colors.white;

    final Finder genderChipFinder =
        find.byKey(const ValueKey<String>('gender_option_0'));
    ChoiceChip genderChip =
        tester.widget<ChoiceChip>(genderChipFinder);

    expect(genderChip.selected, isFalse);
    expect(genderChip.labelStyle?.color, equals(unselectedLabelColor));

    await tester.tap(genderChipFinder);
    await tester.pump();

    genderChip = tester.widget<ChoiceChip>(genderChipFinder);
    expect(genderChip.selected, isTrue);
    expect(genderChip.labelStyle?.color, equals(selectedLabelColor));

    await tester.tap(genderChipFinder);
    await tester.pump();

    genderChip = tester.widget<ChoiceChip>(genderChipFinder);
    expect(genderChip.selected, isFalse);
    expect(genderChip.labelStyle?.color, equals(unselectedLabelColor));

    final Finder interestChipFinder =
        find.byKey(const ValueKey<String>('interest_chip_0'));
    FilterChip interestChip =
        tester.widget<FilterChip>(interestChipFinder);

    expect(interestChip.selected, isFalse);
    expect(interestChip.labelStyle?.color, equals(unselectedLabelColor));
    expect(interestChip.checkmarkColor, equals(oceanEnd));

    await tester.ensureVisible(interestChipFinder);
    await tester.tap(interestChipFinder);
    await tester.pump();

    interestChip = tester.widget<FilterChip>(interestChipFinder);
    expect(interestChip.selected, isTrue);
    expect(interestChip.labelStyle?.color, equals(selectedLabelColor));

    await tester.ensureVisible(interestChipFinder);
    await tester.tap(interestChipFinder);
    await tester.pump();

    interestChip = tester.widget<FilterChip>(interestChipFinder);
    expect(interestChip.selected, isFalse);
    expect(interestChip.labelStyle?.color, equals(unselectedLabelColor));
  });

  testWidgets('Start chat from match overlay pushes ChatPage',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});

    final LikesRepository likes = LikesRepository();
    final ChatMemoryStore chatMemoryStore = ChatMemoryStore();
    final UserPrefs prefs = UserPrefs();
    await prefs.hydrate();
    await likes.hydrate();
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _TestAssetBundle(),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<LikesRepository>.value(value: likes),
            ChangeNotifierProvider<ChatMemoryStore>.value(
              value: chatMemoryStore,
            ),
            ChangeNotifierProvider<UserPrefs>.value(
              value: prefs,
            ),
          ],
          child: const MaterialApp(
            home: ExplorePage(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final Finder likeButton = find.bySemanticsLabel('Like profile');
    expect(likeButton, findsOneWidget);

    await tester.tap(likeButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    final Finder startChatButton =
        find.widgetWithText(FilledButton, 'Start chat');
    expect(startChatButton, findsOneWidget);

    await tester.tap(startChatButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ChatPage), findsOneWidget);
  });

  testWidgets('Finish button exits onboarding and updates first run state',
      (WidgetTester tester) async {
    final _OnboardingHarness harness = await _pumpOnboardingFlow(tester);

    await _completeStep(tester, 0);
    await _completeStep(tester, 1);
    await _completeStep(tester, 2);
    await _completeStep(tester, 3);
    await _completeStep(tester, 4);

    final Finder finishButton =
        find.widgetWithText(FilledButton, 'Finish').first;
    await tester.tap(finishButton);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(harness.prefs.isFirstRun, isFalse);
    expect(find.byType(HomeShell), findsOneWidget);

    await _pumpRootRouter(tester, harness);
    expect(find.byType(HomeShell), findsOneWidget);
  });
}












































