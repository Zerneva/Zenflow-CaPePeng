import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/main_shell.dart';
import 'ui/screens/login_screen.dart';
import 'services/auth_service.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint(e.toString());
  }

  runApp(const ProviderScope(child: ZenFlowApp()));
}

class ZenFlowApp extends ConsumerWidget {
  const ZenFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'ZenFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      darkTheme: AppTheme.darkThemeData,
      themeMode: themeMode,
      home: SplashScreen(nextScreen: const AuthWrapper()),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.white,
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.black,
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const MainShell();
        }
        return const LoginScreen();
      },
    );
  }
}
