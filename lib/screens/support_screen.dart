import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Added for optional Auth

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  String _selectedCategory = 'General';
  bool _isSubmitting = false;
  int _selectedTabIndex = 0;
  
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<String> _categories = [
    'General',
    'Order Issues',
    'Payment Problems',
    'Product Questions',
    'Account Help',
    'Technical Support',
    'Returns & Refunds',
    'Other'
  ];
  
  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How do I track my order?',
      'answer': 'You can track your order by going to "Order History" in your profile and clicking on the specific order. You\'ll see real-time updates on your order status.',
      'category': 'Orders'
    },
    {
      'question': 'What is your return policy?',
      'answer': 'We offer a 30-day return policy for all unused items in original packaging. Baby safety items cannot be returned once opened.',
      'category': 'Returns'
    },
    {
      'question': 'How long does shipping take?',
      'answer': 'Standard shipping takes 3-5 business days. Express shipping is available for 1-2 business days delivery.',
      'category': 'Shipping'
    },
    {
      'question': 'Are your products safe for newborns?',
      'answer': 'Yes, all our products meet international safety standards. Products suitable for newborns are clearly marked with age recommendations.',
      'category': 'Safety'
    },
    {
      'question': 'How do I change my delivery address?',
      'answer': 'You can change your delivery address in your profile settings under "Addresses" or contact our support team if your order has already been processed.',
      'category': 'Account'
    },
    {
      'question': 'Do you offer gift wrapping?',
      'answer': 'Yes! We offer complimentary gift wrapping for all orders. You can select this option during checkout.',
      'category': 'Services'
    },
  ];
  
  @override
  void initState() {
    super.initState();
    
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final feedbackData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'category': _selectedCategory,
        'message': _messageController.text.trim(),
        'timestamp': Timestamp.now(),
        'userId': FirebaseAuth.instance.currentUser?.uid, // Optional, null if not logged in
      };
      
      await FirebaseFirestore.instance.collection('feedback').add(feedbackData);
      
      // Clear form
      _messageController.clear();
      _emailController.clear();
      _nameController.clear();
      _selectedCategory = 'General';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text("Support ticket submitted successfully!"),
              ),
            ],
          ),
          backgroundColor: Color(0xFF98FB98),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(12),
          action: SnackBarAction(
            label: "VIEW",
            textColor: Colors.white,
            onPressed: () {
              // Navigate to ticket tracking
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildContactForm()
                : _selectedTabIndex == 1
                    ? _buildFAQSection()
                    : _buildContactInfo(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Support & Help",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xFFFF69B4),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone, color: Colors.white),
          onPressed: () {
            _showCallDialog();
          },
          tooltip: "Call Support",
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTabItem("Contact", 0, Icons.message),
          _buildTabItem("FAQ", 1, Icons.help_outline),
          _buildTabItem("Info", 2, Icons.info_outline),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          HapticFeedback.lightImpact();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Color(0xFFFF69B4) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Color(0xFFFF69B4) : Color(0xFF8B7355),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Color(0xFFFF69B4) : Color(0xFF8B7355),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildContactFormCard(),
                const SizedBox(height: 32),
                const Text(
                  "Other People's Feedback",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B7355),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeedbackList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('feedback')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading feedback: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final feedbacks = snapshot.data?.docs ?? [];
        if (feedbacks.isEmpty) {
          return const Center(child: Text('No feedback yet'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final data = feedbacks[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data['name'] ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B7355),
                          ),
                        ),
                        Text(
                          (data['timestamp'] as Timestamp?)?.toDate().toString() ?? '',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${data['category'] ?? ''}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['message'] ?? '',
                      style: TextStyle(color: Color(0xFF8B7355)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How can we help you?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "We're here to assist you 24/7",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B7355),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.chat_bubble_outline,
                title: "Live Chat",
                subtitle: "Chat with us now",
                color: Color(0xFF87CEEB),
                onTap: () {
                  _showLiveChatDialog();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.email_outlined,
                title: "Email Us",
                subtitle: "Get help via email",
                color: Color(0xFF98FB98),
                onTap: () {
                  // Scroll to contact form
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B7355),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8B7355),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactFormCard() {
    return Container(
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
              Icon(
                Icons.contact_support,
                color: Color(0xFFFF69B4),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                "Send us a message",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B7355),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Name Field
          _buildInputLabel("Your Name"),
          _buildTextField(
            controller: _nameController,
            hintText: "Enter your full name",
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Email Field
          _buildInputLabel("Email Address"),
          _buildTextField(
            controller: _emailController,
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
          const SizedBox(height: 16),
          
          // Category Dropdown
          _buildInputLabel("Category"),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          
          // Message Field
          _buildInputLabel("Message"),
          _buildMessageField(),
          const SizedBox(height: 24),
          
          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B7355),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFDDA0DD).withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: Color(0xFF8B7355)), // Added for typed text color
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFF8B7355).withOpacity(0.5)),
          prefixIcon: Icon(prefixIcon, color: Color(0xFFFF69B4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFFFFF8F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFDDA0DD).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF69B4)),
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 20,
                    color: Color(0xFFFF69B4),
                  ),
                  const SizedBox(width: 12),
                  Text(category, style: TextStyle(color: Color(0xFF8B7355))),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCategory = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFDDA0DD).withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: _messageController,
        maxLines: 5,
        style: TextStyle(color: Color(0xFF8B7355)), // Added for typed text color
        decoration: InputDecoration(
          hintText: "Describe your issue or feedback in detail...",
          hintStyle: TextStyle(color: Color(0xFF8B7355).withOpacity(0.5)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Icon(Icons.message_outlined, color: Color(0xFFFF69B4)),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your message';
          }
          if (value.length < 10) {
            return 'Message must be at least 10 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitFeedback,
        icon: _isSubmitting
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.send),
        label: Text(_isSubmitting ? "Submitting..." : "Submit Message"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF69B4),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFAQHeader(),
            const SizedBox(height: 20),
            _buildFAQList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFE6F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF87CEEB).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 254, 255, 255).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.help_outline,
              color: Color(0xFF87CEEB),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Frequently Asked Questions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B7355),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Find quick answers to common questions",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B7355),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQList() {
    return Column(
      children: _faqItems.map((faq) => _buildFAQItem(faq)).toList(),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B7355),
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Color(0xFFFFB6C1).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.help_outline,
            color: Color(0xFFFF69B4),
            size: 20,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer'],
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8B7355),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildContactInfoHeader(),
            const SizedBox(height: 20),
            _buildContactMethods(),
            const SizedBox(height: 20),
            _buildBusinessHours(),
            const SizedBox(height: 20),
            _buildSocialLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF98FB98), Color(0xFF90EE90)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.contact_phone,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Get in Touch",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 144, 141, 141),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "We're always here to help you",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 130, 127, 127),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethods() {
    return Column(
      children: [
        _buildContactMethodCard(
          icon: Icons.phone,
          title: "Phone Support",
          subtitle: "+1 (555) 123-4567",
          color: Color(0xFF98FB98),
          onTap: () => _showCallDialog(),
        ),
        const SizedBox(height: 12),
        _buildContactMethodCard(
          icon: Icons.email,
          title: "Email Support",
          subtitle: "support@babyshophub.com",
          color: Color(0xFF87CEEB),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildContactMethodCard(
          icon: Icons.location_on,
          title: "Visit Our Store",
          subtitle: "123 Baby Street, Karachi, Pakistan",
          color: Color(0xFFDDA0DD),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildContactMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B7355),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B7355),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF8B7355).withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHours() {
    return Container(
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
              Icon(
                Icons.access_time,
                color: Color(0xFFFF69B4),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                "Business Hours",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B7355),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildHourRow("Monday - Friday", "9:00 AM - 6:00 PM"),
          _buildHourRow("Saturday", "10:00 AM - 4:00 PM"),
          _buildHourRow("Sunday", "Closed"),
        ],
      ),
    );
  }

  Widget _buildHourRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF8B7355),
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8B7355),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Container(
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
              Icon(
                Icons.share,
                color: Color(0xFFFF69B4),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                "Follow Us",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B7355),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSocialButton(
                icon: Icons.facebook,
                color: Color(0xFF87CEEB),
                onTap: () {},
              ),
              _buildSocialButton(
                icon: Icons.camera_alt,
                color: Color(0xFFDDA0DD),
                onTap: () {},
              ),
              _buildSocialButton(
                icon: Icons.alternate_email,
                color: Color(0xFF87CEEB),
                onTap: () {},
              ),
              _buildSocialButton(
                icon: Icons.video_library,
                color: Color(0xFFFF69B4),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Order Issues':
        return Icons.shopping_bag_outlined;
      case 'Payment Problems':
        return Icons.payment;
      case 'Product Questions':
        return Icons.help_outline;
      case 'Account Help':
        return Icons.account_circle_outlined;
      case 'Technical Support':
        return Icons.build_outlined;
      case 'Returns & Refunds':
        return Icons.keyboard_return;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  void _showCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Call Support", style: TextStyle(color: Colors.white),),
        content: const Text("Would you like to call our support team at +1 (555) 123-4567?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Launch phone dialer
              HapticFeedback.mediumImpact();
            },
            child: const Text("CALL"),
          ),
        ],
      ),
    );
  }

  void _showLiveChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Color(0xFF98FB98),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text("Live Chat", style: TextStyle(color: Colors.white),),
          ],
        ),
        content: const Text("Our support team is online and ready to help you. Would you like to start a live chat session?"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("LATER"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Start live chat
              HapticFeedback.mediumImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF98FB98),
              foregroundColor: Colors.white,
            ),
            child: const Text("START CHAT"),
          ),
        ],
      ),
    );
  }
}