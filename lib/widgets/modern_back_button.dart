import 'package:flutter/material.dart';

class ModernBackButton extends StatelessWidget {
  final Color? color;
  final double size;

  const ModernBackButton({super.key, this.color, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color;
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: size,
        color: iconColor,
      ),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}
