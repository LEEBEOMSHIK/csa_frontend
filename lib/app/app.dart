import 'package:flutter/material.dart';
import '../screens/main_screen.dart';

class FairyTaleApp extends StatelessWidget {
  const FairyTaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '우리들의 동화',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C42),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
