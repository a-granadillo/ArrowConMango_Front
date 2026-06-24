import 'package:flutter/material.dart';
import 'features/game/presentation/theme/mango_theme.dart';
import 'features/game/presentation/screens/splash_screen.dart';
import 'features/game/presentation/screens/main_menu_screen.dart';
import 'features/game/presentation/screens/level_selection_screen.dart';
import 'features/game/presentation/screens/game_screen.dart';
import 'features/game/presentation/screens/victory_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArrowConMango',
      theme: MangoTheme.lightTheme,
      home: const DemoNavigation(),
    );
  }
}

/// Demo navigation for showcasing all screens
class DemoNavigation extends StatefulWidget {
  const DemoNavigation({super.key});

  @override
  State<DemoNavigation> createState() => _DemoNavigationState();
}

class _DemoNavigationState extends State<DemoNavigation> {
  int _currentIndex = 3; // Start on Game screen

  final List<Widget> _screens = [
    const SplashScreen(),
    const MainMenuScreen(),
    const LevelSelectionScreen(),
    const GameScreen(),
    const VictoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: MangoTheme.lightTheme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Splash',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Levels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.games),
            label: 'Game',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Victory',
          ),
        ],
      ),
    );
  }
}
