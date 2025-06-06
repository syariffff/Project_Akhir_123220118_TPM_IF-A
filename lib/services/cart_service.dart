import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:finalproject/models/medicine_model.dart';

class CartService {
  static const String _cartKey = 'cart_items';
  static CartService? _instance;
  
  CartService._internal();
  
  static CartService get instance {
    _instance ??= CartService._internal();
    return _instance!;
  }

  // Tambah item ke keranjang
  Future<void> addItemToCart(Medicine item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList(_cartKey) ?? [];
    
    // Cek apakah item sudah ada di keranjang
    bool itemExists = false;
    List<String> updatedCartItems = [];
    
    for (String cartItemString in cartItems) {
      Map<String, dynamic> cartItemMap = json.decode(cartItemString);
      
      // Jika item sudah ada, tambahkan quantity
      if (cartItemMap['medicine']['id'] == item.id) {
        cartItemMap['quantity'] = (cartItemMap['quantity'] ?? 1) + 1;
        itemExists = true;
      }
      
      updatedCartItems.add(json.encode(cartItemMap));
    }
    
    // Jika item belum ada, tambahkan sebagai item baru
    if (!itemExists) {
      Map<String, dynamic> newCartItem = {
        'medicine': item.toJson(),
        'quantity': 1,
        'addedAt': DateTime.now().toIso8601String(),
      };
      updatedCartItems.add(json.encode(newCartItem));
    }
    
    await prefs.setStringList(_cartKey, updatedCartItems);
  }

  // Ambil semua item dari keranjang
  Future<List<Map<String, dynamic>>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList(_cartKey) ?? [];
    
    return cartItems.map((item) {
      Map<String, dynamic> cartItemMap = json.decode(item);
      return {
        'medicine': Medicine.fromJson(cartItemMap['medicine']),
        'quantity': cartItemMap['quantity'] ?? 1,
        'addedAt': cartItemMap['addedAt'],
      };
    }).toList();
  }

  // Update quantity item di keranjang
  Future<void> updateItemQuantity(String itemId, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList(_cartKey) ?? [];
    
    List<String> updatedCartItems = [];
    
    for (String cartItemString in cartItems) {
      Map<String, dynamic> cartItemMap = json.decode(cartItemString);
      
      if (cartItemMap['medicine']['id'] == itemId) {
        if (quantity > 0) {
          cartItemMap['quantity'] = quantity;
          updatedCartItems.add(json.encode(cartItemMap));
        }
        // Jika quantity <= 0, tidak ditambahkan (artinya dihapus)
      } else {
        updatedCartItems.add(cartItemString);
      }
    }
    
    await prefs.setStringList(_cartKey, updatedCartItems);
  }

  // Hapus item dari keranjang
  Future<void> removeItemFromCart(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItems = prefs.getStringList(_cartKey) ?? [];
    
    List<String> updatedCartItems = cartItems.where((cartItemString) {
      Map<String, dynamic> cartItemMap = json.decode(cartItemString);
      return cartItemMap['medicine']['id'] != itemId;
    }).toList();
    
    await prefs.setStringList(_cartKey, updatedCartItems);
  }

  // Kosongkan keranjang
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  // Opsi 2: Dengan try-catch
  // Hitung total item di keranjang
    Future<int> getCartItemCount() async {
      final cartItems = await getCartItems();
      int total = cartItems.fold(0, (sum, item) {
        int quantity = item['quantity'] ?? 1;
        return sum + quantity;
      });
      return total;
    }

  // Hitung total harga keranjang
  Future<double> getCartTotalPrice() async {
    final cartItems = await getCartItems();
    double total = 0;
    
    for (var item in cartItems) {
      Medicine medicine = item['medicine'];
      int quantity = item['quantity'] ?? 1;
      
      try {
        final priceStr = medicine.price.replaceAll(RegExp(r'[^\d.]'), '');
        double price = double.parse(priceStr);
        total += price * quantity;
      } catch (e) {
        // Jika parsing gagal, skip item ini
        continue;
      }
    }
    
    return total;
  }
}