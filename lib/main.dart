import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/providers/session_sync_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Allow running without a local .env file.
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize date formatting for Russian locale
  await initializeDateFormatting('ru_RU', null);

  runApp(
    const ProviderScope(
      child: PackMateApp(),
    ),
  );
}

class PackMateApp extends ConsumerWidget {
  const PackMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Initialize session sync controller - it will auto-sync on auth state changes
    ref.watch(sessionSyncControllerProvider);

    // Enable auto-sync of local changes to Firestore
    ref.watch(autoSyncProvider);

    return MaterialApp.router(
      title: 'PackMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
