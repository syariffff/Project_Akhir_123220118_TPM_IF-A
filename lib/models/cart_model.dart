class Medicine {
  final String id;
  final String name;
  final String price;
  final String imageUrl;
  final String storeAddress;
  final String productGroup;
  final String description;
  final String indication;
  final String composition;
  final String dosage;
  final String usage;

  Medicine({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.storeAddress,
    required this.productGroup,
    required this.description,
    required this.indication,
    required this.composition,
    required this.dosage,
    required this.usage,
  });

  // Convert Medicine object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'storeAddress': storeAddress,
      'productGroup': productGroup,
      'description': description,
      'indication': indication,
      'composition': composition,
      'dosage': dosage,
      'usage': usage,
    };
  }

  // Create Medicine object from JSON
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      storeAddress: json['storeAddress'] ?? '',
      productGroup: json['productGroup'] ?? '',
      description: json['description'] ?? '',
      indication: json['indication'] ?? '',
      composition: json['composition'] ?? '',
      dosage: json['dosage'] ?? '',
      usage: json['usage'] ?? '',
    );
  }

  // Optional: copyWith method for easier object manipulation
  Medicine copyWith({
    String? id,
    String? name,
    String? price,
    String? imageUrl,
    String? storeAddress,
    String? productGroup,
    String? description,
    String? indication,
    String? composition,
    String? dosage,
    String? usage,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      storeAddress: storeAddress ?? this.storeAddress,
      productGroup: productGroup ?? this.productGroup,
      description: description ?? this.description,
      indication: indication ?? this.indication,
      composition: composition ?? this.composition,
      dosage: dosage ?? this.dosage,
      usage: usage ?? this.usage,
    );
  }
}