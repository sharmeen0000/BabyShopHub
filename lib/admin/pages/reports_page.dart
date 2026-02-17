import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/widgets/glass_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('ReportsPage: No user logged in');
      return false;
    }
    final isAdmin = user.email?.toLowerCase() == 'teamapp@gmail.com';
    debugPrint('ReportsPage: Admin check: $isAdmin for ${user.email} (UID: ${user.uid})');
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
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);

    return FutureBuilder<bool>(
      future: _isAdmin(),
      builder: (context, adminSnapshot) {
        if (!adminSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
        }
        if (!adminSnapshot.data!) {
          debugPrint('ReportsPage: Access denied: User is not an admin');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _toast(context, 'Access denied: Admin only', error: true);
          });
          return const Center(child: Text('Access denied: Admin only', style: TextStyle(color: Color(0xFFFF2D55), fontSize: 18)));
        }

        return RefreshIndicator(
          color: const Color(0xFF8B5CF6),
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ReportCard(
                title: 'Daily Sales',
                value: '\$579.96',
                subtitle: 'Total for ${startOfDay.day}/${startOfDay.month}/${startOfDay.year}',
              ),
              const SizedBox(height: 12),
              _ReportCard(
                title: 'Monthly Sales',
                value: '\$2450.75',
                subtitle: 'Total for ${startOfMonth.month}/${startOfMonth.year}',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _ReportCard({required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [Color(0xFFFF0080), Color(0xFF8B5CF6), Color(0xFF00D4FF)]),
            ),
            child: const Icon(Icons.bar_chart, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 12)),
            ]),
          ),
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(colors: [Color(0xFFFF0080), Color(0xFF8B5CF6), Color(0xFF00D4FF)]).createShader(r),
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}