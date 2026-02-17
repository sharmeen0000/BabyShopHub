import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart'; // Import for AppColors

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Gradient? borderGradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.borderGradient,
  });

  @override
  Widget build(BuildContext context) {
    final border = borderGradient ??
        LinearGradient(colors: [
          AppColors.neonPink.withOpacity(0.2), // 0x33FF0080
          AppColors.neonPurple.withOpacity(0.2), // 0x338B5CF6
          AppColors.neonBlue.withOpacity(0.2), // 0x3300D4FF
        ]);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.glassBackground, AppColors.glassBackground.withOpacity(0.05)], // 0x1AFFFFFF to 0x0DFFFFFF
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: GradientBoxBorder(gradient: border, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Reduced for performance
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;
  final double borderRadius; // Added to sync with GlassCard

  const GradientBoxBorder({
    required this.gradient,
    this.width = 1,
    this.borderRadius = 16,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  Paint _createPaint(Rect rect) {
    return Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint = _createPaint(rect);
    final rrect = (borderRadius ?? BorderRadius.circular(this.borderRadius)).toRRect(rect);
    canvas.drawRRect(rrect.deflate(width / 2), paint);
  }

  @override
  ShapeBorder scale(double t) {
    return GradientBoxBorder(
      gradient: gradient,
      width: width * t,
      borderRadius: borderRadius * t,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final rrect = BorderRadius.circular(borderRadius).toRRect(rect).deflate(width);
    return Path()..addRRect(rrect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final rrect = BorderRadius.circular(borderRadius).toRRect(rect);
    return Path()..addRRect(rrect);
  }

  @override
  bool get isUniform => true;

  @override
  BorderSide get top => BorderSide.none;

  @override
  BorderSide get bottom => BorderSide.none;
}