import 'package:flutter/material.dart';
import 'package:finalproject/models/medicine_model.dart';
import 'package:finalproject/theme/theme.dart';
import 'package:finalproject/services/cart_service.dart';

class KeranjangList extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onCartChanged;

  const KeranjangList({
    super.key, 
    required this.cartItems,
    required this.onCartChanged,
  });

  @override
  State<KeranjangList> createState() => _KeranjangListState();
}

class _KeranjangListState extends State<KeranjangList> {
  Set<String> selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    // Default semua item terseleksi
    selectedItemIds = widget.cartItems
        .map((item) => (item['medicine'] as Medicine).id)
        .toSet();
  }

  @override
  void didUpdateWidget(KeranjangList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected items jika cart berubah
    if (oldWidget.cartItems != widget.cartItems) {
      selectedItemIds = selectedItemIds.intersection(
        widget.cartItems.map((item) => (item['medicine'] as Medicine).id).toSet(),
      );
    }
  }

  Future<void> _updateQuantity(Medicine medicine, int newQuantity) async {
    try {
      await CartService.instance.updateItemQuantity(medicine.id, newQuantity);
      widget.onCartChanged();
    } catch (e) {
      _showErrorMessage('Gagal mengupdate quantity');
    }
  }

  Future<void> _removeItem(Medicine medicine) async {
    try {
      await CartService.instance.removeItemFromCart(medicine.id);
      selectedItemIds.remove(medicine.id);
      widget.onCartChanged();
    } catch (e) {
      _showErrorMessage('Gagal menghapus item');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group items by storeAddress
    final Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in widget.cartItems) {
      final medicine = item['medicine'] as Medicine;
      groupedItems.putIfAbsent(medicine.storeAddress, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: groupedItems.entries.map((entry) {
        final storeAddress = entry.key;
        final items = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon store and store address
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.store,
                      size: 20,
                      color: lightColorScheme.primary,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        storeAddress,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 0.5),

              ...items.map((cartItem) {
                final medicine = cartItem['medicine'] as Medicine;
                final quantity = cartItem['quantity'] as int;
                final isSelected = selectedItemIds.contains(medicine.id);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Checkbox di kiri gambar
                      Checkbox(
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedItemIds.add(medicine.id);
                            } else {
                              selectedItemIds.remove(medicine.id);
                            }
                          });
                        },
                        activeColor: lightColorScheme.primary,
                      ),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          medicine.imageUrl,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 80,
                            width: 80,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kategori: ${medicine.productGroup}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  medicine.price,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: lightColorScheme.primary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (quantity > 1) {
                                          _updateQuantity(medicine, quantity - 1);
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                                              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                                              title: Row(
                                                children: [
                                                  Icon(
                                                    Icons.info_outline,
                                                    color: lightColorScheme.primary,
                                                    size: 28,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Expanded(
                                                    child: Text(
                                                      'Konfirmasi Penghapusan',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content: Text(
                                                'Apakah Anda yakin ingin menghapus "${medicine.name}" dari keranjang?',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              actionsPadding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              actions: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.grey.shade600,
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text(
                                                    'Batal',
                                                    style: TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: lightColorScheme.primary,
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 24,
                                                      vertical: 12,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    _removeItem(medicine);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    'Ya, hapus',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: lightColorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '$quantity',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: lightColorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => _updateQuantity(medicine, quantity + 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: lightColorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Getter untuk mendapatkan selected items (bisa digunakan di parent)
  List<Map<String, dynamic>> get selectedItems {
    return widget.cartItems
        .where((item) => selectedItemIds.contains((item['medicine'] as Medicine).id))
        .toList();
  }
}