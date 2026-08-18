import 'package:flutter/material.dart';

/// Category Model for Sawariya Dairy
class Category {
  static const Map<String, IconData> _iconByName = {
    'milk': Icons.local_drink_rounded,
    'lassi': Icons.local_cafe_rounded,
    'makhan': Icons.rice_bowl_rounded,
    'ghee': Icons.opacity_rounded,
    'paneer': Icons.lunch_dining_rounded,
    'curd': Icons.icecream_rounded,
  };

  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final IconData? iconData;
  final Color backgroundColor;
  final int itemCount;

  const Category({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.imageUrl,
    this.iconData,
    this.backgroundColor = const Color(0xFFEAF3FF),
    this.itemCount = 0,
  });

  /// Creates a [Category] from a Firestore document map.
  factory Category.fromFirestore(Map<String, dynamic> data, String id) {
    final iconName = data['iconName'] as String?;
    final colorValue = data['colorValue'] as int?;
    return Category(
      id: id,
      title: (data['title'] as String?) ?? '',
      subtitle: (data['subtitle'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      iconData: iconName == null ? null : _iconByName[iconName],
      backgroundColor:
          colorValue == null ? const Color(0xFFEAF3FF) : Color(colorValue),
      itemCount: (data['itemCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes this [Category] for writing to Firestore.
  Map<String, dynamic> toFirestore() {
    String? iconName;
    if (iconData != null) {
      for (final entry in _iconByName.entries) {
        if (entry.value == iconData) {
          iconName = entry.key;
          break;
        }
      }
    }
    return {
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'iconName': iconName,
      'colorValue': backgroundColor.value,
      'itemCount': itemCount,
    };
  }
}
