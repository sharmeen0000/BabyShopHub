import 'dart:ui';
import 'package:flutter/material.dart';

class NeonPalette {
  static const Color pink = Color(0xFFFF0080);
  static const Color cyan = Color(0xFF00D4FF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color success = Color(0xFF00FF88);

  static const Color bg1 = Color(0xFF1A1A1A);
  static const Color bg2 = Color(0xFF0A0A0A);
  static const Color bg3 = Color(0xFF000000);

  static const Color text = Colors.white;
  static const Color textMuted = Color(0xFF808080);

  static const BorderSide glassBorder = BorderSide(color: Color(0x33FFFFFF), width: 1);

  static const List<Color> brandGradient = [pink, purple, cyan];
}

class NeonBackground extends StatelessWidget {
  final Widget child;
  final Alignment center;
  final double radius;
  const NeonBackground({super.key, required this.child, this.center = Alignment.topLeft, this.radius = 1.5});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [NeonPalette.bg1, NeonPalette.bg2, NeonPalette.bg3],
        ),
      ),
      child: child,
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;
  const GradientText(this.text, {super.key, required this.style, this.colors = NeonPalette.brandGradient});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(colors: colors).createShader(bounds),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

class Glass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final Color overlay;
  final BorderSide border;
  const Glass({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.overlay = const Color(0x1AFFFFFF),
    this.border = NeonPalette.glassBorder,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: overlay,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.fromBorderSide(border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final List<Color> colors;
  final bool glow;
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.borderRadius = 16,
    this.colors = NeonPalette.brandGradient,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    final boxShadow = glow
        ? [
            BoxShadow(
              color: NeonPalette.pink.withOpacity(0.35),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ]
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
        child: child,
      ),
    );
  }
}

PreferredSizeWidget neonTransparentAppBar({
  required Widget title,
  List<Widget>? actions,
  Widget? leading,
}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: DefaultTextStyle.merge(
      style: const TextStyle(color: NeonPalette.text),
      child: title,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    actions: actions,
    leading: leading,
  );
}
