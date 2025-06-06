import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? child;

  const CustomScaffold({super.key, this.appBar, this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: true, // Jika kamu ingin background fullscreen
      extendBody: true,
      body: Stack(
        children: [
          // Contoh background image
          Image.asset(
            'assets/images/bg1.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(child: child ?? SizedBox()),
        ],
      ),
    );
  }
}
