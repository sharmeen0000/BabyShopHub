import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/widgets/glass_card.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _search = '';
  List<Map<String, dynamic>> _products = [
    {'id': '1', 'name': 'Baby Stroller', 'price': 199.99, 'stock': 10, 'category': 'Travel', 'description': 'High-quality baby stroller with adjustable features.'},
    {'id': '2', 'name': 'Diaper Pack', 'price': 29.99, 'stock': 50, 'category': 'Diapers', 'description': 'Pack of eco-friendly disposable diapers.'},
    {'id': '3', 'name': 'Baby Bottle Set', 'price': 19.99, 'stock': 30, 'category': 'Feeding', 'description': 'Set of anti-colic baby bottles.'},
    {'id': '4', 'name': 'Crib', 'price': 299.99, 'stock': 5, 'category': 'Sleeping', 'description': 'Safe and comfortable crib for newborns.'},
    {'id': '5', 'name': 'High Chair', 'price': 149.99, 'stock': 15, 'category': 'Feeding', 'description': 'Adjustable high chair for feeding time.'},
    {'id': '6', 'name': 'Baby Carrier', 'price': 89.99, 'stock': 25, 'category': 'Travel', 'description': 'Ergonomic baby carrier for hands-free carrying.'},
    {'id': '7', 'name': 'Baby Monitor', 'price': 129.99, 'stock': 20, 'category': 'Safety', 'description': 'Video baby monitor with night vision.'},
    {'id': '8', 'name': 'Bassinet', 'price': 179.99, 'stock': 8, 'category': 'Sleeping', 'description': 'Portable bassinet for safe sleeping.'},
    {'id': '9', 'name': 'Diaper Bag', 'price': 59.99, 'stock': 35, 'category': 'Accessories', 'description': 'Spacious diaper bag with multiple compartments.'},
    {'id': '10', 'name': 'Play Gym', 'price': 69.99, 'stock': 40, 'category': 'Toys', 'description': 'Activity play gym for baby development.'},
    {'id': '11', 'name': 'Car Seat', 'price': 249.99, 'stock': 12, 'category': 'Travel', 'description': 'Infant car seat with safety features.'},
    {'id': '12', 'name': 'Nursery Glider', 'price': 199.99, 'stock': 7, 'category': 'Furniture', 'description': 'Comfortable glider chair for nursery.'},
    {'id': '13', 'name': 'Travel Crib', 'price': 99.99, 'stock': 18, 'category': 'Sleeping', 'description': 'Foldable travel crib for on-the-go.'},
    {'id': '14', 'name': 'Pacifier Set', 'price': 9.99, 'stock': 100, 'category': 'Comfort', 'description': 'Set of orthodontic pacifiers.'},
    {'id': '15', 'name': 'Baby Blanket', 'price': 24.99, 'stock': 60, 'category': 'Clothing', 'description': 'Soft and warm baby blanket.'},
    {'id': '16', 'name': 'Bottle Sterilizer', 'price': 79.99, 'stock': 22, 'category': 'Feeding', 'description': 'Electric sterilizer for baby bottles.'},
    {'id': '17', 'name': 'Baby Swing', 'price': 139.99, 'stock': 14, 'category': 'Comfort', 'description': 'Gentle rocking swing with music.'},
    {'id': '18', 'name': 'Teething Rings', 'price': 12.99, 'stock': 80, 'category': 'Comfort', 'description': 'Safe and soft teething rings for babies.'},
    {'id': '19', 'name': 'Changing Pad', 'price': 34.99, 'stock': 45, 'category': 'Diapers', 'description': 'Waterproof changing pad for easy diaper changes.'},
    {'id': '20', 'name': 'Baby Lotion', 'price': 15.99, 'stock': 70, 'category': 'Baby Care', 'description': 'Gentle moisturizing lotion for baby skin.'},
    {'id': '21', 'name': 'Rattle Set', 'price': 14.99, 'stock': 65, 'category': 'Toys', 'description': 'Colorful rattles for sensory development.'},
    {'id': '22', 'name': 'Baby Bibs', 'price': 10.99, 'stock': 90, 'category': 'Feeding', 'description': 'Set of waterproof bibs with cute designs.'},
    {'id': '23', 'name': 'Nursery Organizer', 'price': 49.99, 'stock': 28, 'category': 'Accessories', 'description': 'Hanging organizer for nursery essentials.'},
    {'id': '24', 'name': 'Baby Thermometer', 'price': 29.99, 'stock': 55, 'category': 'Safety', 'description': 'Digital thermometer for accurate readings.'},
    {'id': '25', 'name': 'Musical Mobile', 'price': 39.99, 'stock': 33, 'category': 'Sleeping', 'description': 'Crib mobile with soothing melodies.'},
    {'id': '26', 'name': 'Bouncer Seat', 'price': 89.99, 'stock': 20, 'category': 'Comfort', 'description': 'Vibrating bouncer seat for calming babies.'},
    {'id': '27', 'name': 'Baby Shampoo', 'price': 11.99, 'stock': 85, 'category': 'Baby Care', 'description': 'Tear-free shampoo for gentle cleaning.'},
    {'id': '28', 'name': 'Activity Cube', 'price': 24.99, 'stock': 50, 'category': 'Toys', 'description': 'Interactive cube for motor skill development.'},
    {'id': '29', 'name': 'Safety Gate', 'price': 59.99, 'stock': 25, 'category': 'Safety', 'description': 'Adjustable gate for childproofing.'},
    {'id': '30', 'name': 'Swaddle Blankets', 'price': 19.99, 'stock': 75, 'category': 'Clothing', 'description': 'Soft swaddle blankets for cozy sleep.'},
  ];

  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('ProductsPage: No user logged in');
      return false;
    }
    final isAdmin = user.email?.toLowerCase() == 'teamapp@gmail.com';
    debugPrint('ProductsPage: Admin check: $isAdmin for ${user.email} (UID: ${user.uid})');
    return isAdmin;
  }

  void _addProduct(Map<String, dynamic> product) {
    setState(() {
      _products.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        ...product,
      });
    });
    _toast('Product added');
  }

  void _editProduct(String id, Map<String, dynamic> updated) {
    setState(() {
      final index = _products.indexWhere((p) => p['id'] == id);
      if (index != -1) {
        _products[index] = {'id': id, ...updated};
      }
    });
    _toast('Product updated');
  }

  void _deleteProduct(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xCC121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Product', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this baby product?', style: TextStyle(color: Color(0xFFAAAAAA))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B5CF6)))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFFF2D55)))),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        _products.removeWhere((p) => p['id'] == id);
      });
      _toast('Product deleted');
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
          debugPrint('ProductsPage: Access denied: User is not an admin');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _toast('Access denied: Admin only', error: true);
          });
          return const Center(child: Text('Access denied: Admin only', style: TextStyle(color: Color(0xFFFF2D55), fontSize: 18)));
        }

        final filteredProducts = _products.where((p) {
          final nameMatch = p['name'].toString().toLowerCase().contains(_search.toLowerCase());
          final categoryMatch = p['category'].toString().toLowerCase().contains(_search.toLowerCase());
          return nameMatch || categoryMatch;
        }).toList();

        return RefreshIndicator(
          color: const Color(0xFF8B5CF6),
          onRefresh: () async => setState(() {}),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search baby products by name or category...',
                            hintStyle: TextStyle(color: Color(0xFF808080)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () async {
                          final result = await showDialog<Map<String, dynamic>>(
                            context: context,
                            builder: (_) => const _ProductDialog(),
                          );
                          if (result != null) {
                            _addProduct(result);
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        child: DataTable(
                          headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          headingRowColor: MaterialStateProperty.resolveWith((_) => const Color(0x1AFFFFFF)),
                          columns: const [
                            DataColumn(label: Padding(padding: EdgeInsets.all(12), child: Text('Name'))),
                            DataColumn(label: Padding(padding: EdgeInsets.all(12), child: Text('Description'))),
                            DataColumn(label: Padding(padding: EdgeInsets.all(12), child: Text('Price'))),
                            DataColumn(label: Padding(padding: EdgeInsets.all(12), child: Text('Stock'))),
                            DataColumn(label: Padding(padding: EdgeInsets.all(12), child: Text('Category'))),
                            DataColumn(label: Padding(padding: EdgeInsets.all(12), child: Text('Actions'))),
                          ],
                          rows: filteredProducts.map((data) {
                            return DataRow(cells: [
                              DataCell(Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(data['name'] ?? 'N/A', style: const TextStyle(color: Colors.white)))),
                              DataCell(Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    data['description'] ?? 'N/A',
                                    style: const TextStyle(color: Color(0xFFBDBDBD)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                              DataCell(Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text('\$${data['price']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: const TextStyle(color: Color(0xFF00D4FF))))),
                              DataCell(Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text('${data['stock'] ?? 0}', style: const TextStyle(color: Color(0xFFFF0080))))),
                              DataCell(Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(data['category'] ?? 'N/A', style: const TextStyle(color: Color(0xFF00FF88))))),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF8B5CF6)),
                                    onPressed: () async {
                                      final result = await showDialog<Map<String, dynamic>>(
                                        context: context,
                                        builder: (_) => _ProductDialog(initial: data),
                                      );
                                      if (result != null) {
                                        _editProduct(data['id'], result);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Color(0xFFFF2D55)),
                                    onPressed: () => _deleteProduct(data['id']),
                                  ),
                                ],
                              )),
                            ]);
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
  }
}

class _ProductDialog extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const _ProductDialog({this.initial});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _category = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _name.text = widget.initial!['name']?.toString() ?? '';
      _description.text = widget.initial!['description']?.toString() ?? '';
      _price.text = widget.initial!['price']?.toString() ?? '';
      _stock.text = widget.initial!['stock']?.toString() ?? '';
      _category.text = widget.initial!['category']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    _category.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'price': double.tryParse(_price.text.trim()) ?? 0.0,
      'stock': int.tryParse(_stock.text.trim()) ?? 0,
      'category': _category.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xCC121212),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Baby Product', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _name,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0x33FFFFFF))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0x66FFFFFF))),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _description,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0x33FFFFFF))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0x66FFFFFF))),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Price',
                    labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0x33FFFFFF))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0x66FFFFFF))),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null) ? 'Enter a valid price' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0x33FFFFFF))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0x66FFFFFF))),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null) ? 'Enter a valid stock number' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _category,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                    filled: true,
                    fillColor: const Color(0x1AFFFFFF),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0x33FFFFFF))),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: const Color(0x66FFFFFF))),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B5CF6)))),
                const SizedBox(width: 8),
                FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
                    child: const Text('Save')),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}