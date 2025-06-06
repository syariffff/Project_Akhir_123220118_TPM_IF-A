import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finalproject/widgets/keranjang/keranjang_empty.dart';
import 'package:finalproject/widgets/keranjang/keranjang_list.dart';
import 'package:finalproject/widgets/keranjang/keranjang_list_price.dart';
import 'package:finalproject/services/cart_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class KeranjangBody extends StatefulWidget {
  const KeranjangBody({super.key});

  @override
  State<KeranjangBody> createState() => _KeranjangBodyState();
}

class _KeranjangBodyState extends State<KeranjangBody> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  
  // Shake detection variables - menggunakan logika sama seperti DiskonScreen
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  String _discountMessage = "Tidak ada diskon";
  double _lastAcceleration = 0.0;
  int _shakeThreshold = 15;
  DateTime _lastShakeTime = DateTime.now();
  Duration _shakeInterval = Duration(seconds: 1);
  
  bool _discountApplied = false;
  double _discountPercentage = 0.0;
  static const double _discountAmount = 5.0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
    _startAccelerometerListener();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _startAccelerometerListener() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      double totalAcceleration = event.x + event.y + event.z;

      // Menggunakan logika yang sama seperti DiskonScreen
      if ((totalAcceleration - _lastAcceleration).abs() > _shakeThreshold) {
        if (DateTime.now().difference(_lastShakeTime) > _shakeInterval && !_discountApplied) {
          _handleShakeDetected();
        }
      }
      _lastAcceleration = totalAcceleration;
    });
  }

  void _handleShakeDetected() {
    // Haptic feedback saat shake terdeteksi
    HapticFeedback.mediumImpact();
    
    setState(() {
      _discountApplied = true;
      _discountPercentage = _discountAmount;
      _discountMessage = "Selamat! Anda mendapatkan diskon ${_discountAmount.toStringAsFixed(0)}%";
    });
    
    _lastShakeTime = DateTime.now();
    _showDiscountDialog();
  }

  void _showDiscountDialog() {
    // Haptic feedback success yang lebih kuat
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.celebration,
                    size: 40,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selamat! 🎉',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _discountMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadCartItems() async {
    try {
      final items = await CartService.instance.getCartItems();
      setState(() {
        cartItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _refreshCart() {
    _loadCartItems();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (cartItems.isEmpty) {
      return const KeranjangEmpty();
    }

    return Column(
      children: [
        // Discount banner jika ada diskon
        if (_discountApplied)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🎊 Diskon Shake ${_discountPercentage.toStringAsFixed(0)}% Aktif!',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Shake instruction banner (hanya muncul jika belum ada diskon)
        if (!_discountApplied)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.vibration, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '📱 Goyangkan HP untuk diskon 5%!',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: KeranjangList(
            cartItems: cartItems,
            onCartChanged: _refreshCart,
          ),
        ),
        KeranjangListPrice(
          cartItems: cartItems,
          onCartChanged: _refreshCart,
          discountPercentage: _discountPercentage,
        ),
      ],
    );
  }
}