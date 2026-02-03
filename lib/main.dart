import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raheel/pages/splash_screen.dart';
import 'package:raheel/pages/login.dart';
import 'package:raheel/pages/reset_password_handler.dart';
import 'package:raheel/pages/profile.dart';
import 'package:raheel/providers/language_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:raheel/l10n/app_localizations.dart';
import 'package:raheel/deeplink_state.dart';
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

      // Initialize language provider
      final languageProvider = LanguageProvider();
      await languageProvider.init();

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

      runApp(MainApp(languageProvider: languageProvider));
    },
    (error, stack) {
      debugPrint('Zone Error: $error');
      debugPrint('Zone Stack: $stack');
    },
  );
}

class MainApp extends StatefulWidget {
  final LanguageProvider languageProvider;

  const MainApp({super.key, required this.languageProvider});

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
        debugPrint('Initial link detected: $uri');
        _handleDeepLink(uri);
      }
    } catch (e) {
      debugPrint('Error getting initial URI: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    try {
      debugPrint('=== Deep Link Handler ===');
      debugPrint('Deep link received: $uri');
      debugPrint('Full URL: ${uri.toString()}');
      debugPrint('Scheme: ${uri.scheme}');
      debugPrint('Host: ${uri.host}');
      debugPrint('Path: ${uri.path}');
      debugPrint('Query params: ${uri.queryParameters}');
      debugPrint('Fragment: ${uri.fragment}');
      debugPrint('========================');

      // Check if it's a password reset link from Supabase
      // Supabase sends recovery links with type=recovery and tokens in query or fragment
      bool isResetPasswordLink = false;

      // Check various possible URL formats:
      // 1. com.raheelcorp.raheel://reset-password?token=xxx&type=recovery
      // 2. com.raheelcorp.raheel://reset-password#access_token=...&refresh_token=...&type=recovery
      // 3. https://mwjjaiqqfzmlaiaamlhu.supabase.co/auth/v1/verify?token=...&type=recovery (Supabase email link)
      // 4. http(s)://.../reset-password?token=xxx&type=recovery (web)

      if (uri.scheme == 'com.raheelcorp.raheel') {
        if (uri.host == 'reset-password' || uri.path.contains('reset-password')) {
          isResetPasswordLink = true;
        }
      } else if (uri.scheme == 'http' || uri.scheme == 'https') {
        // Supabase verification links
        if (uri.host.contains('supabase.co') && uri.path.contains('/auth/v1/verify')) {
          isResetPasswordLink = true;
        } else if (uri.path.contains('reset-password')) {
          isResetPasswordLink = true;
        }
      }

      if (isResetPasswordLink) {
        final queryParams = Map<String, String>.from(uri.queryParameters);
        final fragmentParams = uri.fragment.isNotEmpty
            ? Uri.splitQueryString(uri.fragment)
            : <String, String>{};

        final merged = <String, String>{}
          ..addAll(fragmentParams)
          ..addAll(queryParams);

        final tokenType = merged['type'];
        final token = merged['token'];
        final code = merged['code'];
        final accessToken = merged['access_token'];
        final refreshToken = merged['refresh_token'];

        debugPrint('🔐 Detected reset password link');
        debugPrint('📋 Token type: $tokenType, token=${token != null}, code=${code != null}, access=${accessToken != null}, refresh=${refreshToken != null}');

        if (accessToken != null && refreshToken != null) {
          debugPrint('🎟️ Access/refresh tokens found, setting flag and navigating to reset-password');
          isDeepLinkResetPasswordPending = true;

          Future.microtask(() {
            _navigateToResetPasswordWithTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
              tokenType: tokenType,
            );
          });
        } else if (code != null) {
          debugPrint('🔑 Recovery code found: $code');
          isDeepLinkResetPasswordPending = true;

          Future.microtask(() {
            _navigateToResetPasswordWithCode(code);
          });
        } else if (token != null) {
          debugPrint('🎫 Token found, setting flag and navigating to reset-password');
          isDeepLinkResetPasswordPending = true;

          Future.microtask(() {
            _navigateToResetPassword(token, tokenType);
          });
        } else {
          debugPrint('⚠️ No usable token found in deep link');
        }
      } else {
        debugPrint('❓ Not a recognized deep link: scheme=${uri.scheme}, host=${uri.host}, path=${uri.path}');
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  void _navigateToResetPassword(String token, String? tokenType, {int retryCount = 0}) {
    try {
      final navigator = _navigatorKey.currentState;
      if (navigator != null && navigator.mounted) {
        debugPrint('🔄 Navigator available (retry: $retryCount), executing navigation to /reset-password');
        navigator.pushReplacementNamed(
          '/reset-password',
          arguments: {
            'token': token,
            'type': tokenType ?? 'recovery',
          },
        );
        debugPrint('✅ Navigation command sent successfully');
        // Keep flag true for a bit longer to ensure SplashScreen doesn't interfere
        Future.delayed(const Duration(milliseconds: 2000), () {
          isDeepLinkResetPasswordPending = false;
          debugPrint('🏁 Deep link flag cleared');
        });
      } else if (retryCount < 20) {
        debugPrint('⏳ Navigator not ready (retry: $retryCount), retrying in 200ms');
        Future.delayed(const Duration(milliseconds: 200), () {
          _navigateToResetPassword(token, tokenType, retryCount: retryCount + 1);
        });
      } else {
        debugPrint('❌ Failed to navigate after 20 retries');
        isDeepLinkResetPasswordPending = false;
      }
    } catch (e) {
      debugPrint('❌ Error during navigation to reset password: $e');
      isDeepLinkResetPasswordPending = false;
    }
  }

  void _navigateToResetPasswordWithTokens({
    required String accessToken,
    required String refreshToken,
    String? tokenType,
    int retryCount = 0,
  }) {
    try {
      final navigator = _navigatorKey.currentState;
      if (navigator != null && navigator.mounted) {
        debugPrint('🔄 Navigator available (retry: $retryCount), executing navigation to /reset-password with tokens');
        navigator.pushReplacementNamed(
          '/reset-password',
          arguments: {
            'access_token': accessToken,
            'refresh_token': refreshToken,
            'type': tokenType ?? 'recovery',
          },
        );
        debugPrint('✅ Navigation command sent successfully');
        // Keep flag true for a bit longer to ensure SplashScreen doesn't interfere
        Future.delayed(const Duration(milliseconds: 2000), () {
          isDeepLinkResetPasswordPending = false;
          debugPrint('🏁 Deep link flag cleared');
        });
      } else if (retryCount < 20) {
        debugPrint('⏳ Navigator not ready (retry: $retryCount), retrying in 200ms');
        Future.delayed(const Duration(milliseconds: 200), () {
          _navigateToResetPasswordWithTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            tokenType: tokenType,
            retryCount: retryCount + 1,
          );
        });
      } else {
        debugPrint('❌ Failed to navigate after 20 retries');
        isDeepLinkResetPasswordPending = false;
      }
    } catch (e) {
      debugPrint('❌ Error during navigation to reset password: $e');
      isDeepLinkResetPasswordPending = false;
    }
  }

  void _navigateToResetPasswordWithCode(String code, {int retryCount = 0}) {
    try {
      final navigator = _navigatorKey.currentState;
      if (navigator != null && navigator.mounted) {
        debugPrint('🔄 Navigator available (retry: $retryCount), executing navigation to /reset-password with code');
        navigator.pushReplacementNamed(
          '/reset-password',
          arguments: {
            'code': code,
            'type': 'recovery',
          },
        );
        debugPrint('✅ Navigation command sent successfully');
        Future.delayed(const Duration(milliseconds: 2000), () {
          isDeepLinkResetPasswordPending = false;
          debugPrint('🏁 Deep link flag cleared');
        });
      } else if (retryCount < 20) {
        debugPrint('⏳ Navigator not ready (retry: $retryCount), retrying in 200ms');
        Future.delayed(const Duration(milliseconds: 200), () {
          _navigateToResetPasswordWithCode(code, retryCount: retryCount + 1);
        });
      } else {
        debugPrint('❌ Failed to navigate after 20 retries');
        isDeepLinkResetPasswordPending = false;
      }
    } catch (e) {
      debugPrint('❌ Error during navigation to reset password with code: $e');
      isDeepLinkResetPasswordPending = false;
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
    return ChangeNotifierProvider<LanguageProvider>.value(
      value: widget.languageProvider,
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: _navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.locale,
            theme: ThemeData(
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  systemNavigationBarColor: Color.fromARGB(255, 234, 235, 235),
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
              ),
            ),
            home: SplashScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/login':
                  return MaterialPageRoute(builder: (context) => const LoginPage());
                case '/profile':
                  return MaterialPageRoute(builder: (context) => const ProfilePage());
                case '/reset-password':
                  return MaterialPageRoute(
                    builder: (context) => const ResetPasswordHandler(),
                    settings: RouteSettings(arguments: settings.arguments),
                  );
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }

}

