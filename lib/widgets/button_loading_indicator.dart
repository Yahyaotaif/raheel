import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ButtonLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const ButtonLoadingIndicator({
    super.key,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/lottie/cute.json',
        fit: BoxFit.contain,
        repeat: true,
      ),
    );
  }
}
