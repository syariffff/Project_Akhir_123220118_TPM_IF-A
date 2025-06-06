import 'package:flutter/material.dart';
import 'package:finalproject/widgets/profile/profile_body.dart';
import 'package:finalproject/widgets/scaffold/custom_scaffold2.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold2(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      child: const ProfileBody(),
    );
  }
}