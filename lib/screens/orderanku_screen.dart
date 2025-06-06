import 'package:finalproject/widgets/orderanku/orderanku_list.dart';
import 'package:finalproject/widgets/scaffold/custom_scaffold2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OrderankuScreen extends StatefulWidget {
  const OrderankuScreen({super.key});

  @override
  State<OrderankuScreen> createState() => _OrderankuScreenState();
}

class _OrderankuScreenState extends State<OrderankuScreen> {
  late Future<Map<String, List<dynamic>>> _orderDataFuture;

  @override
  void initState() {
    super.initState();
    _orderDataFuture = _loadOrderData();
  }

  // Load semua data order dari SharedPreferences
  Future<Map<String, List<dynamic>>> _loadOrderData() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // Ambil order history dari shared preferences
      List<String> orderHistoryStrings = prefs.getStringList('order_history') ?? [];
      
      if (orderHistoryStrings.isEmpty) {
        return {
          'orderItems': [],
          'pickUpTimes': [],
          'totalPrices': [],
        };
      }

      List<Map<String, dynamic>> orderItems = [];
      List<String> pickUpTimes = [];
      List<double> totalPrices = [];

      // Parse setiap order
      for (String orderString in orderHistoryStrings) {
        try {
          Map<String, dynamic> order = json.decode(orderString);
          
          // Extract order items (medicines)
          List<dynamic> items = order['items'] ?? [];
          orderItems.add({
            'orderId': order['orderId'],
            'orderDate': order['orderDate'],
            'status': order['status'] ?? 'pending',
            'items': items,
            'pickupOption': order['pickupOption'],
          });

          // Extract pickup times
          String pickupTime = '';
          if (order['pickupOption'] == 'Terjadwal') {
            String? scheduledDate = order['scheduledDate'];
            String? scheduledTime = order['scheduledTime'];
            
            if (scheduledDate != null && scheduledTime != null) {
              DateTime date = DateTime.parse(scheduledDate);
              String formattedDate = '${date.day}/${date.month}/${date.year}';
              pickupTime = 'Terjadwal: $formattedDate $scheduledTime';
            } else {
              pickupTime = 'Terjadwal';
            }
          } else {
            pickupTime = 'Ambil Sekarang';
          }
          pickUpTimes.add(pickupTime);

          // Extract total prices
          double totalPrice = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
          totalPrices.add(totalPrice);

        } catch (e) {
          print('Error parsing order: $e');
          continue;
        }
      }

      return {
        'orderItems': orderItems,
        'pickUpTimes': pickUpTimes,
        'totalPrices': totalPrices,
      };

    } catch (e) {
      print('Error loading order data: $e');
      return {
        'orderItems': [],
        'pickUpTimes': [],
        'totalPrices': [],
      };
    }
  }

  // Method untuk refresh data
  void _refreshData() {
    setState(() {
      _orderDataFuture = _loadOrderData();
    });
  }

  // Method untuk hapus order (opsional)
  Future<void> _deleteOrder(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> orderHistory = prefs.getStringList('order_history') ?? [];
    
    // Filter out order yang akan dihapus
    List<String> updatedOrderHistory = orderHistory.where((orderString) {
      try {
        Map<String, dynamic> order = json.decode(orderString);
        return order['orderId'] != orderId;
      } catch (e) {
        return true; // Keep if can't parse
      }
    }).toList();

    await prefs.setStringList('order_history', updatedOrderHistory);
    
    // Refresh data setelah delete
    _refreshData();
    
    // Show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Method untuk update status order (opsional)
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> orderHistory = prefs.getStringList('order_history') ?? [];
    
    List<String> updatedOrderHistory = [];
    
    for (String orderString in orderHistory) {
      try {
        Map<String, dynamic> order = json.decode(orderString);
        
        if (order['orderId'] == orderId) {
          order['status'] = newStatus;
          order['updatedAt'] = DateTime.now().toIso8601String();
        }
        
        updatedOrderHistory.add(json.encode(order));
      } catch (e) {
        updatedOrderHistory.add(orderString); // Keep original if can't parse
      }
    }

    await prefs.setStringList('order_history', updatedOrderHistory);
    
    // Refresh data setelah update
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold2(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Orderanku",
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Image.asset('assets/logo/back.png', width: 35, height: 35),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          // Tombol refresh (opsional)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      child: FutureBuilder<Map<String, List<dynamic>>>(
        future: _orderDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final orderData = snapshot.data!;
          final orderItems = orderData['orderItems'] ?? [];
          final pickUpTimes = List<String>.from(orderData['pickUpTimes'] ?? []);
          final totalPrices = List<double>.from(orderData['totalPrices'] ?? []);


          if (orderItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada order',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Order pertama Anda akan muncul di sini',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke medicine store
                    },
                    child: const Text('Mulai Belanja'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
            },
            child: OrderankuList(
              orderItems: orderItems,
              pickUpTimes: pickUpTimes,
              totalPrices: totalPrices,
              onDeleteOrder: _deleteOrder, // Pass callback untuk delete
              onUpdateStatus: _updateOrderStatus, // Pass callback untuk update status
            ),
          );
        },
      ),
    );
  }
}