import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/cart_provider.dart';
import '../providers/order_history_provider.dart';
import 'checkout_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  
  String _selectedPaymentMethod = 'card';
  bool _isProcessingPayment = false;
  bool _saveCardInfo = false;
  
  // Form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  
  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    // Start animations
    _slideController.forward();
    _fadeController.forward();
    
    // Pre-fill some demo data
    _addressController.text = "123 Baby Street";
    _cityController.text = "Karachi";
    _zipController.text = "75500";
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    super.dispose();
  }
  
  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isProcessingPayment = true;
    });
    
    HapticFeedback.mediumImpact();
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 3));
    
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderHistoryProvider>(context, listen: false);
    
    // Calculate total
    final total = _calculateTotal(cartProvider);
    final itemsList = cartProvider.items.map((item) => item.title).toList();
    
    // Save to Firebase Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to place order')),
        );
        setState(() { _isProcessingPayment = false; });
        return;
      }
      
      // Refresh authentication token
      await user.getIdToken(true);
      
      final orderId = "BB${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
      
      final orderData = {
        'userId': user.uid,
        'email': user.email,
        'orderId': orderId,
        'items': itemsList,
        'totalAmount': total,
        'status': 'paid',
        'timestamp': Timestamp.now(),
        'address': _addressController.text,
        'city': _cityController.text,
        'zip': _zipController.text,
        'paymentMethod': _selectedPaymentMethod,
      };
      
      await FirebaseFirestore.instance.collection('orders').add(orderData);
      
      // Success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order saved to Firebase!')),
      );
    } catch (e) {
      print('Error saving order: $e'); // Log error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving order: $e')),
      );
      setState(() { _isProcessingPayment = false; });
      return;
    }
    
    // Add order to local history provider
    orderProvider.addOrder(itemsList);
    
    // Clear cart
    cartProvider.clearCart();
    
    setState(() {
      _isProcessingPayment = false;
    });
    
    // Navigate to success screen
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: CheckoutSuccessScreen(
              orderNumber: "BB${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
              totalAmount: total,
              items: itemsList,
              estimatedDelivery: "3-5 business days",
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    
    return Scaffold(
      backgroundColor: Color(0xFFFFF8F5),
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B7355),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF8B7355)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummary(cart),
                const SizedBox(height: 20),
                _buildPaymentMethods(),
                const SizedBox(height: 20),
                if (_selectedPaymentMethod == 'card') _buildCardForm(),
                if (_selectedPaymentMethod == 'paypal') _buildPayPalForm(),
                if (_selectedPaymentMethod == 'cod') _buildCODForm(),
                const SizedBox(height: 20),
                _buildShippingAddress(),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildPaymentButton(cart),
    );
  }
  
  Widget _buildOrderSummary(CartProvider cart) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Color(0xFFFF69B4)),
                const SizedBox(width: 8),
                const Text(
                  "Order Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B7355),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${item.title} x${item.quantity}",
                      style: const TextStyle(fontSize: 14, color: Color(0xFF8B7355)),
                    ),
                  ),
                  Text(
                    "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B7355),
                    ),
                  ),
                ],
              ),
            )).toList(),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal:", style: TextStyle(fontSize: 16, color: Color(0xFF8B7355))),
                Text(
                  "\$${cart.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF8B7355)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Shipping:", style: TextStyle(fontSize: 16, color: Color(0xFF8B7355))),
                Text(
                  cart.totalPrice > 25 ? "FREE" : "\$5.99",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cart.totalPrice > 25 ? Color(0xFF98FB98) : Color(0xFF8B7355),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tax:", style: TextStyle(fontSize: 16, color: Color(0xFF8B7355))),
                Text(
                  "\$${(cart.totalPrice * 0.08).toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF8B7355)),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B7355)),
                ),
                Text(
                  "\$${_calculateTotal(cart).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF69B4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  double _calculateTotal(CartProvider cart) {
    final subtotal = cart.totalPrice;
    final shipping = subtotal > 25 ? 0 : 5.99;
    final tax = subtotal * 0.08;
    return subtotal + shipping + tax;
  }
  
  Widget _buildPaymentMethods() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Payment Method",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B7355),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.credit_card, color: Color(0xFFFF69B4)),
              title: const Text("Credit/Debit Card", style: TextStyle(color:Color(0xFF8B7355 ),)),
              trailing: Radio<String>(
                value: 'card',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() { _selectedPaymentMethod = value!; });
                },
                activeColor: Color(0xFFFF69B4),
              ),
            ),
            ListTile(
              leading: Icon(Icons.paypal, color: Color(0xFFDDA0DD)),
              title: const Text("PayPal", style: TextStyle(color:Color(0xFF8B7355 ),)),
              trailing: Radio<String>(
                value: 'paypal',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() { _selectedPaymentMethod = value!; });
                },
                activeColor: Color(0xFFFF69B4),
              ),
            ),
            ListTile(
              leading: Icon(Icons.money, color: Color(0xFF98FB98)),
              title: const Text("Cash on Delivery", style: TextStyle(color:Color(0xFF8B7355 ),)),
              trailing: Radio<String>(
                value: 'cod',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() { _selectedPaymentMethod = value!; });
                },
                activeColor: Color(0xFFFF69B4),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCardForm() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Card Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B7355),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              style: const TextStyle(color: Color(0xFF8B7355)),
              decoration: InputDecoration(
                labelText: "Card Number",
                labelStyle: TextStyle(color: Color(0xFF8B7355)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFDDA0DD).withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF69B4)),
                ),
                prefixIcon: Icon(Icons.credit_card, color: Color(0xFFFF69B4)),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (value.length != 16) {
                  return 'Invalid card number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    style: const TextStyle(color: Color(0xFF8B7355)),
                    decoration: InputDecoration(
                      labelText: "Expiry (MM/YY)",
                      labelStyle: TextStyle(color: Color(0xFF8B7355)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFDDA0DD).withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF69B4)),
                      ),
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    style: const TextStyle(color: Color(0xFF8B7355)),
                    decoration: InputDecoration(
                      labelText: "CVV",
                      labelStyle: TextStyle(color: Color(0xFF8B7355)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFDDA0DD).withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF69B4)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (value.length < 3) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardHolderController,
              style: const TextStyle(color: Color(0xFF8B7355)),
              decoration: InputDecoration(
                labelText: "Card Holder Name",
                labelStyle: TextStyle(color: Color(0xFF8B7355)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFDDA0DD).withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF69B4)),
                ),
                prefixIcon: Icon(Icons.person, color: Color(0xFFFF69B4)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _saveCardInfo,
                  onChanged: (value) {
                    setState(() {
                      _saveCardInfo = value ?? false;
                    });
                  },
                  activeColor: Color(0xFFFF69B4),
                ),
                const Expanded(
                  child: Text(
                    "Save card information for future purchases",
                    style: TextStyle(color: Color(0xFF8B7355)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPayPalForm() {
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
            Icon(
              Icons.account_balance_wallet,
              size: 60,
              color: Color(0xFFDDA0DD),
            ),
            const SizedBox(height: 16),
            const Text(
              "You will be redirected to PayPal to complete your payment securely.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF8B7355)),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCODForm() {
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
            Icon(
              Icons.money,
              size: 60,
              color: Color(0xFF98FB98),
            ),
            const SizedBox(height: 16),
            const Text(
              "Pay with cash when your order is delivered to your doorstep.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF8B7355)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF98FB98).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF98FB98).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Color(0xFF98FB98), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Additional \$2.99 COD fee applies",
                      style: TextStyle(fontSize: 14, color: Color(0xFF8B7355)),
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
  
  Widget _buildShippingAddress() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Shipping Address",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B7355),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              style: const TextStyle(color: Color(0xFF8B7355)),
              decoration: InputDecoration(
                labelText: "Street Address",
                labelStyle: TextStyle(color: Color(0xFF8B7355)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFDDA0DD).withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFF69B4)),
                ),
                prefixIcon: Icon(Icons.home, color: Color(0xFFFF69B4)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    style: const TextStyle(color: Color(0xFF8B7355)),
                    decoration: InputDecoration(
                      labelText: "City",
                      labelStyle: TextStyle(color: Color(0xFF8B7355)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFDDA0DD).withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF69B4)),
                      ),
                      prefixIcon: Icon(Icons.location_city, color: Color(0xFFFF69B4)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _zipController,
                    style: const TextStyle(color: Color(0xFF8B7355)),
                    decoration: InputDecoration(
                      labelText: "ZIP code",
                      labelStyle: TextStyle(color: Color(0xFF8B7355)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFDDA0DD).withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFFF69B4)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentButton(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isProcessingPayment ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF69B4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: _isProcessingPayment
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Processing Payment...",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    "Pay \$${_calculateTotal(cart).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}