import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';
import '../pages/widgets/glass_card.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> with TickerProviderStateMixin {
  String _searchQuery = '';
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  bool _isInitialized = false;
  bool _hasShownError = false;
  final ValueNotifier<bool> _adminStatus = ValueNotifier<bool>(false);
  Timer? _toastTimer;
  bool _isRebuilding = false;

  @override
  void initState() {
    super.initState();
    debugPrint('CustomersPage: initState called');
    _setupAnimations();
    _checkAdminStatus();
  }

  void _setupAnimations() {
    debugPrint('CustomersPage: Setting up animations');
    _animationController?.dispose();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    ));
    _isInitialized = true;
    _animationController!.forward();
    debugPrint('CustomersPage: Animations initialized synchronously');
  }

  Future<void> _checkAdminStatus() async {
    if (_isRebuilding) return;
    _isRebuilding = true;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('CustomersPage: No user logged in');
      _adminStatus.value = false;
      _isRebuilding = false;
      return;
    }
    try {
      await user.reload();
      final idTokenResult = await user.getIdTokenResult(true);
      final isAdmin = idTokenResult.claims?['admin'] == true || user.email == 'teamapp@gmail.com';
      debugPrint('CustomersPage: Admin check: $isAdmin for ${user.email} (UID: ${user.uid}), claims: ${idTokenResult.claims}');
      _adminStatus.value = isAdmin;
      _isRebuilding = false;
    } catch (e) {
      debugPrint('CustomersPage: Error checking admin claim: $e');
      _adminStatus.value = user.email == 'teamapp@gmail.com';
      _isRebuilding = false;
    }
  }

  void _scheduleToast(String msg, {bool error = false}) {
    if (_toastTimer?.isActive ?? false) return;
    _toastTimer = Timer(Duration(milliseconds: 500), () {
      if (mounted) {
        _toast(msg, error: error);
        if (error && msg.contains('Error fetching')) {
          setState(() {
            _hasShownError = true;
          });
        }
      }
    });
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(error ? Icons.error_outline : Icons.check_circle, color: Color(0xFFFFFFFF)),
            SizedBox(width: 12),
            Expanded(child: Text(msg, style: TextStyle(color: Color(0xFFFFFFFF)))),
          ],
        ),
        backgroundColor: error ? Color(0xFFFF0080) : Color(0xFF00FF88),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Color(0xFFFF0080), width: 1),
        ),
        margin: EdgeInsets.all(12),
        elevation: 4,
        duration: Duration(seconds: 3),
        showCloseIcon: true,
        closeIconColor: Color(0xFFFFFFFF),
      ),
    );
  }

  Future<int> _getOrderCount(String userId) async {
    if (userId.isEmpty) {
      debugPrint('CustomersPage: Invalid userId for order count');
      return 0;
    }
    try {
      final query = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();
      return query.docs.length;
    } catch (e) {
      debugPrint('CustomersPage: Error fetching order count for $userId: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CustomersPage: Building widget, initialized: $_isInitialized');
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
          child: _isInitialized && _animationController != null
              ? ValueListenableBuilder<bool>(
                  valueListenable: _adminStatus,
                  builder: (context, isAdmin, child) {
                    if (!isAdmin) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Access denied: Admin only',
                              style: TextStyle(color: Color(0xFFFF0080), fontSize: 18),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _checkAdminStatus,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF00D4FF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Retry Admin Check', style: TextStyle(color: Color(0xFFFFFFFF))),
                            ),
                          ],
                        ),
                      );
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF)));
                        }
                        if (snapshot.hasError) {
                          debugPrint('CustomersPage: StreamBuilder error: ${snapshot.error}');
                          if (!_hasShownError) {
                            _scheduleToast('Error fetching customers: ${snapshot.error}', error: true);
                          }
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error fetching customers: ${snapshot.error}',
                                  style: TextStyle(color: Color(0xFFFF0080), fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => setState(() {}),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF00D4FF),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text('Retry Fetch', style: TextStyle(color: Color(0xFFFFFFFF))),
                                ),
                              ],
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          debugPrint('CustomersPage: No users found, docs: ${snapshot.data?.docs.length}');
                          return const Center(
                            child: Text(
                              'No customers found',
                              style: TextStyle(color: Color(0xFF808080), fontSize: 16),
                            ),
                          );
                        }

                        final customers = snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name = (data['displayName'] ?? '').toString().toLowerCase();
                          final email = (data['email'] ?? '').toString().toLowerCase();
                          debugPrint('CustomersPage: Filtering user: ${data['email']}, matches: ${name.contains(_searchQuery.toLowerCase()) || email.contains(_searchQuery.toLowerCase())}');
                          return name.contains(_searchQuery.toLowerCase()) || email.contains(_searchQuery.toLowerCase());
                        }).toList();
                        debugPrint('CustomersPage: Found ${customers.length} users');

                        return RefreshIndicator(
                          color: Color(0xFF00D4FF),
                          backgroundColor: Color(0xFF2A2A2A),
                          onRefresh: () async => FirebaseFirestore.instance.collection('users').get(),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                GlassCard(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.search, color: Color(0xFF00D4FF)),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          onChanged: (value) => setState(() => _searchQuery = value),
                                          style: TextStyle(color: Color(0xFFFFFFFF)),
                                          decoration: InputDecoration(
                                            hintText: 'Search customers by name or email...',
                                            hintStyle: TextStyle(color: Color(0xFF808080)),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12),
                                Expanded(
                                  child: customers.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No customers found',
                                            style: TextStyle(color: Color(0xFF808080), fontSize: 16),
                                          ),
                                        )
                                      : FadeTransition(
                                          opacity: _fadeAnimation!,
                                          child: SlideTransition(
                                            position: _slideAnimation!,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: GlassCard(
                                                padding: EdgeInsets.zero,
                                                child: DataTable(
                                                  headingTextStyle: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                  ),
                                                  headingRowColor: MaterialStateProperty.resolveWith((_) => Color(0x1AFFFFFF)),
                                                  dataRowColor: MaterialStateProperty.resolveWith((_) => Color(0x1AFFFFFF).withOpacity(0.05)),
                                                  columns: [
                                                    DataColumn(label: Padding(padding: EdgeInsets.all(12), child: Text('Name'))),
                                                    DataColumn(label: Padding(padding: EdgeInsets.all(12), child: Text('Email'))),
                                                    DataColumn(label: Padding(padding: EdgeInsets.all(12), child: Text('Orders Count'))),
                                                    DataColumn(label: Padding(padding: EdgeInsets.all(12), child: Text('Role'))),
                                                  ],
                                                  rows: customers.map((doc) {
                                                    final data = doc.data() as Map<String, dynamic>;
                                                    return DataRow(cells: [
                                                      DataCell(Padding(
                                                        padding: EdgeInsets.all(12),
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              backgroundColor: Color(0x1A00D4FF),
                                                              child: Text(
                                                                data['displayName']?.toString()[0] ?? '?',
                                                                style: TextStyle(color: Color(0xFF00D4FF)),
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              data['displayName'] ?? 'N/A',
                                                              style: TextStyle(color: Color(0xFFFFFFFF)),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                      DataCell(Padding(
                                                        padding: EdgeInsets.all(12),
                                                        child: Text(
                                                          data['email'] ?? 'N/A',
                                                          style: TextStyle(color: Color(0xFFBDBDBD)),
                                                        ),
                                                      )),
                                                      DataCell(Padding(
                                                        padding: EdgeInsets.all(12),
                                                        child: FutureBuilder<int>(
                                                          future: _getOrderCount(data['uid'] ?? ''),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                                              return CircularProgressIndicator(
                                                                color: Color(0xFF00D4FF),
                                                                strokeWidth: 2,
                                                              );
                                                            }
                                                            if (snapshot.hasError) {
                                                              debugPrint('CustomersPage: Order count error: ${snapshot.error}');
                                                              return Text('0', style: TextStyle(color: Color(0xFFFF0080)));
                                                            }
                                                            return Text(
                                                              '${snapshot.data ?? 0}',
                                                              style: TextStyle(color: Color(0xFFFF0080)),
                                                            );
                                                          },
                                                        ),
                                                      )),
                                                      DataCell(Padding(
                                                        padding: EdgeInsets.all(12),
                                                        child: Text(
                                                          data['role']?.toString().toUpperCase() ?? 'N/A',
                                                          style: TextStyle(
                                                            color: data['role'] == 'admin' ? Color(0xFF00D4FF) : Color(0xFFFF0080),
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      )),
                                                    ]);
                                                  }).toList(),
                                                ),
                                              ),
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
                )
              : const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF))),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _animationController?.dispose();
    _adminStatus.dispose();
    super.dispose();
  }
}