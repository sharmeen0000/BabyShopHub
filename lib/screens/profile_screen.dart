import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  Map<String, String> user = {
    "name": "",
    "email": "",
    "address": "",
    "phone": "",
  };

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _animationController.forward();

    _loadUserData();
  }

  void _loadUserData() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        setState(() {
          user["name"] = currentUser.displayName ?? "User";
          user["email"] = currentUser.email ?? "";
          user["address"] = ""; // This would need to be stored separately in Firestore
          user["phone"] = ""; // This would need to be stored separately in Firestore
          
          _nameController.text = user["name"]!;
          _emailController.text = user["email"]!;
          _addressController.text = user["address"]!;
          _phoneController.text = user["phone"]!;
          
          _isLoading = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading user data: ${e.toString()}"),
          backgroundColor: Color(0xFFFF69B4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
    HapticFeedback.lightImpact();
  }

  void _saveProfile() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(_nameController.text);
        
        setState(() {
          user["name"] = _nameController.text;
          user["email"] = _emailController.text;
          user["address"] = _addressController.text;
          user["phone"] = _phoneController.text;
          _isEditing = false;
        });

        HapticFeedback.mediumImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text("Profile updated successfully!")),
              ],
            ),
            backgroundColor: Color(0xFF98FB98),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(12),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating profile: ${e.toString()}"),
          backgroundColor: Color(0xFFFF69B4),
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error signing out: ${e.toString()}"),
                    backgroundColor: Color(0xFFFF69B4),
                  ),
                );
              }
            },
            child: Text("LOGOUT", style: TextStyle(color: Color(0xFFFF69B4))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE8F5E8), Color(0xFFF0F8F0)],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E8), Color(0xFFF0F8F0)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: _buildProfileHeader(),
                    ),
                    _buildProfileStats(),
                    _buildProfileInfo(),
                    _buildSettingsSection(),
                    _buildActionButtons(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Color(0xFF4CAF50),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
            ),
          ),
        ),
        title: const Text("My Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      actions: [
        if (!_isEditing)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _toggleEditMode,
            tooltip: "Edit Profile",
          ),
        if (_isEditing)
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveProfile,
            tooltip: "Save Changes",
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Hero(
                tag: 'profile_image',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    child: Text(
                      user["name"]!.isNotEmpty ? user["name"]![0].toUpperCase() : "U",
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
              if (_isEditing)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _isEditing
              ? TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B7355)),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: "Your Name"),
                )
              : Text(
                  user["name"]!.isNotEmpty ? user["name"]! : "User",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B7355)),
                ),
          const SizedBox(height: 4),
          _isEditing
              ? TextField(
                  controller: _emailController,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF8B7355)),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: "Your Email"),
                  enabled: false,
                )
              : Text(
                  user["email"]!,
                  style: TextStyle(fontSize: 14, color: Color(0xFF8B7355)),
                ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Orders", "12"),
          _buildDivider(),
          _buildStatItem("Wishlist", "24"),
          _buildDivider(),
          _buildStatItem("Reviews", "8"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF8B7355))),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Color(0xFFDDA0DD).withOpacity(0.3));
  }

  Widget _buildProfileInfo() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B7355))),
            const SizedBox(height: 16),
            _buildInfoItem(icon: Icons.phone, title: "Phone Number", value: user["phone"]!, controller: _phoneController),
            const Divider(height: 24),
            _buildInfoItem(icon: Icons.location_on, title: "Address", value: user["address"]!, controller: _addressController),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required TextEditingController controller,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Color(0xFFFFB6C1).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: Color(0xFFFF69B4)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Color(0xFF8B7355))),
              const SizedBox(height: 4),
              _isEditing
                  ? TextField(
                      controller: controller,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF8B7355)),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: InputBorder.none,
                        hintText: "Enter $title",
                      ),
                    )
                  : Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF8B7355))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8B7355))),
            const SizedBox(height: 16),
            _buildSettingItem(
              icon: Icons.notifications,
              title: "Notifications",
              subtitle: "Receive order updates and promotions",
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  HapticFeedback.lightImpact();
                },
                activeColor: Color(0xFFFF69B4),
              ),
            ),
            const Divider(height: 24),
            _buildSettingItem(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              subtitle: "Switch between light and dark theme",
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  HapticFeedback.lightImpact();
                },
                activeColor: Color(0xFFFF69B4),
              ),
            ),
            const Divider(height: 24),
            _buildSettingItem(
              icon: Icons.receipt_long,
              title: "Order History",
              subtitle: "View your past orders",
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => OrderHistoryScreen()));
                },
              ),
            ),
            const Divider(height: 24),
            _buildSettingItem(
              icon: Icons.language,
              title: "Language",
              subtitle: "English (US)",
              trailing: IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16), onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Color(0xFFFFB6C1).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: Color(0xFFFF69B4)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF8B7355))),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Color(0xFF8B7355))),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("This feature is coming soon!"),
                  backgroundColor: Color(0xFF81C784),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(12),
                ),
              );
            },
            child: Text(
              "Delete Account",
              style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
