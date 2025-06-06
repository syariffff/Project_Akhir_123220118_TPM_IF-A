import 'package:finalproject/screens/checkout_screen.dart';
import 'package:finalproject/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:finalproject/models/medicine_model.dart';

class KeranjangListPrice extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onCartChanged;
  final double discountPercentage; // Parameter baru untuk diskon

  const KeranjangListPrice({
    super.key, 
    required this.cartItems,
    required this.onCartChanged,
    this.discountPercentage = 0.0, // Default 0% diskon
  });

  @override
  State<KeranjangListPrice> createState() => _KeranjangListPriceState();
}

class _KeranjangListPriceState extends State<KeranjangListPrice> {
  Set<String> selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    // Default semua item terseleksi
    _initializeSelectedItems();
  }

  @override
  void didUpdateWidget(KeranjangListPrice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartItems != widget.cartItems) {
      _initializeSelectedItems();
    }
  }

  void _initializeSelectedItems() {
    selectedItemIds = widget.cartItems
        .map((item) => (item['medicine'] as Medicine).id)
        .toSet();
  }

  // Method untuk update selected items dari KeranjangList
  void updateSelectedItems(Set<String> newSelectedIds) {
    setState(() {
      selectedItemIds = newSelectedIds;
    });
  }

  double _calculateSubtotal() {
    double subTotal = 0;
    
    for (var cartItem in widget.cartItems) {
      final medicine = cartItem['medicine'] as Medicine;
      final quantity = cartItem['quantity'] as int;
      
      // Hanya hitung item yang terseleksi
      if (selectedItemIds.contains(medicine.id)) {
        try {
          final priceStr = medicine.price.replaceAll(RegExp(r'[^\d.]'), '');
          final price = double.tryParse(priceStr) ?? 0;
          subTotal += price * quantity;
        } catch (_) {
          // Skip jika parsing gagal
        }
      }
    }
    
    return subTotal;
  }

  List<Map<String, dynamic>> get selectedCartItems {
    return widget.cartItems
        .where((item) => selectedItemIds.contains((item['medicine'] as Medicine).id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final double subTotal = _calculateSubtotal();
    final double pajak = subTotal * 0.10; // pajak 10% dari subtotal
    final double totalBeforeDiscount = subTotal + pajak;
    
    // Perhitungan diskon
    final double discountAmount = totalBeforeDiscount * (widget.discountPercentage / 100);
    final double finalTotal = totalBeforeDiscount - discountAmount;

    TextStyle labelStyle = const TextStyle(color: Colors.grey, fontSize: 14);
    TextStyle priceStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          // Checkbox untuk select/deselect all
          Row(
            children: [
              Checkbox(
                value: selectedItemIds.length == widget.cartItems.length && widget.cartItems.isNotEmpty,
                tristate: true,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      // Select all
                      selectedItemIds = widget.cartItems
                          .map((item) => (item['medicine'] as Medicine).id)
                          .toSet();
                    } else {
                      // Deselect all
                      selectedItemIds.clear();
                    }
                  });
                },
                activeColor: lightColorScheme.primary,
              ),
              Text(
                'Pilih Semua (${selectedItemIds.length}/${widget.cartItems.length})',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 8, thickness: 0.5),
          
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: labelStyle),
              Text('Rp ${subTotal.toStringAsFixed(0)}', style: priceStyle),
            ],
          ),
          const SizedBox(height: 6),
          
          // Pajak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pajak (10%)', style: labelStyle),
              Text('Rp ${pajak.toStringAsFixed(0)}', style: priceStyle),
            ],
          ),
          const SizedBox(height: 6),
          
          // Total sebelum diskon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Sebelum Diskon', style: labelStyle),
              Text('Rp ${totalBeforeDiscount.toStringAsFixed(0)}', style: priceStyle),
            ],
          ),
          
          // Tampilkan diskon jika ada
          if (widget.discountPercentage > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_offer, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Diskon Shake (${widget.discountPercentage.toStringAsFixed(0)}%)',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '- Rp ${discountAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Divider(height: 8, thickness: 1, color: Colors.green.shade200),
          ],
          
          const SizedBox(height: 6),
          
          // Total akhir
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18,
                  color: widget.discountPercentage > 0 ? Colors.green : Colors.black,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Tampilkan harga coret jika ada diskon
                  if (widget.discountPercentage > 0)
                    Text(
                      'Rp ${totalBeforeDiscount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    'Rp ${finalTotal.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: widget.discountPercentage > 0 ? Colors.green : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Tampilkan badge hemat jika ada diskon
          if (widget.discountPercentage > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                '🎉 Anda hemat Rp ${discountAmount.toStringAsFixed(0)}!',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedItemIds.isEmpty 
                  ? null 
                  : () {
                      // Pass selected items dan total akhir ke CheckoutScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            selectedItems: selectedCartItems,
                            totalAmount: finalTotal, // Gunakan total setelah diskon
                            discountPercentage: widget.discountPercentage, // Pass diskon info
                            discountAmount: discountAmount,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedItemIds.isEmpty 
                    ? Colors.grey.shade400 
                    : (widget.discountPercentage > 0 ? Colors.green : lightColorScheme.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Text(
                selectedItemIds.isEmpty 
                    ? 'PILIH ITEM UNTUK CHECKOUT' 
                    : widget.discountPercentage > 0 
                        ? 'CHECKOUT DENGAN DISKON (${selectedItemIds.length} item)'
                        : 'CHECKOUT (${selectedItemIds.length} item)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}