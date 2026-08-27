/// Product Model for Sawariya Dairy
class Product {
  final String id;
  final String title;
  final String categoryId;
  final String categoryName;
  final double price;
  final double? originalPrice;
  final String unit; // e.g. "500 ml", "1 L", "200 g", "1 kg"
  final String imageUrl;
  final String description;
  final double rating;
  final int reviewCount;
  final bool isFreshDeal;
  final bool isBestSeller;
  final bool isA2CowMilk;
  final bool inStock;

  const Product({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    this.originalPrice,
    required this.unit,
    required this.imageUrl,
    this.description = '',
    this.rating = 4.8,
    this.reviewCount = 120,
    this.isFreshDeal = false,
    this.isBestSeller = false,
    this.isA2CowMilk = false,
    this.inStock = true,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  Product copyWith({
    String? id,
    String? title,
    String? categoryId,
    String? categoryName,
    double? price,
    double? originalPrice,
    String? unit,
    String? imageUrl,
    String? description,
    double? rating,
    int? reviewCount,
    bool? isFreshDeal,
    bool? isBestSeller,
    bool? isA2CowMilk,
    bool? inStock,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFreshDeal: isFreshDeal ?? this.isFreshDeal,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isA2CowMilk: isA2CowMilk ?? this.isA2CowMilk,
      inStock: inStock ?? this.inStock,
    );
  }

  /// Creates a [Product] from a Firestore document map.
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    final original = data['originalPrice'];
    return Product(
      id: id,
      title: (data['title'] as String?) ?? '',
      categoryId: (data['categoryId'] as String?) ?? '',
      categoryName: (data['categoryName'] as String?) ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: original == null ? null : (original as num).toDouble(),
      unit: (data['unit'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      isFreshDeal: (data['isFreshDeal'] as bool?) ?? false,
      isBestSeller: (data['isBestSeller'] as bool?) ?? false,
      isA2CowMilk: (data['isA2CowMilk'] as bool?) ?? false,
      inStock: (data['inStock'] as bool?) ?? true,
    );
  }

  /// Serializes this [Product] for SharedPreferences / general-purpose use.
  /// Includes [id] (unlike [toFirestore] which omits it).
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'price': price,
        'originalPrice': originalPrice,
        'unit': unit,
        'imageUrl': imageUrl,
        'description': description,
        'rating': rating,
        'reviewCount': reviewCount,
        'isFreshDeal': isFreshDeal,
        'isBestSeller': isBestSeller,
        'isA2CowMilk': isA2CowMilk,
        'inStock': inStock,
      };

  /// Restores a [Product] from a map produced by [toMap].
  factory Product.fromMap(Map<String, dynamic> map) {
    final original = map['originalPrice'];
    return Product(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      categoryId: (map['categoryId'] as String?) ?? '',
      categoryName: (map['categoryName'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: original == null ? null : (original as num).toDouble(),
      unit: (map['unit'] as String?) ?? '',
      imageUrl: (map['imageUrl'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      isFreshDeal: (map['isFreshDeal'] as bool?) ?? false,
      isBestSeller: (map['isBestSeller'] as bool?) ?? false,
      isA2CowMilk: (map['isA2CowMilk'] as bool?) ?? false,
      inStock: (map['inStock'] as bool?) ?? true,
    );
  }

  /// Serializes this [Product] for writing to Firestore.
  Map<String, dynamic> toFirestore() => {
        'title': title,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'price': price,
        'originalPrice': originalPrice,
        'unit': unit,
        'imageUrl': imageUrl,
        'description': description,
        'rating': rating,
        'reviewCount': reviewCount,
        'isFreshDeal': isFreshDeal,
        'isBestSeller': isBestSeller,
        'isA2CowMilk': isA2CowMilk,
        'inStock': inStock,
      };
}
