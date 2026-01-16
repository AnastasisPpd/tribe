import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'localization.dart';
import 'utils/constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/chat_screen.dart';
import 'services/notification_service.dart';
import 'services/message_notification_listener.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Notification Service
  await NotificationService.instance.init();

  // Set up notification tap handler
  NotificationService.instance.onNotificationTap = (activityId, activityTitle) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(activityId: activityId, title: activityTitle),
      ),
    );
  };

  runApp(const TribeApp());
}

class TribeApp extends StatefulWidget {
  const TribeApp({super.key});

  @override
  State<TribeApp> createState() => _TribeAppState();
}

class _TribeAppState extends State<TribeApp> {
  @override
  void initState() {
    super.initState();
    AppLocalization.instance.addListener(_onLanguageChange);
  }

  @override
  void dispose() {
    AppLocalization.instance.removeListener(_onLanguageChange);
    super.dispose();
  }

  void _onLanguageChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Tribe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBackground,
        primaryColor: kBlue,
        colorScheme: const ColorScheme.dark(
          primary: kBlue,
          secondary: kBlue,
          surface: kCard,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // Localization
      supportedLocales: const [Locale('en', 'US'), Locale('el', 'GR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale(AppLocalization.instance.language),

      // Routing
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainNavigation(),
      },
      // Fallback for unknown routes
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: kBlue)),
          );
        }
        if (snapshot.hasData) {
          // Start message notifications when user is logged in
          MessageNotificationListener.instance.startListening();
          return const MainNavigation();
        }
        // Stop listening when logged out
        MessageNotificationListener.instance.stopListening();
        return const LoginScreen();
      },
    );
  }
}
