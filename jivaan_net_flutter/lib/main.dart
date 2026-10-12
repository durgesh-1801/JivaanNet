
import 'package:flutter/material.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';

import 'core/theme/app_theme.dart';
import 'shared/widgets/app_scaffold_shell.dart';

/// Shared Serverpod client for the app.
/// Android emulator reaches the host computer via 10.0.2.2.
final client = Client('http://10.0.2.2:8080/');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JivaanNetApp());
}

/// Root widget of the JivaanNet mobile frontend application.
class JivaanNetApp extends StatelessWidget {
  const JivaanNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JivaanNet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppScaffoldShell(),
    );
  }
}
