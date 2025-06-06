class Medicine {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final String indication;
  final String composition;
  final String dosage;
  final String usage;
  final String sideEffects;
  final String productGroup;
  final String price;
  final String storeAddress;

  Medicine({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.indication,
    required this.composition,
    required this.dosage,
    required this.usage,
    required this.sideEffects,
    required this.productGroup,
    required this.price,
    required this.storeAddress,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? '', 
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      indication: json['indication'] ?? '',
      composition: json['composition'] ?? '',
      dosage: json['dosage'] ?? '',
      usage: json['usage'] ?? '',
      sideEffects: json['sideEffects'] ?? '',
      productGroup: json['productGroup'] ?? '',
      price: json['price'] ?? '',
      storeAddress: json['storeAddress'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'indication': indication,
      'composition': composition,
      'dosage': dosage,
      'usage': usage,
      'sideEffects': sideEffects,
      'productGroup': productGroup,
      'price': price,
      'storeAddress': storeAddress,
    };
  }
}
