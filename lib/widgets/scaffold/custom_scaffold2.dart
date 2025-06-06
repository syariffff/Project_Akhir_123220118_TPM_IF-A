import 'package:flutter/material.dart';

class CustomScaffold2 extends StatelessWidget {
  const CustomScaffold2({
    super.key,
    this.child,
    this.appBar,
    this.bottomNavigationBar,
  });

  final Widget? child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          appBar ??
          AppBar(
            leading: SizedBox(),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/bg1.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(child: child ?? const SizedBox()),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
