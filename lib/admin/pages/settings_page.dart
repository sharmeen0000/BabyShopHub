import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/widgets/glass_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true;

  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('SettingsPage: No user logged in');
      return false;
    }
    final isAdmin = user.email?.toLowerCase() == 'teamapp@gmail.com';
    debugPrint('SettingsPage: Admin check: $isAdmin for ${user.email} (UID: ${user.uid})');
    return isAdmin;
  }

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _toast('Theme switched to ${_isDarkMode ? 'Dark' : 'Light'}');
    // Note: Actual theme switching requires ThemeData updates in main.dart
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    _toast('Signed out');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: error ? const Color(0xFFFF2D55) : const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
        elevation: 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdmin(),
      builder: (context, adminSnapshot) {
        if (!adminSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
        }
        if (!adminSnapshot.data!) {
          debugPrint('SettingsPage: Access denied: User is not an admin');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _toast('Access denied: Admin only', error: true);
          });
          return const Center(child: Text('Access denied: Admin only', style: TextStyle(color: Color(0xFFFF2D55), fontSize: 18)));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              GlassCard(
                child: ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFF00D4FF)),
                  title: Text('Admin: ${FirebaseAuth.instance.currentUser?.email ?? 'N/A'}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Manage your account', style: TextStyle(color: Color(0xFFBDBDBD))),
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: SwitchListTile(
                  activeColor: const Color(0xFF8B5CF6),
                  inactiveTrackColor: const Color(0xFF808080),
                  title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Toggle between dark and light theme', style: TextStyle(color: Color(0xFFBDBDBD))),
                  value: _isDarkMode,
                  onChanged: _toggleTheme,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Color(0xFFFF2D55)),
                  title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Log out of the admin panel', style: TextStyle(color: Color(0xFFBDBDBD))),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xCC121212),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Color(0xFFAAAAAA))),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B5CF6)))),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sign Out', style: TextStyle(color: Color(0xFFFF2D55)))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      _signOut();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}