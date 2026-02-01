import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raheel/pages/splash_screen.dart';
import 'package:raheel/pages/login.dart';
import 'package:raheel/pages/reset_password_handler.dart';
import 'package:raheel/pages/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

void main() async {
  // Global error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          systemNavigationBarColor: Color.fromARGB(255, 234, 235, 235),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // Initialize Supabase with error handling
      try {
        await Supabase.initialize(
          anonKey: "sb_publishable_cxUvaJDh0uUDhCeRFiED9A_Mra7VYYg",
          url: "https://mwjjaiqqfzmlaiaamlhu.supabase.co",
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('Supabase initialization timeout');
          },
        );
      } catch (e) {
        debugPrint('Supabase initialization error: $e');
        // Continue - app can work offline
      }

      runApp(const MainApp());
    },
    (error, stack) {
      debugPrint('Zone Error: $error');
      debugPrint('Zone Stack: $stack');
    },
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late StreamSubscription _deepLinkSubscription;
  late StreamSubscription _connectivitySubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  bool _isFirstConnectivityCheck = true;

  @override
  void initState() {
    super.initState();

    // Initialize features with error handling
    try {
      _initializeFeatures();
    } catch (e) {
      debugPrint('Error initializing features: $e');
    }

  }

  void _initializeFeatures() {
    try {
      _appLinks = AppLinks();
      _initDeepLinkListener();
      _handleInitialLink();
    } catch (e) {
      debugPrint('Deep link initialization error: $e');
    }

    try {
      _checkConnectivity();
      _listenToConnectivityChanges();
    } catch (e) {
      debugPrint('Connectivity check error: $e');
    }
  }


  void _checkConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      final isOnline = !results.contains(ConnectivityResult.none);

      if (mounted && !isOnline) {
        _showNoInternetNotification();
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }
  }

  void _listenToConnectivityChanges() {
    try {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          final isOnline = !results.contains(ConnectivityResult.none);

          if (mounted) {
            if (_isFirstConnectivityCheck) {
              _isFirstConnectivityCheck = false;
              return;
            }

            if (!isOnline) {
              _showNoInternetNotification();
            } else {
              _showInternetRestoredNotification();
            }
          }
        },
        onError: (err) {
          debugPrint('Connectivity listener error: $err');
        },
      );
    } catch (e) {
      debugPrint('Error setting up connectivity listener: $e');
    }
  }

  void _showNoInternetNotification() {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'لا يوجد اتصال بالإنترنت',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      debugPrint('Error showing no internet notification: $e');
    }
  }

  void _showInternetRestoredNotification() {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.wifi, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'تم استعادة الاتصال',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      debugPrint('Error showing internet restored notification: $e');
    }
  }

  BuildContext? get navigatorContext => _navigatorKey.currentContext;

  void _initDeepLinkListener() {
    try {
      _deepLinkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          _handleDeepLink(uri);
        },
        onError: (err) {
          debugPrint('Deep link stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('Error initializing deep link listener: $e');
    }
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      debugPrint('Error getting initial URI: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    try {
      debugPrint('Deep link received: $uri');

      // Check if it's a password reset link from the web page
      // Note: AndroidManifest uses com.raheelcorp.raheel scheme
      if ((uri.scheme == 'com.raheelcorp.raheel' ||
              uri.scheme == 'com.example.raheel') &&
          uri.host == 'reset-password') {
        // Extract access token from query parameters if present
        final accessToken = uri.queryParameters['access_token'];
        final refreshToken = uri.queryParameters['refresh_token'];
        final tokenType = uri.queryParameters['type'];

        _navigatorKey.currentState?.pushReplacementNamed(
          '/reset-password',
          arguments: {
            'access_token': accessToken,
            'refresh_token': refreshToken,
            'type': tokenType,
          },
        );
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  @override
  void dispose() {
    try {
      _deepLinkSubscription.cancel();
      _connectivitySubscription.cancel();
    } catch (e) {
      debugPrint('Error in dispose: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: Color.fromARGB(255, 234, 235, 235),
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
        '/reset-password': (context) => const ResetPasswordHandler(),
      },
    );
  }
}
