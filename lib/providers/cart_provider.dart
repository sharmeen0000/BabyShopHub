import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String title;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  CartProvider() {
    loadCartFromPrefs(); // constructor
  }

  void addToCart(CartItem item) {
    final index = _items.indexWhere((e) => e.title == item.title);
    if (index >= 0) {
      _items[index].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    saveCartToPrefs();
    notifyListeners();
  }

  void removeFromCart(int index) {
    _items.removeAt(index);
    saveCartToPrefs();
    notifyListeners();
  }

  void increment(int index) {
    _items[index].quantity++;
    saveCartToPrefs();
    notifyListeners();
  }

  void decrement(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
      saveCartToPrefs();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    saveCartToPrefs();
    notifyListeners();
  }

  void saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartData = _items.map((item) {
      return jsonEncode({
        'title': item.title,
        'price': item.price,
        'image': item.image,
        'quantity': item.quantity,
      });
    }).toList();
    prefs.setStringList('cart', cartData);
  }

  void loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cartData = prefs.getStringList('cart');
    if (cartData != null) {
      _items = cartData.map((item) {
        final Map<String, dynamic> data = jsonDecode(item);
        return CartItem(
          title: data['title'],
          price: (data['price'] as num).toDouble(),
          image: data['image'],
          quantity: data['quantity'],
        );
      }).toList();
      notifyListeners();
    }
  }
}
