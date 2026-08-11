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
}
