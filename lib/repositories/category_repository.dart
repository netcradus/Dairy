import 'package:flutter/material.dart';
import '../models/category.dart';
import '../core/constants/app_assets.dart';

class CategoryRepository {
  List<Category> getCategories() {
    return const [
      Category(
        id: 'cat_milk',
        title: 'Fresh Milk',
        subtitle: '100% Pure',
        imageUrl: 'assets/images/milk.png',
        iconData: Icons.local_drink_rounded,
        backgroundColor: Color(0xFFEAF5FF),
        borderColor: Color(0xFFD2E6FF),
        titleColor: Color(0xFF0C1A30),
        itemCount: 8,
      ),
      Category(
        id: 'cat_makhan',
        title: 'Makhan',
        subtitle: 'Thick & Healthy',
        imageUrl: 'assets/images/makhana.png',
        iconData: Icons.rice_bowl_rounded,
        backgroundColor: Color(0xFFF0F9F4),
        borderColor: Color(0xFFDBEFE3),
        titleColor: Color(0xFF005F38),
        itemCount: 6,
      ),
      Category(
        id: 'cat_lassi',
        title: 'Lassi',
        subtitle: 'Refreshing & Tasty',
        imageUrl: 'assets/images/lassi.png',
        iconData: Icons.local_cafe_rounded,
        backgroundColor: Color(0xFFEBF3FE),
        borderColor: Color(0xFFD2E3FC),
        titleColor: Color(0xFF0C1A30),
        itemCount: 4,
      ),
      Category(
        id: 'cat_paneer',
        title: 'Paneer',
        subtitle: 'Soft & Delicious',
        imageUrl: 'assets/images/paneer.png',
        iconData: Icons.lunch_dining_rounded,
        backgroundColor: Color(0xFFFFF5EA),
        borderColor: Color(0xFFFEDEB8),
        titleColor: Color(0xFF0C1A30),
        itemCount: 5,
      ),
      Category(
        id: 'cat_ghee',
        title: 'Pure Ghee',
        subtitle: 'Premium Quality',
        imageUrl: 'assets/images/ghee.png',
        iconData: Icons.opacity_rounded,
        backgroundColor: Color(0xFFFFF9EE),
        borderColor: Color(0xFFFEE6C5),
        titleColor: Color(0xFF0C1A30),
        itemCount: 4,
      ),
    ];
  }
}
