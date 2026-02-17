import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const Color pink = Color(0xFFFF0080);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color cyan = Color(0xFF00D4FF);

  static const Color dark1 = Color(0xFF1A1A1A);
  static const Color dark2 = Color(0xFF0A0A0A);
  static const Color black = Color(0xFF000000);

  static const Color muted = Color(0xFF808080);
  static const Color overlay = Color(0x1AFFFFFF);
  static const Color border = Color(0x33FFFFFF);
  static const Color success = Color(0xFF00FF88);
}

class AppDecorations {
  static const BoxDecoration background = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment.topLeft,
      radius: 1.5,
      colors: [AppColors.dark1, AppColors.dark2, AppColors.black],
    ),
  );

  static BoxDecoration glass20 = BoxDecoration(
    color: AppColors.overlay,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.border, width: 1),
    boxShadow: [
      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
    ],
  );

  static BoxDecoration roundedGradientButton = BoxDecoration(
    gradient: LinearGradient(colors: [AppColors.pink, AppColors.purple, AppColors.cyan]),
    borderRadius: BorderRadius.circular(25),
    boxShadow: [
      BoxShadow(color: AppColors.pink.withOpacity(0.4), blurRadius: 20, offset: Offset(0, 8)),
    ],
  );
}

class AppText {
  // Orbitron-like headings, Rajdhani-like body (use your pubspec fonts if available)
  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 2.0,
    fontFamily: 'Orbitron',
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: AppColors.muted,
    letterSpacing: 1.0,
    fontFamily: 'Rajdhani',
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: Colors.white,
    fontFamily: 'Rajdhani',
  );

  static const TextStyle cta = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    color: Colors.white,
    fontFamily: 'Orbitron',
  );
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  const GradientText(this.text, {super.key, required this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.pink, AppColors.purple, AppColors.cyan],
      ).createShader(bounds),
      child: Text(text, textAlign: textAlign, style: style.copyWith(color: Colors.white)),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? radius;

  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.margin, this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: AppDecorations.glass20.copyWith(borderRadius: radius ?? BorderRadius.circular(20)),
      child: child,
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: AppDecorations.roundedGradientButton,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: loading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: AppText.cta),
                ],
              ),
      ),
    );
  }
}

class ThemedScaffoldShell extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool scroll;

  const ThemedScaffoldShell({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.scroll = false,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    final content = scroll ? SingleChildScrollView(child: body) : body;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Container(
        decoration: AppDecorations.background,
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: content,
        ),
      ),
    );
  }
}
