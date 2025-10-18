// lib/screens/home_shell.dart
import 'package:flutter/material.dart';

// These files live in the SAME folder, so use simple relative imports:
import 'explore_page.dart';
import 'matches_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      const ExplorePage(),
      MatchesPage(onExploreTap: () => _setIndex(0)),
      const ProfilePage(),
      const SettingsPage(),
    ];
    _index = _normalizeIndex(widget.initialIndex);
  }

  int _normalizeIndex(int index) {
    if (index < 0 || index >= _pages.length) {
      return 0;
    }
    return index;
  }

  void _setIndex(int newIndex) {
    final int normalized = _normalizeIndex(newIndex);
    if (_index == normalized) {
      return;
    }
    setState(() => _index = normalized);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _setIndex,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Matches'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }
}
