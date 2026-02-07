import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:raheel/deeplink_state.dart';
import 'package:raheel/pages/login.dart';
import '../theme_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _textOpacity = 0.0;
  Offset _textOffset = Offset.zero;
  double _fadeOpacity = 1.0;
  late AnimationController _carController;
  late Animation<Offset> _carAnimation;
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromARGB(255, 234, 235, 235),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    // Initialize car animation controller
    _carController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    
    _carAnimation = Tween<Offset>(
      begin: const Offset(-4, 0),
      end: const Offset(3, 0),
    ).animate(CurvedAnimation(
      parent: _carController,
      curve: Curves.easeInOut,
    ));
    
    // Check if deep link is pending at splash init
    debugPrint('🔍 Splash init - deep link pending: $isDeepLinkResetPasswordPending');
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _textOpacity = 1.0;
          _textOffset = Offset.zero;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 4100), () {
      if (mounted) {
        _carController.repeat();
      }
    });
    Future.delayed(const Duration(milliseconds: 4000), () async {
      if (!mounted) return;
      debugPrint('🕐 Splash screen 6s timer completed');
      debugPrint('🔍 Checking deep link flag: $isDeepLinkResetPasswordPending');
      
      // Wait a bit more and check flag again in case deep link is still processing
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;
      
      debugPrint('🔍 Final check - deep link flag: $isDeepLinkResetPasswordPending');
      
      if (isDeepLinkResetPasswordPending) {
        debugPrint('🚫 Splash screen: deep link reset-password pending, skipping login navigation');
        return;
      }
      
      debugPrint('➡️ Splash screen: navigating to login');
      setState(() {
        _fadeOpacity = 0.0;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _carController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBodyColor,
      body: Center(
        child: AnimatedOpacity(
          opacity: _fadeOpacity,
          duration: const Duration(milliseconds: 2000),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedSlide(
                offset: _textOffset,
                duration: const Duration(milliseconds: 2000),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: _textOpacity,
                  duration: const Duration(milliseconds: 2000),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'رحيل',
                        style: TextStyle(
                          fontFamily: 'typokar',
                          fontSize: 90,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'رحلتك معنا مؤكدة بإذن الله ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: AnimatedBuilder(
                          animation: _carAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_carAnimation.value.dx * 100, 0),
                              child: child,
                            );
                          },
                          child: Lottie.asset(
                            'assets/lottie/carr.json',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                            repeat: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
