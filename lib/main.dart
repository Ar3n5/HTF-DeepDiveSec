import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_genui/flutter_genui.dart';
import 'package:hack_the_future_starter/features/chat/view/chat_screen.dart';
import 'package:hack_the_future_starter/core/theme_provider.dart';
import 'package:hack_the_future_starter/l10n/app_localizations.dart';
import 'package:logging/logging.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configureGenUiLogging(level: Level.ALL);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeProvider,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: _themeProvider.themeMode,
          theme: _themeProvider.lightTheme,
          darkTheme: _themeProvider.darkTheme,
          home: ChatScreen(themeProvider: _themeProvider),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// View is now provided by features/chat/presentation/views/chat_screen.dart
