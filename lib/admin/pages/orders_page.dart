import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/widgets/glass_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
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
      debugPrint('OrdersPage: No user logged in');
      return false;
    }
    final isAdmin = user.email?.toLowerCase() == 'teamapp@gmail.com';
    debugPrint('OrdersPage: Admin check: $isAdmin for ${user.email} (UID: ${user.uid})');
    return isAdmin;
  }

  void _updateStatus(String docId, String status) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(docId).update({'status': status});
      _toast('Status updated');
    } catch (e) {
      _toast('Error updating status: $e', error: true);
    }
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

  // Validate status to ensure it matches DropdownButton items
  String _validateStatus(String? status) {
    const validStatuses = ['pending', 'processing', 'shipped', 'delivered'];
    return validStatuses.contains(status?.toLowerCase()) ? status! : 'pending';
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
          debugPrint('OrdersPage: Access denied: User is not an admin');
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
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
            }
            if (snapshot.hasError) {
              _toast('Error fetching orders: ${snapshot.error}', error: true);
              return const Center(
                child: Text(
                  'Error fetching orders',
                  style: TextStyle(color: Color(0xFFFF0080), fontSize: 16),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No orders found',
                  style: TextStyle(color: Color(0xFF808080), fontSize: 16),
                ),
              );
            }

            final orders = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return (data['orderId']?.toString().toLowerCase().contains(_search.toLowerCase()) ?? false) ||
                  (data['email']?.toString().toLowerCase().contains(_search.toLowerCase()) ?? false);
            }).toList();

            return RefreshIndicator(
              color: const Color(0xFF8B5CF6),
              backgroundColor: const Color(0xFF2A2A2A),
              onRefresh: () async => FirebaseFirestore.instance.collection('orders').get(),
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
                                hintText: 'Search orders by ID or email...',
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
                      child: orders.isEmpty
                          ? const Center(
                              child: Text(
                                'No orders found',
                                style: TextStyle(color: Color(0xFF808080), fontSize: 16),
                              ),
                            )
                          : FadeTransition(
                              opacity: _fadeAnimation!,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: GlassCard(
                                  padding: EdgeInsets.zero,
                                  child: DataTable(
                                    headingTextStyle: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                    headingRowColor:
                                        MaterialStateProperty.resolveWith((_) => const Color(0x1AFFFFFF)),
                                    dataRowColor:
                                        MaterialStateProperty.resolveWith((_) => const Color(0x1AFFFFFF).withOpacity(0.05)),
                                    columns: const [
                                      DataColumn(
                                        label: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Text('Order ID'),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Text('Email'),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Text('Amount'),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Text('Status'),
                                        ),
                                      ),
                                    ],
                                    rows: orders.map((doc) {
                                      final data = doc.data() as Map<String, dynamic>;
                                      final status = _validateStatus(data['status']);
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Text(
                                                data['orderId'] ?? 'N/A',
                                                style: const TextStyle(color: Color(0xFFFFFFFF)),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Text(
                                                data['email'] ?? 'N/A',
                                                style: const TextStyle(color: Color(0xFFB0B0B0)),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Text(
                                                '\$${data['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                                                style: const TextStyle(color: Color(0xFF00D4FF)),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: DropdownButton<String>(
                                                value: status,
                                                items: ['pending', 'processing', 'shipped', 'delivered']
                                                    .map((status) => DropdownMenuItem(
                                                          value: status,
                                                          child: Text(
                                                            status,
                                                            style: const TextStyle(color: Color(0xFFFF0080)),
                                                          ),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    _updateStatus(doc.id, value);
                                                  }
                                                },
                                                style: const TextStyle(color: Color(0xFFFF0080)),
                                                dropdownColor: const Color(0xFF2A2A2A),
                                                borderRadius: BorderRadius.circular(12),
                                                underline: const SizedBox(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
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
    );
  }
}