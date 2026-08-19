import 'package:flutter/material.dart';

class Category {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final IconData iconData;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final int itemCount;

  const Category({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.iconData,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.itemCount,
  });
}
