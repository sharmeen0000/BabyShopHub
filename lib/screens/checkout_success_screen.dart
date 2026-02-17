import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_navigation_screen.dart';
import 'order_history_screen.dart';

class CheckoutSuccessScreen extends StatefulWidget {
  final String? orderNumber;
  final double? totalAmount;
  final List<String>? items;
  final String? estimatedDelivery;

  const CheckoutSuccessScreen({
    super.key,
    this.orderNumber,
    this.totalAmount,
    this.items,
    this.estimatedDelivery,
  });

  @override
  State<CheckoutSuccessScreen> createState() => _CheckoutSuccessScreenState();
}

class _CheckoutSuccessScreenState extends State<CheckoutSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _confettiAnimationController;
  late AnimationController _pulseAnimationController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _confettiAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiAnimationController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
    
    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mainAnimationController.forward();
    _confettiAnimationController.forward();
    
    // Pulse animation loop
    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _confettiAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFE8F5E8), // Light green
                  Colors.white,
                  const Color(0xFFE1F5FE), // Light blue
                ],
              ),
            ),
          ),
          
          // Confetti animation
          _buildConfettiAnimation(size),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.05),
                  _buildSuccessIcon(),
                  const SizedBox(height: 32),
                  _buildSuccessMessage(),
                  const SizedBox(height: 24),
                  _buildOrderDetails(),
                  const SizedBox(height: 32),
                  _buildDeliveryInfo(),
                  SizedBox(height: size.height * 0.05),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiAnimation(Size size) {
    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final random = (index * 0.1) % 1.0;
            return Positioned(
              left: size.width * random,
              top: -50 + (size.height * 0.8 * _confettiAnimation.value),
              child: Transform.rotate(
                angle: _confettiAnimation.value * 6.28 * (index % 3 + 1),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: [
                      const Color(0xFF81C784), // Light green
                      const Color(0xFF64B5F6), // Light blue
                      const Color(0xFFFFB74D), // Light orange
                      const Color(0xFFBA68C8), // Light purple
                      const Color(0xFFF06292), // Light pink
                    ][index % 5],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSuccessIcon() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8), // Light green
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF81C784).withOpacity(0.3), // Light green
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_circle,
                size: 80,
                color: const Color(0xFF81C784), // Light green
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          const Text(
            "Order Placed Successfully! 🎉",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Thank you for shopping with BabyShopHub!\nYour order is being prepared with love.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: const Color(0xFF81C784), // Light green
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Order Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              "Order Number",
              widget.orderNumber ?? "#BB${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
            ),
            _buildDetailRow(
              "Total Amount",
              "\$${widget.totalAmount?.toStringAsFixed(2) ?? '0.00'}",
            ),
            _buildDetailRow(
              "Items",
              "${widget.items?.length ?? 0} products",
            ),
            _buildDetailRow(
              "Payment Status",
              "Confirmed",
              valueColor: const Color(0xFF81C784), // Light green
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE1F5FE), // Light blue
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF64B5F6)), // Light blue
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF64B5F6), // Light blue
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_shipping,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Estimated Delivery",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.estimatedDelivery ?? "3-5 business days",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, animation, __) {
                      return FadeTransition(
                        opacity: animation,
                        child: MainNavigationScreen(),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 500),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home),
              label: const Text("Continue Shopping"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF81C784), // Light green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrderHistoryScreen()),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text("View Order History"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF81C784), // Light green
                side: BorderSide(color: const Color(0xFF81C784)), // Light green
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
