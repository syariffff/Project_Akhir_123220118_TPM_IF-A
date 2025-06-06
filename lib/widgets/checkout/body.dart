import 'package:flutter/material.dart';
import 'package:finalproject/models/medicine_model.dart';
import 'package:finalproject/theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Import CartService untuk clear cart
// import 'package:finalproject/services/cart_service.dart';

class CheckoutBody extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final double totalAmount;
  final double discountAmount;

  const CheckoutBody({
    super.key,
    required this.selectedItems,
    required this.totalAmount, required double discountPercentage, required this.discountAmount,
  });

  @override
  State<CheckoutBody> createState() => _CheckoutBodyState();
}

class _CheckoutBodyState extends State<CheckoutBody> {
  String pickupOption = 'Sekarang';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int selectedDateIndex = 0;
  int selectedTimeIndex = 0;
  bool isProcessingCheckout = false;
  String selectedTimezone = 'WIB'; // Default timezone

  // Timezone options
  final List<Map<String, String>> timezones = [
    {'code': 'WIB', 'name': 'WIB (UTC+7)', 'offset': '+07:00'},
    {'code': 'WITA', 'name': 'WITA (UTC+8)', 'offset': '+08:00'},
    {'code': 'WIT', 'name': 'WIT (UTC+9)', 'offset': '+09:00'},
    {'code': 'LONDON', 'name': 'London (UTC+0/+1)', 'offset': '+00:00'},
  ];

  List<DateTime> get nextThreeDays {
    final now = DateTime.now();
    return List.generate(
      3,
      (i) => DateTime(now.year, now.month, now.day).add(Duration(days: i)),
    );
  }

  List<TimeOfDay> generateTimeSlots() {
    final slots = <TimeOfDay>[];
    for (int hour = 10; hour <= 20; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
    }
    return slots;
  }

  String formatDate(DateTime d) => DateFormat('EEE, dd MMM').format(d);

  // Konversi waktu berdasarkan timezone
  DateTime convertToTimezone(DateTime localTime, String fromTimezone, String toTimezone) {
    final Map<String, int> timezoneOffsets = {
      'WIB': 7,
      'WITA': 8,
      'WIT': 9,
      'LONDON': 0, // GMT, bisa +1 saat daylight saving
    };

    final fromOffset = timezoneOffsets[fromTimezone] ?? 7;
    final toOffset = timezoneOffsets[toTimezone] ?? 7;
    final difference = toOffset - fromOffset;

    return localTime.add(Duration(hours: difference));
  }

  // Format waktu dengan timezone
  String formatTimeWithTimezone(DateTime dateTime, TimeOfDay timeOfDay, String timezone) {
    final combinedDateTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    final convertedTime = convertToTimezone(combinedDateTime, 'WIB', timezone);
    final formattedDate = DateFormat('EEE, dd MMM').format(convertedTime);
    final formattedTime = TimeOfDay.fromDateTime(convertedTime).format(context);
    
    return '$formattedDate $formattedTime ($timezone)';
  }

