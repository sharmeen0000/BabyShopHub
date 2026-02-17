import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_panel.dart';
import '../widgets/glass_card.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showPassword = false;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
    _slide = Tween<Offset>(begin: const Offset(0, .12), end: Offset.zero).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
    _anim.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  Gradient get _brandGrad => const LinearGradient(colors: [
        Color(0xFFFF0080),
        Color(0xFF8B5CF6),
        Color(0xFF00D4FF),
      ]);

  Future<void> _loginAsAdmin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    setState(() => _isLoading = true);
    try {
      print('Attempting login with email: ${_emailCtrl.text.trim()}'); // Debug log
      // Sign in with Firebase Authentication
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      // Get user UID
      final uid = cred.user?.uid;
      if (uid == null) {
        throw Exception('No user found after sign-in.');
      }

      // Check if user is an admin
      print('Checking roles for UID: $uid'); // Debug log
      final doc = await FirebaseFirestore.instance.collection('roles').doc(uid).get();
      final data = doc.data();
      final isAdmin = data != null && (data['role'] == 'admin' || data['admin'] == true);

      if (!isAdmin) {
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        setState(() => _isLoading = false);
        _toast('This account is not authorized as Admin.', error: true);
        return;
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const AdminPanel()),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      print('FirebaseAuthException: ${e.code} - ${e.message}'); // Debug log
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid email or password. Please verify your credentials or register the account.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed. Please try again.';
      }
      await Future.delayed(const Duration(milliseconds: 200)); // Smooth UI feedback
      _toast(errorMessage, error: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      print('Error: $e'); // Debug log
      _toast('Error: $e', error: true);
    }
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? const Color(0xFFFF2D55) : const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _logoHeader(),
                        const SizedBox(height: 20),
                        GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _labeledField(
                                  label: 'ADMIN EMAIL',
                                  child: TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      hint: 'you@company.com',
                                      icon: Icons.alternate_email,
                                      iconColor: const Color(0xFFFF0080),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Enter email';
                                      }
                                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v.trim())) {
                                        return 'Enter a valid email (e.g., you@company.com)';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _labeledField(
                                  label: 'PASSWORD',
                                  child: TextFormField(
                                    controller: _passwordCtrl,
                                    obscureText: !_showPassword,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      hint: 'Your secure password',
                                      icon: Icons.lock_outline,
                                      iconColor: const Color(0xFF8B5CF6),
                                      suffix: IconButton(
                                        onPressed: () => setState(() => _showPassword = !_showPassword),
                                        icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF808080)),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: _brandGrad,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(color: const Color(0xFFFF0080).withOpacity(.35), blurRadius: 20, offset: const Offset(0, 8)),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _loginAsAdmin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Text('LOGIN AS ADMIN',
                                              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(foregroundColor: const Color(0xFF00D4FF)),
                          child: const Text('Back to Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _brandGrad,
            boxShadow: [
              BoxShadow(color: const Color(0xFFFF0080).withOpacity(.45), blurRadius: 36, spreadRadius: 6),
              BoxShadow(color: const Color(0xFF00D4FF).withOpacity(.25), blurRadius: 44, spreadRadius: 8),
            ],
          ),
          child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => _brandGrad.createShader(bounds),
          child: const Text('ADMIN ACCESS',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 6),
        const Text('Secure entry required', style: TextStyle(color: Color(0xFF808080))),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon, Color? iconColor, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF808080)),
      prefixIcon: Icon(icon, color: iconColor ?? const Color(0xFFFF0080)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0x1AFFFFFF),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x33FFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x66FFFFFF)),
      ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(color: Color(0xFF808080), fontSize: 12, letterSpacing: 1.3, fontWeight: FontWeight.w600)),
        ),
        child,
      ],
    );
  }
}