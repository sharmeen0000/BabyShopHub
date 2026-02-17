import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';
import '../providers/order_history_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with TickerProviderStateMixin {
  String _filterStatus = 'All'; // 'All', 'Processing', 'Shipped', 'Delivered'
  int _expandedOrderIndex = -1;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );
    
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Order> _filterOrders(List<Order> orders) {
    if (_filterStatus == 'All') {
      return orders;
    }
    return orders.where((order) => order.status == _filterStatus).toList();
  }

  List<Order> _searchOrders(List<Order> orders) {
    if (_searchController.text.isEmpty) {
      return orders;
    }
    
    final query = _searchController.text.toLowerCase();
    return orders.where((order) {
      return order.orderId.toLowerCase().contains(query) ||
          order.items.any((item) => item.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderHistoryProvider>(context);
    final allOrders = orderProvider.orders;
    final filteredOrders = _searchOrders(_filterOrders(allOrders));
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E8), Color(0xFFF0F8F0)],
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            if (_isSearching) _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: filteredOrders.isEmpty
                  ? _buildEmptyState()
                  : _buildOrdersList(filteredOrders),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? null
          : const Text(
              "Order History",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B7355),
              ),
            ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF8B7355)),
        onPressed: () => Navigator.of(context).pop(MainNavigationScreen()),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: Color(0xFF8B7355),
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
              }
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.filter_list, color: Color(0xFF8B7355)),
          onPressed: _showFilterOptions,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Color(0xFF8B7355)),
        decoration: InputDecoration(
          hintText: "Search orders...",
          hintStyle: TextStyle(color: Color(0xFF8B7355).withOpacity(0.5)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF8B7355).withOpacity(0.5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Color(0xFFFFF8F5),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Processing', 'Shipped', 'Delivered'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((filter) {
            final isSelected = _filterStatus == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _filterStatus = filter;
                  });
                  HapticFeedback.lightImpact();
                },
                backgroundColor: Color(0xFFFFF8F5),
                selectedColor: Color(0xFFFFB6C1).withOpacity(0.3),
                checkmarkColor: Color(0xFFFF69B4),
                labelStyle: TextStyle(
                  color: isSelected ? Color(0xFFFF69B4) : Color(0xFF8B7355),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(
                    color: isSelected ? Color(0xFFFFB6C1) : Colors.transparent,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No orders found",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B7355),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isSearching || _filterStatus != 'All'
                  ? "Try changing your search or filter"
                  : "Start shopping to see your orders here",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8B7355),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text("Start Shopping"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        itemCount: orders.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final order = orders[index];
          final isExpanded = _expandedOrderIndex == index;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 16),
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
                InkWell(
                  onTap: () {
                    setState(() {
                      _expandedOrderIndex = isExpanded ? -1 : index;
                    });
                    HapticFeedback.lightImpact();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order #${order.orderId}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B7355),
                              ),
                            ),
                            _buildStatusBadge(order.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Color(0xFF8B7355),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.date,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8B7355),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.shopping_bag,
                              size: 14,
                              color: Color(0xFF8B7355),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${order.items.length} items",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8B7355),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildOrderTracker(order.steps, order.status),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isExpanded ? "Hide Details" : "View Details",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF69B4),
                              ),
                            ),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 16,
                              color: Color(0xFFFF69B4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: isExpanded
                      ? _buildOrderDetails(order)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case 'Processing':
        color = Color(0xFFDDA0DD);
        icon = Icons.hourglass_empty;
        break;
      case 'Shipped':
        color = Color(0xFF87CEEB);
        icon = Icons.local_shipping;
        break;
      case 'Delivered':
        color = Color(0xFF98FB98);
        icon = Icons.check_circle;
        break;
      default:
        color = Color(0xFF8B7355);
        icon = Icons.info;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTracker(List<String> steps, String currentStatus) {
    final currentIndex = steps.indexOf(currentStatus);
    
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        // Even indices are steps, odd indices are connectors
        if (index.isEven) {
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex <= currentIndex;
          
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Color(0xFF98FB98)
                        : Color(0xFFDDA0DD).withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? Color(0xFF228B22)
                          : Color(0xFF8B7355).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  steps[stepIndex],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Color(0xFF8B7355) : Color(0xFF8B7355).withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          final connectorIndex = index ~/ 2;
          final isCompleted = connectorIndex < currentIndex;
          
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? Color(0xFF98FB98) : Color(0xFFDDA0DD).withOpacity(0.3),
            ),
          );
        }
      }),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFF8F5),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            "Items",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B7355),
            ),
          ),
          const SizedBox(height: 8),
          ...order.items.map((item) => _buildOrderItem(item)).toList(),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B7355),
                ),
              ),
              Text(
                "\$${(order.items.length * 25.99).toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF69B4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.receipt),
                  label: const Text("Invoice"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF8B7355),
                    side: BorderSide(color: Color(0xFFDDA0DD).withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.replay),
                  label: const Text("Reorder"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF69B4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFDDA0DD).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shopping_bag,
              size: 20,
              color: Color(0xFFFF69B4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B7355),
              ),
            ),
          ),
          Text(
            "\$25.99",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF69B4),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFFDDA0DD).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Filter Orders",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B7355),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.all_inclusive, color: Color(0xFF8B7355)),
              title: const Text("All Orders", style: TextStyle(color: Color(0xFF8B7355))),
              trailing: _filterStatus == 'All'
                  ? Icon(Icons.check, color: Color(0xFFFF69B4))
                  : null,
              onTap: () {
                setState(() {
                  _filterStatus = 'All';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.hourglass_empty, color: Color(0xFFDDA0DD)),
              title: const Text("Processing", style: TextStyle(color: Color(0xFF8B7355))),
              trailing: _filterStatus == 'Processing'
                  ? Icon(Icons.check, color: Color(0xFFFF69B4))
                  : null,
              onTap: () {
                setState(() {
                  _filterStatus = 'Processing';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Color(0xFF87CEEB)),
              title: const Text("Shipped", style: TextStyle(color: Color(0xFF8B7355))),
              trailing: _filterStatus == 'Shipped'
                  ? Icon(Icons.check, color: Color(0xFFFF69B4))
                  : null,
              onTap: () {
                setState(() {
                  _filterStatus = 'Shipped';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF98FB98)),
              title: const Text("Delivered", style: TextStyle(color: Color(0xFF8B7355))),
              trailing: _filterStatus == 'Delivered'
                  ? Icon(Icons.check, color: Color(0xFFFF69B4))
                  : null,
              onTap: () {
                setState(() {
                  _filterStatus = 'Delivered';
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}