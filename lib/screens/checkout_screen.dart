import 'package:finalproject/widgets/checkout/body.dart';
import 'package:finalproject/widgets/scaffold/custom_scaffold2.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedItems;
  final double totalAmount;
  final double discountPercentage; // Parameter baru
  final double discountAmount; // Parameter baru

  const CheckoutScreen({
    super.key,
    required this.selectedItems,
    required this.totalAmount,
    this.discountPercentage = 0.0, // Default 0%
    this.discountAmount = 0.0, // Default 0
  });

  @override
  Widget build(BuildContext context) {
    void onCheckoutPressed() {
      // Pesan yang berbeda jika ada diskon
      String message = discountPercentage > 0 
          ? 'Pesanan berhasil dibuat dengan diskon ${discountPercentage.toStringAsFixed(0)}%!'
          : 'Pesanan berhasil dibuat!';
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: discountPercentage > 0 ? Colors.green : null,
        ),
      );
      Navigator.pop(context);
    }

    return CustomScaffold2(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const Text(
              'Konfirmasi Pesanan',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
            ),
            // Tampilkan badge diskon di title jika ada
            if (discountPercentage > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${discountPercentage.toStringAsFixed(0)}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
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
      ),
      child: CheckoutBody(
        selectedItems: selectedItems,
        totalAmount: totalAmount,
        discountPercentage: discountPercentage, // Pass ke CheckoutBody
        discountAmount: discountAmount, // Pass ke CheckoutBody
      ),
    );
  }
}