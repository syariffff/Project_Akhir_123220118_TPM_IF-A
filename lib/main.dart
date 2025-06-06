import 'package:finalproject/screens/sigin_screen.dart';
import 'package:finalproject/services/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:finalproject/screens/welcome_screen.dart';
import 'package:finalproject/currency.dart'; // Pastikan file ini ada dan benar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('usersBox');
  await Hive.openBox('sessionBox');
  await Hive.openBox('favoritesBox');
  // Initialize notification service
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toko Elektronik',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE), // warna seed default
        ),
      ),
      home: const SignInScreen(),
    );
  }
}
