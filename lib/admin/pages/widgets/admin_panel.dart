import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/admin/pages/feeback_page.dart';
import '../dashboard_page.dart';
import '../products_page.dart';
import '../orders_page.dart';
import '../customers_page.dart';
import '../reports_page.dart';
import '../settings_page.dart';
import 'dart:ui';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int _index = 0;

  final _pages = const [
    DashboardPage(),
    ProductsPage(),
    OrdersPage(),
    CustomersPage(),
    ReportsPage(),
    SettingsPage(),
    FeedbackPage(),
  ];

  final _titles = const [
    'Dashboard',
    'Products',
    'Orders',
    'Customers',
    'Reports',
    'Settings',
    'Feedback',
  ];

  final _brandGrad = const LinearGradient(
    colors: [Color(0xFFFF0080), Color(0xFF8B5CF6), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Future<void> _logout() async {
    debugPrint('AdminPanel: Initiating logout');
    await FirebaseAuth.instance.signOut();
    if (!mounted) {
      debugPrint('AdminPanel: Widget not mounted, skipping navigation');
      return;
    }
    debugPrint('AdminPanel: Logout successful, navigating back');
    Navigator.of(context).pop();
  }

  void _onDestinationSelected(int index) {
    if (!mounted) {
      debugPrint('AdminPanel: Widget not mounted, skipping navigation to index $index');
      return;
    }
    debugPrint('AdminPanel: Switching to page ${_titles[index]} (index: $index)');
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AdminPanel: Building with index $_index (${_titles[_index]})');
    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF141414).withOpacity(0.8),
                    const Color(0xFF0C0C0C).withOpacity(0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: _brandGrad,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback: (b) => _brandGrad.createShader(b),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 400),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          shadows: [
                            Shadow(
                              color: const Color(0xFF8B5CF6).withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(_titles[_index]),
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'Logout',
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0x1AFFFFFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
              Color(0xFF050505),
            ],
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _pages[_index],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF141414).withOpacity(0.7),
                  const Color(0xFF0C0C0C).withOpacity(0.5),
                ],
              ),
              border: const Border(top: BorderSide(color: Color(0x33FFFFFF))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              indicatorColor: const Color(0x1A8B5CF6),
              height: 72,
              selectedIndex: _index,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              onDestinationSelected: _onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: Colors.white70),
                  selectedIcon: Icon(Icons.home, color: Color(0xFFFF0080)),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined, color: Colors.white70),
                  selectedIcon: Icon(Icons.inventory_2, color: Color(0xFF8B5CF6)),
                  label: 'Products',
                ),
                NavigationDestination(
                  icon: Icon(Icons.local_shipping_outlined, color: Colors.white70),
                  selectedIcon: Icon(Icons.local_shipping, color: Color(0xFF00D4FF)),
                  label: 'Orders',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline, color: Colors.white70),
                  selectedIcon: Icon(Icons.people, color: Color(0xFFFF0080)),
                  label: 'Customers',
                ),
                NavigationDestination(
                  icon: Icon(Icons.query_stats_outlined, color: Colors.white70),
                  selectedIcon: Icon(Icons.query_stats, color: Color(0xFF8B5CF6)),
                  label: 'Reports',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined, color: Colors.white70),
                  selectedIcon: Icon(Icons.settings, color: Color(0xFF00D4FF)),
                  label: 'Settings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.feedback_outlined, color: Colors.white70),
                  selectedIcon: Icon(Icons.feedback, color: Color(0xFFFF0080)),
                  label: 'Feedback',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}