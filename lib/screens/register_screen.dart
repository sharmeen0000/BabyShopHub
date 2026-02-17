import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_navigation_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String _selectedRole = 'user'; // Added role selection
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFFFFFFF)),
              SizedBox(width: 12),
              Expanded(child: Text('Please accept the terms and conditions')),
            ],
          ),
          backgroundColor: const Color(0xFFFF0080),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Color(0xFFFF0080), width: 1),
          ),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
          showCloseIcon: true,
          closeIconColor: const Color(0xFFFFFFFF),
        ),
      );
      return;
    }
    
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      await userCredential.user?.updateDisplayName(nameController.text.trim());
      await userCredential.user?.sendEmailVerification();
      
      // Save user data to Firestore 'users' collection
      try {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': emailController.text.trim(),
          'displayName': nameController.text.trim(),
          'role': _selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (firestoreError) {
        throw Exception('Failed to save user data to Firestore: $firestoreError');
      }
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFFFFFFFF)),
              SizedBox(width: 12),
              Expanded(
                child: Text('Account created successfully as $_selectedRole! Please check your email for verification.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00FF88),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Color(0xFFFF0080), width: 1),
          ),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
          showCloseIcon: true,
          closeIconColor: const Color(0xFFFFFFFF),
        ),
      );
      
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) {
            return FadeTransition(
              opacity: animation,
              child: LoginScreen(),
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFFFFFFF)),
              SizedBox(width: 12),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: const Color(0xFFFF0080),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Color(0xFFFF0080), width: 1),
          ),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
          showCloseIcon: true,
          closeIconColor: const Color(0xFFFFFFFF),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFFFFFFF)),
              SizedBox(width: 12),
              Expanded(child: Text('Registration failed: $e')),
            ],
          ),
          backgroundColor: const Color(0xFFFF0080),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Color(0xFFFF0080), width: 1),
          ),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 3),
          showCloseIcon: true,
          closeIconColor: const Color(0xFFFFFFFF),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0A0A0A),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.03),
                  _buildHeader(height),
                  SizedBox(height: height * 0.03),
                  _buildRoleSelection(),
                  const SizedBox(height: 24),
                  _buildRegisterForm(),
                  const SizedBox(height: 20),
                  _buildTermsAndConditions(),
                  const SizedBox(height: 24),
                  _buildRegisterButton(),
                  const SizedBox(height: 24),
                  _buildSocialRegister(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double height) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Hero(
            tag: 'logo',
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00D4FF),
                    Color(0xFF8B5CF6),
                    Color(0xFFFF0080),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF0080).withOpacity(0.3),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_bag_rounded,
                size: height * 0.07,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFF00D4FF),
                Color(0xFF8B5CF6),
                Color(0xFFFF0080),
              ],
            ).createShader(bounds),
            child: const Text(
              "CREATE ACCOUNT",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Join the future of baby shopping",
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF808080),
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0x33FFFFFF), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = 'user';
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedRole == 'user' 
                          ? const Color(0xFFFF0080) 
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _selectedRole == 'user' ? [
                        BoxShadow(
                          color: const Color(0xFFFF0080).withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ] : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: _selectedRole == 'user' 
                              ? Colors.white 
                              : const Color(0xFF808080),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'USER',
                          style: TextStyle(
                            color: _selectedRole == 'user' 
                                ? Colors.white 
                                : const Color(0xFF808080),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Expanded(
              //   child: GestureDetector(
              //     // onTap: () {
              //     //   setState(() {
              //     //     _selectedRole = 'admin';
              //     //   }
              //     //   );
              //     //   HapticFeedback.lightImpact();
              //     // },
              //     child: Container(
              //       // padding: const EdgeInsets.symmetric(vertical: 12),
              //       // decoration: BoxDecoration(
              //       //   // color: _selectedRole == 'admin' 
              //       //       // ? const Color(0xFF00D4FF) 
              //       //       // : Colors.transparent,
              //       //   // borderRadius: BorderRadius.circular(20),
              //       //   // boxShadow: _selectedRole == 'admin' ? [
              //       //   //   BoxShadow(
              //       //   //     color: const Color(0xFF00D4FF).withOpacity(0.3),
              //       //   //     blurRadius: 10,
              //       //   //     spreadRadius: 2,
              //       //   //   ),
              //       //   // ] : null,
              //       // ),
              //       child: Row(
              //         // mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           // Icon(
              //           //   Icons.admin_panel_settings_outlined,
              //           //   color: _selectedRole == 'admin' 
              //           //       ? Colors.white 
              //           //       : const Color(0xFF808080),
              //           //   size: 20,
              //           // ),
              //           // const SizedBox(width: 8),
              //           // Text(
              //           //   'ADMIN',
              //           //   style: TextStyle(
              //           //     color: _selectedRole == 'admin' 
              //           //         ? Colors.white 
              //           //         : const Color(0xFF808080),
              //           //     fontWeight: FontWeight.w600,
              //           //     letterSpacing: 1.0,
              //           //   ),
              //           // ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputLabel("FULL NAME"),
            _buildTextField(
              controller: nameController,
              hintText: "Enter your full name",
              prefixIcon: Icons.person_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _buildInputLabel("EMAIL"),
            _buildTextField(
              controller: emailController,
              hintText: "Enter your email address",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _buildInputLabel("PHONE NUMBER"),
            _buildTextField(
              controller: phoneController,
              hintText: "Enter your phone number",
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Phone number must be at least 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _buildInputLabel("PASSWORD"),
            _buildTextField(
              controller: passwordController,
              hintText: "Create a password",
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF808080),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            
            _buildInputLabel("CONFIRM PASSWORD"),
            _buildTextField(
              controller: confirmPasswordController,
              hintText: "Confirm your password",
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF808080),
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF808080),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon, 
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33FFFFFF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: const Color(0xFF808080)),
          prefixIcon: Icon(prefixIcon, color: const Color(0xFFFF0080)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return SlideTransition(
      position: _slideAnimation,
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
              value: _acceptTerms,
              activeColor: const Color(0xFFFF0080),
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(color: const Color(0x33FFFFFF), width: 2),
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: 'I agree to the ',
                style: TextStyle(color: const Color(0xFF808080)),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: const Color(0xFF00D4FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: const Color(0xFF00D4FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF00D4FF),
              Color(0xFF8B5CF6),
              Color(0xFFFF0080),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4FF).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  "CREATE ACCOUNT",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSocialRegister() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: const Color(0x33FFFFFF))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "OR REGISTER WITH",
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF808080),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(child: Divider(color: const Color(0x33FFFFFF))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                color: const Color(0xFFFF0080),
                onTap: () {},
              ),
              const SizedBox(width: 20),
              _buildSocialButton(
                icon: Icons.facebook,
                color: const Color(0xFF00D4FF),
                onTap: () {},
              ),
              const SizedBox(width: 20),
              _buildSocialButton(
                icon: Icons.apple,
                color: const Color(0xFF8B5CF6),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x33FFFFFF), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 30,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account?",
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF808080),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) {
                    return FadeTransition(
                      opacity: animation,
                      child: LoginScreen(),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF00D4FF),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              "LOGIN",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}