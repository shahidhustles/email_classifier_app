import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/email_provider.dart';
import 'screens/app_shell_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/cache_service.dart';
import 'services/gmail_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const InboxStoreApp());
}

class InboxStoreApp extends StatelessWidget {
  const InboxStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GmailService gmailService = GmailService();
    final CacheService cacheService = CacheService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authService: AuthService(),
            gmailService: gmailService,
          )..bootstrap(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, EmailProvider>(
          create: (_) =>
              EmailProvider(
                gmailService: gmailService,
                cacheService: cacheService,
              )..bootstrap(),
          update: (_, authProvider, emailProvider) {
            final EmailProvider provider =
                emailProvider ??
                EmailProvider(
                  gmailService: gmailService,
                  cacheService: cacheService,
                )..bootstrap();
            provider.bindAuthProvider(authProvider);
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        switch (authProvider.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const LoadingScreen();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
          case AuthStatus.authenticated:
          case AuthStatus.error:
            return authProvider.currentUser == null
                ? const LoginScreen()
                : const AppShellScreen();
        }
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Checking sign-in state...'),
          ],
        ),
      ),
    );
  }
}
