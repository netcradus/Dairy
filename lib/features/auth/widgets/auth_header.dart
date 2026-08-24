import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_sizes.dart';

/// Reusable Sawariya Dairy Brand Auth Header Component matching reference image
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Logo Icon & Badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/logo(1).png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Sawariya Dairy',
              style: GoogleFonts.playfairDisplay(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C1810),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.p20),

        // Welcome Title
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF132238),
            height: 1.2,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: AppSizes.p6),

        // Subtitle Description
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF4A5568),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
