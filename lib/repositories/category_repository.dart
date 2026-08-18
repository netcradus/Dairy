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
        imageUrl: AppAssets.milkPng,
        iconData: Icons.local_drink_rounded,
        backgroundColor: Color(0xFFEBF4FE),
        itemCount: 8,
      ),
      Category(
        id: 'cat_curd',
        title: 'Curd',
        subtitle: 'Thick & Healthy',
        imageUrl: AppAssets.curdPlaceholder,
        iconData: Icons.rice_bowl_rounded,
        backgroundColor: Color(0xFFEDF7ED),
        itemCount: 6,
      ),
      Category(
        id: 'cat_lassi',
        title: 'Lassi',
        subtitle: 'Refreshing & Tasty',
        imageUrl: AppAssets.lassiPng,
        iconData: Icons.local_cafe_rounded,
        backgroundColor: Color(0xFFE6F4FE),
        itemCount: 4,
      ),
      Category(
        id: 'cat_paneer',
        title: 'Paneer & Butter',
        subtitle: 'Soft & Delicious',
        imageUrl: AppAssets.paneerPlaceholder,
        iconData: Icons.lunch_dining_rounded,
        backgroundColor: Color(0xFFFEF7EB),
        itemCount: 5,
      ),
      Category(
        id: 'cat_ghee',
        title: 'Pure Ghee',
        subtitle: 'Premium Quality',
        imageUrl: AppAssets.gheePlaceholder,
        iconData: Icons.opacity_rounded,
        backgroundColor: Color(0xFFFFF8EA),
        itemCount: 4,
      ),
    ];
  }
}
