import 'package:flutter/material.dart';

class Order {
  final String orderId;
  final String date;
  final String status;
  final List<String> items;
  final List<String> steps;

  Order({
    required this.orderId,
    required this.date,
    required this.status,
    required this.items,
    required this.steps,
  });
}

class OrderHistoryProvider with ChangeNotifier {
  final List<Order> _orders = [
    Order(
      orderId: "ORD123456",
      date: "2025-07-10",
      status: "Delivered",
      items: ["Diapers", "Baby Food"],
      steps: ["Ordered", "Shipped", "Out for Delivery", "Delivered"],
    ),
    Order(
      orderId: "ORD123457",
      date: "2025-07-14",
      status: "Shipped",
      items: ["Clothing", "Lotion"],
      steps: ["Ordered", "Shipped"],
    ),
  ];

  List<Order> get orders => _orders;

  void addOrder(List<String> itemTitles) {
    final now = DateTime.now();
    final order = Order(
      orderId: "ORD${DateTime.now().millisecondsSinceEpoch}",
      date: "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
      status: "Ordered",
      items: itemTitles,
      steps: ["Ordered"],
    );
    _orders.add(order);
    notifyListeners();
  }
}
