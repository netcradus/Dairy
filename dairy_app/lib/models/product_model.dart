class DairyProduct {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final String unit;
  final double price;
  final int ordersCount;
  final double totalRevenue;
  final int stockQuantity;
  final String fatContent;
  final String packaging;
  final bool inStock;
  final String emoji;

  const DairyProduct({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.unit,
    required this.price,
    required this.ordersCount,
    required this.totalRevenue,
    required this.stockQuantity,
    required this.fatContent,
    required this.packaging,
    this.inStock = true,
    required this.emoji,
  });

  DairyProduct copyWith({
    String? id,
    String? name,
    String? subtitle,
    String? category,
    String? unit,
    double? price,
    int? ordersCount,
    double? totalRevenue,
    int? stockQuantity,
    String? fatContent,
    String? packaging,
    bool? inStock,
    String? emoji,
  }) {
    return DairyProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      ordersCount: ordersCount ?? this.ordersCount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      fatContent: fatContent ?? this.fatContent,
      packaging: packaging ?? this.packaging,
      inStock: inStock ?? this.inStock,
      emoji: emoji ?? this.emoji,
    );
  }
}
