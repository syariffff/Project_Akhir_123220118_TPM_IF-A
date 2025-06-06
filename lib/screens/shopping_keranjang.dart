import 'package:finalproject/widgets/scaffold/custom_scaffold2.dart';
import 'package:flutter/material.dart';
import 'package:finalproject/widgets/keranjang/body.dart';

class ShoppingKeranjangScreen extends StatelessWidget {
  const ShoppingKeranjangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold2(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // centerTitle: true,
        title: const Text(
          'Keranjang Saya',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 20,
          ), // samakan dengan padding list
          child: IconButton(
            padding: EdgeInsets.zero, // hilangkan padding default IconButton
            constraints:
                const BoxConstraints(), // hilangkan constraints default
            icon: Image.asset('assets/logo/back.png', width: 35, height: 35),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      child: SafeArea(child: Body()),
    );
  }
}
