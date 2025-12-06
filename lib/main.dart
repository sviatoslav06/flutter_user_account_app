import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_user_account_app/firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'styles/app_theme.dart';
import 'widgets/home_shell.dart';
import 'screens/profile_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/notification_screen.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/notification_provider.dart';
import 'repositories/task_repository.dart';
import 'repositories/notification_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:ui' as ui show PlatformDispatcher;

void main() async {
  debugPaintSizeEnabled = false;
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  analytics = FirebaseAnalytics.instance;

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordError(
      details.exception,
      details.stack ?? StackTrace.current,
      fatal: true,
    );
  };

  ui.PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(UserAccountApp());
}

late FirebaseAnalytics analytics;

class UserAccountApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final taskRepo = TaskRepository();
    final notifRepo = NotificationRepository();

    return MultiProvider(
      providers: [
        Provider<TaskRepository>.value(value: taskRepo),
        Provider<NotificationRepository>.value(value: notifRepo),
        ChangeNotifierProvider(
            create: (_) => TaskProvider(firestoreRepo: taskRepo)),
        ChangeNotifierProvider(
            create: (_) => NotificationProvider(firestoreRepo: notifRepo)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'User Account Page',
        theme: AppTheme.lightTheme,
        home: AuthGate(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeShell(),
          '/profile': (context) => ProfileScreen(),
          '/tasks': (context) => TasksScreen(),
          '/schedule': (context) => ScheduleScreen(),
          '/notifications': (context) => NotificationsScreen(),
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginScreen();
        }

        return HomeShell();
      },
    );
  }
}
