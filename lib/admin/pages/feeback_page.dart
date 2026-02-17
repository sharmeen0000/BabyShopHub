import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/widgets/glass_card.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> with TickerProviderStateMixin {
  String _search = '';
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeInOut,
    );
    _fadeController!.forward();
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    super.dispose();
  }

  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('FeedbackPage: No user logged in');
      return false;
    }
    final isAdmin = user.email?.toLowerCase() == 'teamapp@gmail.com';
    debugPrint('FeedbackPage: Admin check: $isAdmin for ${user.email} (UID: ${user.uid})');
    return isAdmin;
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Color(0xFFFFFFFF))),
        backgroundColor: error ? const Color(0xFFFF0080) : const Color(0xFF00FF88),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFFFF0080), width: 1),
        ),
        margin: const EdgeInsets.all(12),
        elevation: 4,
        duration: const Duration(seconds: 3),
        showCloseIcon: true,
        closeIconColor: const Color(0xFFFFFFFF),
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
          debugPrint('FeedbackPage: Access denied: User is not an admin');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _toast('Access denied: Admin only', error: true);
          });
          return const Center(
            child: Text(
              'Access denied: Admin only',
              style: TextStyle(color: Color(0xFFFF0080), fontSize: 18),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
            }
            if (snapshot.hasError) {
              _toast('Error fetching feedback: ${snapshot.error}', error: true);
              return const Center(
                child: Text(
                  'Error fetching feedback',
                  style: TextStyle(color: Color(0xFFFF0080), fontSize: 16),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No feedback found',
                  style: TextStyle(color: Color(0xFF808080), fontSize: 16),
                ),
              );
            }

            final feedback = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return (data['email']?.toString().toLowerCase().contains(_search.toLowerCase()) ?? false) ||
                  (data['message']?.toString().toLowerCase().contains(_search.toLowerCase()) ?? false);
            }).toList();

            return RefreshIndicator(
              color: const Color(0xFF8B5CF6),
              backgroundColor: const Color(0xFF2A2A2A),
              onRefresh: () async => FirebaseFirestore.instance.collection('feedback').get(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _search = v),
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                              decoration: const InputDecoration(
                                hintText: 'Search feedback by email or message...',
                                hintStyle: TextStyle(color: Color(0xFF808080)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: feedback.isEmpty
                          ? const Center(
                              child: Text(
                                'No feedback found',
                                style: TextStyle(color: Color(0xFF808080), fontSize: 16),
                              ),
                            )
                          : FadeTransition(
                              opacity: _fadeAnimation!,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: feedback.map((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    return GlassCard(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: const Icon(Icons.feedback, color: Color(0xFF00D4FF)),
                                        title: Text(data['message'] ?? 'N/A', style: const TextStyle(color: Color(0xFFFFFFFF))),
                                        subtitle: Text(
                                          'By ${data['email'] ?? 'N/A'} | Category: ${data['category'] ?? 'General'} | ${data['timestamp']?.toDate().toString().substring(0, 16) ?? 'N/A'}',
                                          style: const TextStyle(color: Color(0xFFB0B0B0)),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
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
}