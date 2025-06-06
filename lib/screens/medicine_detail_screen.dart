import 'package:finalproject/screens/shopping_keranjang.dart';
import 'package:flutter/material.dart';
import 'package:finalproject/widgets/scaffold/custom_scaffold2.dart';
import 'package:finalproject/models/medicine_model.dart';
import 'package:finalproject/widgets/medicine/medicine_detail_body.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Medicine item;
  final String priceText;

  const MedicineDetailScreen({super.key, required this.item, required this.priceText});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold2(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Item Detail',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
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
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShoppingKeranjangScreen(),
                ),
              );
            },
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      child: MedicineDetailBody(item: item, priceText: priceText,),
    );
  }
}
