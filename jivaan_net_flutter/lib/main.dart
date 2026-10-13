import 'package:flutter/material.dart';
import 'package:jivaan_net_client/jivaan_net_client.dart';

import 'core/theme/app_theme.dart';
import 'services/connectivity_service.dart';
import 'shared/widgets/app_scaffold_shell.dart';

/// Configurable Serverpod URL.
/// Defaults to localhost:8080 (for adb reverse on Android devices or desktop),
/// or can be configured via `--dart-define=SERVERPOD_URL=http://<IP>:8080/`
const String serverpodUrl = String.fromEnvironment(
  'SERVERPOD_URL',
  defaultValue: 'http://localhost:8080/',
);

/// Shared Serverpod client for the app.
final client = Client(serverpodUrl);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Asynchronously probe backend reachability on launch without blocking UI
  ConnectivityService.instance.checkBackendReachability(client);
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
