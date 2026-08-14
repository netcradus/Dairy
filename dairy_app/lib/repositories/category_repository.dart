import 'package:flutter/material.dart';
import '../models/category.dart';
import '../core/constants/app_assets.dart';

class CategoryRepository {
  List<Category> getCategories() {
    return const [
      Category(
        id: 'cat_milk',
        title: 'Fresh Milk',
        imageUrl: AppAssets.milkPlaceholder,
        iconData: Icons.local_drink_rounded,
        backgroundColor: Color(0xFFEAF3FF),
        itemCount: 8,
      ),
      Category(
        id: 'cat_curd',
        title: 'Curd & Lassi',
        imageUrl: AppAssets.curdPlaceholder,
        iconData: Icons.rice_bowl_rounded,
        backgroundColor: Color(0xFFEFF6FF),
        itemCount: 6,
      ),
      Category(
        id: 'cat_paneer',
        title: 'Paneer & Butter',
        imageUrl: AppAssets.paneerPlaceholder,
        iconData: Icons.lunch_dining_rounded,
        backgroundColor: Color(0xFFFEF3C7),
        itemCount: 5,
      ),
      Category(
        id: 'cat_ghee',
        title: 'Pure Ghee',
        imageUrl: AppAssets.gheePlaceholder,
        iconData: Icons.opacity_rounded,
        backgroundColor: Color(0xFFFEF9C3),
        itemCount: 4,
      ),
    ];
  }
}
