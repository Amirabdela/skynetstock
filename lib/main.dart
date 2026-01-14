import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/stock_provider.dart';
import 'services/auth_service.dart';
import 'services/auth_gate.dart';
import 'screens/home_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/account_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Skynet Stock',
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
        routes: {
          '/signin': (_) => const SignInScreen(),
          '/signup': (_) => const SignUpScreen(),
          '/login': (_) => const SignInScreen(),
          '/home': (_) => const HomeScreen(),
          '/account': (_) => const AccountScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/messages': (_) => const MessagesScreen(),
          '/notifications': (_) => const NotificationsScreen(),
          '/reports': (_) => const ReportsScreen(),
        },
      ),
    );
  }
}
