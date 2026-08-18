import 'package:flutter/material.dart';
import '../models/category.dart';
import '../core/constants/app_assets.dart';

class CategoryRepository {
  List<Category> getCategories() {
    return const [
      Category(
        id: 'cat_milk',
        title: 'Milk',
        subtitle: '100% Pure',
        imageUrl: 'assets/images/milk.png',
        iconData: Icons.local_drink_rounded,
        backgroundColor: Color(0xFFEBF4FE),
        itemCount: 8,
      ),
      Category(
        id: 'cat_lassi',
        title: 'Lassi',
        subtitle: 'Refreshing & Tasty',
        imageUrl: 'assets/images/lassi.png',
        iconData: Icons.local_cafe_rounded,
        backgroundColor: Color(0xFFE6F4FE),
        itemCount: 4,
      ),
      Category(
        id: 'cat_makhan',
        title: 'Makhan',
        subtitle: 'Fresh & Creamy',
        imageUrl: 'assets/images/makhan.png',
        iconData: Icons.rice_bowl_rounded,
        backgroundColor: Color(0xFFEDF7ED),
        itemCount: 6,
      ),
      Category(
        id: 'cat_ghee',
        title: 'Ghee',
        subtitle: 'Premium Quality',
        imageUrl: 'assets/images/ghee.png',
        iconData: Icons.opacity_rounded,
        backgroundColor: Color(0xFFFFF8EA),
        itemCount: 4,
      ),
      Category(
        id: 'cat_paneer',
        title: 'Paneer',
        subtitle: 'Soft & Delicious',
        imageUrl: 'assets/images/paneer.png',
        iconData: Icons.lunch_dining_rounded,
        backgroundColor: Color(0xFFFEF7EB),
        itemCount: 5,
      ),
    ];
  }
}
