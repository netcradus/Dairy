import 'package:flutter/material.dart';

class KpiMetric {
  final String title;
  final String value;
  final String growthText;
  final bool isPositive;
  final IconData icon;
  final Color themeColor;
  final Color themeBgColor;

  const KpiMetric({
    required this.title,
    required this.value,
    required this.growthText,
    required this.isPositive,
    required this.icon,
    required this.themeColor,
    required this.themeBgColor,
  });
}
