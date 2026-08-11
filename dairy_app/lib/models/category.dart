import 'package:flutter/material.dart';

/// Category Model for Sawariya Dairy
class Category {
  final String id;
  final String title;
  final String imageUrl;
  final IconData? iconData;
  final Color backgroundColor;
  final int itemCount;

  const Category({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.iconData,
    this.backgroundColor = const Color(0xFFEAF3FF),
    this.itemCount = 0,
  });
}
