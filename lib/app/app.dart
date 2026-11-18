import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../navigation/main_shell.dart';
import '../providers/app_state_provider.dart';
import '../screens/security/lock_screen.dart';
import '../theme/app_theme.dart';

class DayPilotApp extends StatefulWidget {
  const DayPilotApp({super.key});

  @override
  State<DayPilotApp> createState() => _DayPilotAppState();
}

class _DayPilotAppState extends State<DayPilotApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<AppStateProvider>().lockAppIfEnabled();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return MaterialApp(
      title: 'DayPilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appState.settings.themeMode,
      locale: Locale(appState.settings.languageCode),
      supportedLocales: const [
        Locale('en'),
        Locale('ta'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: appState.isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : (appState.isLocked ? const LockScreen() : const MainShell()),
    );
  }
}
