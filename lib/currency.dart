import 'package:flutter/material.dart';

class CurrencyProvider with ChangeNotifier {
  String _currency = 'IDR';
  double _rate = 1.0;

  String get currency => _currency;
  double get rate => _rate;

  void setCurrency(String newCurrency) {
    _currency = newCurrency;
    // Atur rate sesuai dengan mata uang yang dipilih
    switch (newCurrency) {
      case 'USD':
        _rate = 0.000062; // Misalnya, 1 IDR = 0.065 USD
        break;
      case 'EUR':
        _rate = 0.000060; // Misalnya, 1 IDR = 0.060 EUR
        break;
      case 'JPY':
        _rate = 0.0098; // Misalnya, 1 IDR = 7.2 JPY
        break;
      case 'IDR':
        _rate = 1.0; // Default IDR
        break;
    }
    notifyListeners();
  }
}
