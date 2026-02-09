import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
    return LoadingAnimationWidget.inkDrop(
      color: color ?? Colors.white,
      size: size,
    );
  }
}
