import 'package:flutter/material.dart';
import '../screens/task_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/notification_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeShell extends StatefulWidget {
  @override
  _HomeShellState createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    TasksScreen(),
    ScheduleScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;

    Widget content = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _pages[_currentIndex],
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(Icons.assignment),
                  label: Text('Завдання'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.schedule_outlined),
                  selectedIcon: Icon(Icons.schedule),
                  label: Text('Розклад'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.notifications_none),
                  selectedIcon: Icon(Icons.notifications),
                  label: Text('Сповіщення'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Профіль'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      body: content,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
