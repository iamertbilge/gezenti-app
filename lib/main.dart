import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'services/offline_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GezentiApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class GezentiApp extends StatefulWidget {
  const GezentiApp({super.key});

  @override
  State<GezentiApp> createState() => _GezentiAppState();
}

class _GezentiAppState extends State<GezentiApp> {
  @override
  void initState() {
    super.initState();
    OfflineSyncService.instance.start(navigatorKey: navigatorKey);
  }

  @override
  void dispose() {
    OfflineSyncService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Gezenti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
