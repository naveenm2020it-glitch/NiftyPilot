import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'providers/app_state_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppStateProvider();
  await appState.initialize();

  runApp(
    ChangeNotifierProvider<AppStateProvider>.value(
      value: appState,
      child: const DayPilotApp(),
    ),
  );
}