  // Widget untuk menampilkan konversi waktu
  Widget buildTimezoneConverter() {
    if (pickupOption != 'Terjadwal' || selectedDate == null || selectedTime == null) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konversi Waktu Zona',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightColorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: lightColorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: timezones.map((tz) {
                  final isSelected = selectedTimezone == tz['code'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? lightColorScheme.primary.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: lightColorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formatTimeWithTimezone(selectedDate!, selectedTime!, tz['code']!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected 
                                  ? lightColorScheme.primary 
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih zona waktu referensi:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: timezones.map((tz) {
                final isSelected = selectedTimezone == tz['code'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTimezone = tz['code']!;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? lightColorScheme.primary
                          : lightColorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tz['name']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : lightColorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Simpan data checkout ke SharedPreferences
  Future<void> saveCheckoutData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Konversi waktu ke berbagai zona waktu untuk disimpan
    final timezoneConversions = <String, String>{};
    if (selectedDate != null && selectedTime != null) {
      for (final tz in timezones) {
        timezoneConversions[tz['code']!] = formatTimeWithTimezone(
          selectedDate!, 
          selectedTime!, 
          tz['code']!
        );
      }
    }
    
    // Buat data checkout
    final checkoutData = {
      'orderId': 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
      'orderDate': DateTime.now().toIso8601String(),
      'pickupOption': pickupOption,
      'scheduledDate': selectedDate?.toIso8601String(),
      'scheduledTime': selectedTime != null 
          ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'selectedTimezone': selectedTimezone,
      'timezoneConversions': timezoneConversions, // Simpan konversi semua zona waktu
      'totalAmount': widget.totalAmount - widget.discountAmount,
      'items': widget.selectedItems.map((item) => {
        'medicine': (item['medicine'] as Medicine).toJson(),
        'quantity': item['quantity'],
      }).toList(),
      'status': 'pending', // pending, completed, cancelled
    };

    // Ambil riwayat order yang sudah ada
    List<String> orderHistory = prefs.getStringList('order_history') ?? [];
    
    // Tambahkan order baru
    orderHistory.add(json.encode(checkoutData));
    
    // Simpan kembali ke SharedPreferences
    await prefs.setStringList('order_history', orderHistory);
    
    // Simpan juga data order terakhir untuk referensi cepat
    await prefs.setString('last_order', json.encode(checkoutData));
  }

  Future<void> clearCartAfterCheckout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_items');
  }

  // Proses checkout
  Future<void> processCheckout() async {
    if (isProcessingCheckout) return;
    
    setState(() {
      isProcessingCheckout = true;
    });

    try {
      // Validasi jika pickup terjadwal tapi belum pilih waktu
      if (pickupOption == 'Terjadwal' && (selectedDate == null || selectedTime == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih tanggal dan jam untuk pickup terjadwal'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Simpan data checkout
      await saveCheckoutData();
      
      // Clear cart
      await clearCartAfterCheckout();
      
      // Tampilkan dialog sukses dengan informasi timezone
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  const Text('Checkout Berhasil!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pesanan Anda telah berhasil diproses.'),
                  const SizedBox(height: 10),
                  Text('Total: Rp ${(widget.totalAmount - widget.discountAmount).toStringAsFixed(0)}'),
                  if (pickupOption == 'Terjadwal') ...[
                    const SizedBox(height: 10),
                    Text(
                      'Jadwal Pickup:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Text(formatTimeWithTimezone(selectedDate!, selectedTime!, selectedTimezone)),
                    const SizedBox(height: 8),
                    Text(
                      'Konversi Zona Waktu:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    ...timezones
                        .where((tz) => tz['code'] != selectedTimezone)
                        .map((tz) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                formatTimeWithTimezone(selectedDate!, selectedTime!, tz['code']!),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            )),
                  ] else ...[
                    const SizedBox(height: 5),
                    const Text('Pickup: Sekarang'),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Back to previous screen
                    Navigator.of(context).pop(); // Back to previous screen
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessingCheckout = false;
        });
      }
    }
  }

  Widget buildCustomButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? lightColorScheme.primary
              : lightColorScheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : lightColorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group produk berdasarkan alamat toko
    final Map<String, List<Map<String, dynamic>>> groupedByStore = {};
    for (var item in widget.selectedItems) {
      final medicine = item['medicine'] as Medicine;
      groupedByStore.putIfAbsent(medicine.storeAddress, () => []).add(item);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alamat Toko',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...groupedByStore.keys.map(
                      (storeAddress) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.store,
                              color: lightColorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                storeAddress,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Opsi Ambil Pesanan Sendiri',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: [
                        RadioListTile<String>(
                          activeColor: lightColorScheme.primary,
                          title: const Text('Ambil Sekarang'),
                          value: 'Sekarang',
                          groupValue: pickupOption,
                          onChanged: (value) {
                            setState(() {
                              pickupOption = value!;
                              selectedDate = null;
                              selectedTime = null;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          activeColor: lightColorScheme.primary,
                          title: const Text('Ambil Terjadwal'),
                          value: 'Terjadwal',
                          groupValue: pickupOption,
                          onChanged: (value) {
                            setState(() {
                              pickupOption = value!;
                              if (selectedDate == null) {
                                selectedDate = nextThreeDays[0];
                                selectedDateIndex = 0;
                              }
                              if (selectedTime == null) {
                                selectedTime = generateTimeSlots()[0];
                                selectedTimeIndex = 0;}
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Date and Time Selection (hanya tampil jika pickup terjadwal)
            if (pickupOption == 'Terjadwal') ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Tanggal',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: nextThreeDays.length,
                          itemBuilder: (context, index) {
                            final date = nextThreeDays[index];
                            final isSelected = selectedDateIndex == index;
                            return buildCustomButton(
                              formatDate(date),
                              isSelected,
                              () {
                                setState(() {
                                  selectedDate = date;
                                  selectedDateIndex = index;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Jam',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: generateTimeSlots().length,
                          itemBuilder: (context, index) {
                            final timeSlot = generateTimeSlots()[index];
                            final isSelected = selectedTimeIndex == index;
                            return buildCustomButton(
                              timeSlot.format(context),
                              isSelected,
                              () {
                                setState(() {
                                  selectedTime = timeSlot;
                                  selectedTimeIndex = index;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Timezone Converter Widget
              buildTimezoneConverter(),
            ],

            // Order Summary
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Pesanan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...widget.selectedItems.map((item) {
                      final medicine = item['medicine'] as Medicine;
                      final quantity = item['quantity'] as int;
                      final subtotal = medicine.price * quantity;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                medicine.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.medication),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medicine.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${quantity}x Rp ${medicine.price}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Rp ${subtotal}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pesanan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${(widget.totalAmount - widget.discountAmount).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: lightColorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isProcessingCheckout ? null : processCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightColorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isProcessingCheckout
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Memproses...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Checkout Sekarang',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}