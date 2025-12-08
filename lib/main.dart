import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_colors.dart';
import 'state/auth_state.dart';
import 'state/interaction_state.dart';
import 'state/tts_state.dart';
import 'state/theme_state.dart';
import 'dart:io';

// Source - https://stackoverflow.com/a
// Posted by Ma'moon Al-Akash, modified by community. See post 'Timeline' for change history
// Retrieved 2025-11-30, License - CC BY-SA 4.0

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}


void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()..loadToken()),
        ChangeNotifierProvider(create: (_) => InteractionState()),
        ChangeNotifierProvider(create: (_) => TtsState()),
        ChangeNotifierProvider(create: (_) => ThemeState()),
      ],
      child: const WikiScrollsApp(),
    ),
  );
}

class WikiScrollsApp extends StatelessWidget {
  const WikiScrollsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeState>();
    final isDark = themeState.isDarkMode;
    
    final baseTheme = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);
    final scaffoldBg = isDark ? Colors.black : Colors.white;
    final inputBg = isDark ? AppColors.inputBg : Colors.grey.shade100;
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WikiScrolls',
      themeMode: themeState.themeMode,
      theme: _buildTheme(ThemeData.light(useMaterial3: true), false),
      darkTheme: _buildTheme(ThemeData.dark(useMaterial3: true), true),
      home: const OnboardingScreen(),
    );
  }
  
  ThemeData _buildTheme(ThemeData baseTheme, bool isDark) {
    final scaffoldBg = isDark ? Colors.black : Colors.white;
    final inputBg = isDark ? AppColors.inputBg : Colors.grey.shade100;
    
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: AppColors.orange,
        secondary: AppColors.darkBrown,
      ),
      textTheme: GoogleFonts.sourceSerif4TextTheme(baseTheme.textTheme),
      scaffoldBackgroundColor: scaffoldBg,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: AppColors.orange, width: 1),
        ),
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black38),
      ),
    );
  }
}
