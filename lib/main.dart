import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_colors.dart';
import 'state/auth_state.dart';
import 'state/interaction_state.dart';
import 'state/tts_state.dart';
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
      ],
      child: const WikiScrollsApp(),
    ),
  );
}

class WikiScrollsApp extends StatelessWidget {
  const WikiScrollsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WikiScrolls',
      theme: baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: AppColors.orange,
          secondary: AppColors.darkBrown,
        ),
  // Use Source Serif 4 for all text styles (including display & headline)
  textTheme: GoogleFonts.sourceSerif4TextTheme(baseTheme.textTheme),
        scaffoldBackgroundColor: Colors.black,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: AppColors.orange, width: 1),
          ),
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white54),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}
