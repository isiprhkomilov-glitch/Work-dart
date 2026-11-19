import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

/// Корневой виджет приложения.
class NetworkApp extends StatelessWidget {
  const NetworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Работа с сетью',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        cardTheme: const CardThemeData(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
