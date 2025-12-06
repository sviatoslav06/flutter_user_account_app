import 'package:flutter/material.dart';
import '../screens/notification_screen.dart';
import '../screens/task_list_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/profile_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const BottomNavBar({super.key, required this.currentIndex, this.onTap});

  void _defaultOnItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const TasksScreen();
        break;
      case 1:
        nextPage = ScheduleScreen();
        break;
      case 2:
        nextPage = NotificationsScreen();
        break;
      case 3:
        nextPage = ProfileScreen();
        break;
      default:
        nextPage = const TasksScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextPage,
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        } else {
          _defaultOnItemTapped(context, index);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.indigo,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'Завдання',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule_outlined),
          activeIcon: Icon(Icons.schedule),
          label: 'Розклад',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          activeIcon: Icon(Icons.notifications),
          label: 'Сповіщення',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Профіль',
        ),
      ],
    );
  }
}
