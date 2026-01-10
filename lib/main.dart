import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/stock_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StockProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SkyStock',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo.shade700),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.indigo.shade700,
            foregroundColor: Colors.white,
          ),
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
