import 'package:flutter/material.dart';
import 'package:finalproject/models/medicine_model.dart';
import 'package:finalproject/theme/theme.dart';
import 'package:finalproject/services/cart_service.dart'; // Import CartService

class MedicineDetailBody extends StatefulWidget {
  final Medicine item;
  final String priceText; // Add this variable

  const MedicineDetailBody({Key? key, required this.item, required this.priceText}) : super(key: key);

  @override
  State<MedicineDetailBody> createState() => _MedicineDetailBodyState();
}

class _MedicineDetailBodyState extends State<MedicineDetailBody> {
  int quantity = 1;
  bool isAddingToCart = false; // Loading state

  double get totalPrice {
    try {
      final priceStr = widget.item.price.replaceAll(RegExp(r'[^\d.]'), '');
      return quantity * double.parse(priceStr);
    } catch (e) {
      return 0;
    }
  }

  void showCustomMessage(String message, {bool isSuccess = true}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Future<void> addToCart() async {
    if (isAddingToCart) return; // Prevent multiple taps
    
    setState(() {
      isAddingToCart = true;
    });

    try {
      await CartService.instance.addItemToCart(widget.item);
      showCustomMessage(
        '${widget.item.name} berhasil ditambahkan ke keranjang',
        isSuccess: true,
      );
    } catch (e) {
      showCustomMessage(
        'Gagal menambahkan ke keranjang: ${e.toString()}',
        isSuccess: false,
      );
    } finally {
      setState(() {
        isAddingToCart = false;
      });
    }
  }

  Widget cardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Divider(color: Colors.grey, thickness: 0.5),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget detailText(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 27),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label\n",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: content,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('storeAddress: ${widget.item.storeAddress}');
    final item = widget.item;
    final priceText = widget.priceText;

    final horizontalPadding = 20.0; // padding kiri ListView
    final horizontalPaddingRight = 16.0; // padding kanan ListView
    final imageWidth =
        MediaQuery.of(context).size.width -
        horizontalPadding -
        horizontalPaddingRight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 5, 16, 140),
            children: [
              // Gambar dengan borderRadius bawah kiri & kanan melengkung
              Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
                  child: Container(
                    color: Colors.white,
                    child: Image.network(
                      item.imageUrl,
                      height: 280,
                      width: imageWidth,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 280,
                        width: imageWidth,
                        color: Colors.grey.shade300,
                        child: const Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            priceText,  // Use priceText here
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // favorite logic here
                          },
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Colors.black,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey, thickness: 0.5),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store,
                          size: 20,
                          color: lightColorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item.storeAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Card detail produk biasa dengan borderRadius 16 semua
              cardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Detail Produk"),
                    detailText("Kategori", item.productGroup),
                    detailText("Deskripsi", item.description),
                    detailText("Varian", item.indication),
                    detailText("Spesifikasi", item.composition),
                    detailText("Kondisi", item.dosage),
                    detailText("Review", item.usage),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(color: Colors.white),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: isAddingToCart ? null : addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAddingToCart 
                    ? Colors.grey.shade400 
                    : lightColorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                shadowColor: Colors.black54,
                elevation: isAddingToCart ? 0 : 10,
              ),
              child: isAddingToCart
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Menambahkan...",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      "Tambah ke Keranjang",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}