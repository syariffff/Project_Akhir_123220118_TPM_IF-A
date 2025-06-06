import 'package:finalproject/models/medicine_model.dart';
import 'package:finalproject/widgets/medicine/medicine_category_card.dart';
import 'package:flutter/material.dart';
import 'package:finalproject/theme/theme.dart';
import 'package:finalproject/widgets/medicine/medicine_category_button.dart';
import 'package:finalproject/widgets/scaffold/custom_scaffold2.dart';
import '../services/medicine_service.dart';
import '../screens/medicine_detail_screen.dart';
import '../screens/shopping_keranjang.dart';
import 'package:provider/provider.dart';
import 'package:finalproject/currency.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class MedicineStoreScreen extends StatefulWidget {
  const MedicineStoreScreen({super.key});

  @override
  State<MedicineStoreScreen> createState() => _MedicineStoreScreenState();
}

class _MedicineStoreScreenState extends State<MedicineStoreScreen> {
  final MedicineService _medicineService = MedicineService();

  late Future<List<Medicine>> _futureMedicines;

  int selectedCategoryIndex = 0;
  final TextEditingController searchController = TextEditingController();

  // List kategori yang diambil dari productGroup + 'All' default
  List<String> categories = ['All'];

  // Location variables
  Position? _currentPosition;
  String _currentAddress = 'Mendeteksi lokasi...';
  bool _isLocationLoading = false;
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _futureMedicines = _medicineService.fetchMedicines();
    _checkLocationPermission();
  }

  // Cek dan request location permission
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = 'Izin lokasi ditolak';
        _locationPermissionGranted = false;
      });
      _showLocationPermissionDialog();
      return;
    }

    if (permission == LocationPermission.whileInUse || 
        permission == LocationPermission.always) {
      setState(() {
        _locationPermissionGranted = true;
      });
      _getCurrentLocation();
    } else {
      setState(() {
        _currentAddress = 'Izin lokasi diperlukan';
        _locationPermissionGranted = false;
      });
    }
  }

  // Dialog untuk meminta izin lokasi
  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Lokasi Diperlukan'),
          content: const Text(
            'Aplikasi membutuhkan akses lokasi untuk menampilkan toko terdekat. '
            'Silakan aktifkan izin lokasi di pengaturan aplikasi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Pengaturan'),
            ),
          ],
        );
      },
    );
  }

  // Dapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Layanan lokasi tidak aktif';
          _isLocationLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
      });

      await _getAddressFromLatLng(position);
    } catch (e) {
      setState(() {
        _currentAddress = 'Gagal mendapatkan lokasi';
        _isLocationLoading = false;
      });
      
      // Show error dialog
      _showLocationErrorDialog(e.toString());
    }
  }

  // Konversi koordinat ke alamat
  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = 
            '${place.street ?? ''}, ${place.subLocality ?? ''}, '
            '${place.locality ?? ''}, ${place.administrativeArea ?? ''}';
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Lat: ${position.latitude.toStringAsFixed(4)}, '
                         'Lng: ${position.longitude.toStringAsFixed(4)}';
        _isLocationLoading = false;
      });
    }
  }

  // Dialog error lokasi
  void _showLocationErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error Lokasi'),
          content: Text('Gagal mendapatkan lokasi: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _getCurrentLocation();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        );
      },
    );
  }

  // Hitung jarak antara dua koordinat (dalam kilometer)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  // Filter obat berdasarkan kategori, search query, dan jarak
  List<Medicine> filterMedicines(List<Medicine> medicines, String category, String query) {
    query = query.toLowerCase();
    List<Medicine> filtered = medicines.where((medicine) {
      final matchesCategory = category == 'All' ? true : medicine.productGroup == category;
      final matchesQuery = medicine.name.toLowerCase().contains(query) ||
          medicine.productGroup.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    // Sort berdasarkan jarak jika lokasi tersedia
    if (_currentPosition != null) {
      filtered.sort((a, b) {
        // Asumsi medicine memiliki latitude dan longitude
        // Jika tidak ada, gunakan jarak default atau parsing dari address
        double distanceA = _getDistanceToStore(a);
        double distanceB = _getDistanceToStore(b);
        return distanceA.compareTo(distanceB);
      });
    }

    return filtered;
  }

  // Dapatkan jarak ke toko (dummy implementation - sesuaikan dengan data Anda)
  double _getDistanceToStore(Medicine medicine) {
    if (_currentPosition == null) return 0.0;
    
    // Contoh koordinat dummy - sesuaikan dengan data medicine Anda
    // Anda mungkin perlu menambahkan latitude dan longitude ke model Medicine
    double storeLat = -7.7956 + (medicine.hashCode % 100) * 0.001; // Dummy lat
    double storeLng = 110.3695 + (medicine.hashCode % 100) * 0.001; // Dummy lng
    
    return _calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      storeLat,
      storeLng,
    );
  }

  // Ambil kategori unik dari list medicine
  List<String> getCategoriesFromMedicines(List<Medicine> medicines) {
    final Set<String> uniqueCategories = {};
    for (var medicine in medicines) {
      if (medicine.productGroup.isNotEmpty) {
        uniqueCategories.add(medicine.productGroup);
      }
    }
    return ['All', ...uniqueCategories.toList()];
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold2(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Toko Elektronik',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        actionsPadding: const EdgeInsets.only(right: 15),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ShoppingKeranjangScreen(),
                ),
              );
            },
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Location indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lokasi Anda:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        _isLocationLoading
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Mendeteksi lokasi...',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              )
                            : Text(
                                _currentAddress,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.blue, size: 20),
                    onPressed: _locationPermissionGranted ? _getCurrentLocation : _checkLocationPermission,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dropdown untuk memilih mata uang
            Row(
              children: [
                const Text('Mata Uang:'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: context.watch<CurrencyProvider>().currency,
                  onChanged: (String? newValue) {
                    setState(() {
                      context.read<CurrencyProvider>().setCurrency(newValue!);
                    });
                  },
                  items: <String>['IDR', 'USD', 'EUR', 'JPY']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search bar + filter button
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey, width: 0.5),
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.black54,
                        ),
                        hintText: 'Cari produk',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.black54,
                                ),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      style: const TextStyle(color: Colors.black),
                      cursorColor: Colors.black,
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: lightColorScheme.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      // TODO: implement filter action jika perlu
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // FutureBuilder untuk data medicine
            FutureBuilder<List<Medicine>>(
              future: _futureMedicines,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Expanded(
                      child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Expanded(
                      child: Center(child: Text('Error: ${snapshot.error}')));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Expanded(
                      child: Center(
                          child: Text(
                    'Tidak ada produk ditemukan',
                    style: TextStyle(color: Colors.white),
                  )));
                }

                final medicines = snapshot.data!;

                // Update categories list secara dinamis dari data medicine
                categories = getCategoriesFromMedicines(medicines);

                final category = categories[selectedCategoryIndex];

                // Tombol kategori horizontal scroll
                final categorySelector = SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(categories.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CategoryButton(
                          title: categories[index],
                          isSelected: selectedCategoryIndex == index,
                          onTap: () {
                            setState(() {
                              selectedCategoryIndex = index;
                              searchController.clear();
                            });
                          },
                        ),
                      );
                    }),
                  ),
                );

                // Filter produk berdasarkan kategori dan pencarian
                final filteredProducts = filterMedicines(
                  medicines,
                  category,
                  searchController.text,
                );

                return Expanded(
                  child: Column(
                    children: [
                      categorySelector,
                      const SizedBox(height: 25),
                      
                      // Show distance info if location is available
                      if (_currentPosition != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.near_me, color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              const Text(
                                'Produk diurutkan berdasarkan jarak terdekat',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      filteredProducts.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada produk ditemukan',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final medicine = filteredProducts[index];

                                  // Ambil currency dari provider
                                  final currencyProvider = Provider.of<CurrencyProvider>(context, listen: false);
                                  final currencySymbol = currencyProvider.currency == 'USD'
                                      ? '\$'
                                      : currencyProvider.currency == 'EUR'
                                          ? '€'
                                          : currencyProvider.currency == 'JPY'
                                              ? '¥'
                                              : 'Rp'; // default IDR
                                  final bool isOriginalCurrency = currencyProvider.currency == 'IDR';
                                  final double priceValue = double.tryParse(medicine.price) ?? 0.0;
                                  final double displayPrice = isOriginalCurrency ? priceValue : priceValue * currencyProvider.rate;
                                  final String priceText = '${isOriginalCurrency ? 'Rp' : currencyProvider.currency} ${displayPrice.toStringAsFixed(2)}';

                                  // Calculate distance for display
                                  final double distance = _getDistanceToStore(medicine);
                                  final String distanceText = distance < 1 
                                      ? '${(distance * 1000).round()}m'
                                      : '${distance.toStringAsFixed(1)}km';

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MedicineDetailScreen(
                                          item: medicine,
                                          priceText: priceText,  // Pass priceText here
                                        ),
                                      ),
                                    );
                                    },
                                    child: Stack(
                                      children: [
                                        ProductCard(
                                          imageUrl: medicine.imageUrl,
                                          name: medicine.name,
                                          category: medicine.productGroup,
                                          price: priceText,
                                          storeAddress: medicine.storeAddress,
                                          isLiked: false,
                                          onTapAdd: () {},
                                          onTapLike: () {}, 
                                          pricePrefix: '',
                                        ),
                                        // Distance badge
                                        if (_currentPosition != null)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                distanceText,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}