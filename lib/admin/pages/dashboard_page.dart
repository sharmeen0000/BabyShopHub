import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/widgets/glass_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('DashboardPage: No user logged in');
      return false;
    }
    final isAdmin = user.email?.toLowerCase() == 'teamapp@gmail.com';
    debugPrint('DashboardPage: Admin check: $isAdmin for ${user.email} (UID: ${user.uid})');
    return isAdmin;
  }

  void _toast(BuildContext context, String msg, {bool error = false}) {
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
    final wide = MediaQuery.of(context).size.width > 900;
    final cross = wide ? 4 : 2;

    return FutureBuilder<bool>(
      future: _isAdmin(),
      builder: (context, adminSnapshot) {
        if (!adminSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
        }
        if (!adminSnapshot.data!) {
          debugPrint('DashboardPage: Access denied: User is not an admin');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _toast(context, 'Access denied: Admin only', error: true);
          });
          return const Center(child: Text('Access denied: Admin only', style: TextStyle(color: Color(0xFFFF2D55), fontSize: 18)));
        }

        return RefreshIndicator(
          color: const Color(0xFF8B5CF6),
          onRefresh: () async {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: cross,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _StatCard(title: 'Total Products', value: '4', icon: Icons.inventory_2),
                _StatCard(title: 'Total Orders', value: '4', icon: Icons.receipt_long),
                _StatCard(title: 'Total Customers', value: '4', icon: Icons.people),
                _StatCard(title: "Today's Sales", value: '\$579.96', icon: Icons.attach_money),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00D4FF), size: 32),
          const SizedBox(height: 10),
          Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFFCCCCCC), fontSize: 14)),
          const Spacer(),
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              colors: [Color(0xFFFF0080), Color(0xFF8B5CF6), Color(0xFF00D4FF)],
            ).createShader(r),
            child: Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
          ),
        ],
      ),
    );
  }
}