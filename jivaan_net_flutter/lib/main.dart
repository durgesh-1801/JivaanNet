import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'shared/widgets/app_scaffold_shell.dart';

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
