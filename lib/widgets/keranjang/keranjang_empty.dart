import 'package:flutter/material.dart';

class KeranjangEmpty extends StatelessWidget {
  const KeranjangEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Keranjang kosong',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }
}
