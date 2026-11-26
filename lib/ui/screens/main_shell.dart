import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          // Subtle slide + fade for direction-aware transitions
          final isForward = _currentIndex > _previousIndex;
          final begin = Offset(isForward ? 0.03 : -0.03, 0);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: begin,
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() {
                _previousIndex = _currentIndex;
                _currentIndex = index;
              });
            }
          },
          items: [
            _buildNavItem(
              Icons.dashboard_outlined,
              Icons.dashboard_rounded,
              'BERANDA',
            ),
            _buildNavItem(
              Icons.bar_chart_outlined,
              Icons.bar_chart_rounded,
              'STATISTIK',
            ),
            _buildNavItem(Icons.person_outline, Icons.person_rounded, 'PROFIL'),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(outlinedIcon),
      activeIcon: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.85, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Icon(filledIcon),
      ),
      label: label,
    );
  }
}
