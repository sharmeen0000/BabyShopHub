import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/favorites_provider.dart';
import 'package:flutter_application_1/providers/order_history_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firbaseoption.dart';
import 'screens/splash_screen.dart'; 
import 'providers/cart_provider.dart';
import 'theme/app_theme.dart';
import 'theme/neon_theme.dart';

class AppColors {
  // Dark theme with neon accents
  static const Color primaryDark = Color(0xFF0A0A0A);      
  static const Color surfaceDark = Color(0xFF1A1A1A);       // Dark surface
  static const Color cardDark = Color(0xFF2A2A2A);          // Card background
  
  // Neon accent colors
  static const Color neonPink = Color(0xFFFF0080);          // Bright pink
  static const Color neonBlue = Color(0xFF00D4FF);          // Cyan blue
  static const Color neonPurple = Color(0xFF8B5CF6);       // Purple
  static const Color neonGreen = Color(0xFF00FF88);        // Bright green
  
  // Gradient colors
  static const Color gradientStart = Color(0xFFFF0080);     // Pink
  static const Color gradientMiddle = Color(0xFF8B5CF6);    // Purple
  static const Color gradientEnd = Color(0xFF00D4FF);       // Blue
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);       // White
  static const Color textSecondary = Color(0xFFB0B0B0);     // Light gray
  static const Color textMuted = Color(0xFF808080);         // Muted gray
  
  // Glass morphism
  static const Color glassBackground = Color(0x1AFFFFFF);   // Semi-transparent white
  static const Color glassBorder = Color(0x33FFFFFF);       // Border for glass effect
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: firebaseoption);
    print("✅ Firebase connected successfully!");
  } catch (e) {
    print("❌ Firebase connection failed: $e");
  }

  runApp(
    MultiProvider(
      
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => OrderHistoryProvider()),
      ],
      child: BabyShopHub(),
    ),
  );
}

class BabyShopHub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyShopHub 2026',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.neonPink,
        scaffoldBackgroundColor: AppColors.primaryDark,
        
        textTheme: GoogleFonts.orbitronTextTheme().copyWith(
          headlineLarge: GoogleFonts.orbitron(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 2.0,
          ),
          headlineMedium: GoogleFonts.orbitron(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 1.5,
          ),
          titleLarge: GoogleFonts.rajdhani(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 1.2,
          ),
          titleMedium: GoogleFonts.rajdhani(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          bodyLarge: GoogleFonts.rajdhani(
            fontSize: 16,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
          bodyMedium: GoogleFonts.rajdhani(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: 1.5,
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: AppColors.neonPink, width: 2),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
            textStyle: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.glassBorder, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.glassBorder, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.neonPink, width: 2),
          ),
          filled: true,
          fillColor: AppColors.glassBackground,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          hintStyle: GoogleFonts.rajdhani(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          labelStyle: GoogleFonts.rajdhani(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIconColor: AppColors.neonPink,
          suffixIconColor: AppColors.neonPink,
        ),
        
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.cardDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: AppColors.neonPink, width: 1),
          ),
          contentTextStyle: GoogleFonts.rajdhani(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          actionTextColor: AppColors.neonPink,
        ),
        
        cardTheme: CardThemeData(
          color: AppColors.cardDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.glassBorder, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.neonPink;
            }
            return Colors.transparent;
          }),
          checkColor: MaterialStateProperty.all(AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          side: BorderSide(color: AppColors.glassBorder, width: 2),
        ),
        
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.neonPink,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.neonPink,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: GoogleFonts.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.rajdhani(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        
        dividerTheme: DividerThemeData(
          color: AppColors.glassBorder,
          thickness: 1,
          space: 1,
        ),
        
        cardColor: AppColors.cardDark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: SplashScreen(), // Start with splash screen instead of login
    );
  }
}
