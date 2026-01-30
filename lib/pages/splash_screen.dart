import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lottie/lottie.dart';
import 'package:raheel/pages/login.dart';
import '../theme_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _textOpacity = 0.0;
  Offset _textOffset = const Offset(0, 0.5);
  double _fadeOpacity = 1.0;
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Color.fromARGB(255, 234, 235, 235),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _textOpacity = 1.0;
          _textOffset = Offset.zero;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 6000), () async {
      if (!mounted) return;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBodyColor,
      body: AnimatedOpacity(
        opacity: _fadeOpacity,
        duration: const Duration(milliseconds: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSlide(
              offset: _textOffset,
              duration: const Duration(milliseconds: 3000),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _textOpacity,
                duration: const Duration(milliseconds: 3000),
                child: Column(
                  children: [
                    const Text(
                      'رحيل',
                      style: TextStyle(
                        fontFamily: 'DahkaEmbossed',
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Lottie.asset(
              'assets/lottie/earth_tag.json',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'رحلتك معنا مؤكدة بإذن الله ',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
