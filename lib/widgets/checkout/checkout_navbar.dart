import 'package:flutter/material.dart';
import 'package:finalproject/theme/theme.dart';

class CheckoutNavBar extends StatelessWidget {
  final VoidCallback onCheckout;
  final double totalAmount;

  const CheckoutNavBar({
    super.key,
    required this.onCheckout,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate subtotal (total without tax)
    final double subTotal = totalAmount / 1.10; // Reverse calculate from total
    final double tax = subTotal * 0.10;

    TextStyle labelStyle = const TextStyle(color: Colors.grey, fontSize: 14);
    TextStyle priceStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Colors.grey,
    );
    TextStyle totalStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: lightColorScheme.primary,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pajak & Subtotal (abu-abu)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pajak (10%)', style: labelStyle),
              Text('Rp ${tax.toStringAsFixed(0)}', style: priceStyle),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: labelStyle),
              Text('Rp ${subTotal.toStringAsFixed(0)}', style: priceStyle),
            ],
          ),

          const SizedBox(height: 12),

          // Bar bawah: total (hijau) + tombol di kanan
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Total: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black, // warna item default
                ),
              ),
              Text('Rp ${totalAmount.toStringAsFixed(0)}', style: totalStyle),
              const SizedBox(width: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightColorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Buat Pesanan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
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
}