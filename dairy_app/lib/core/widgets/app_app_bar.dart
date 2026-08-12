import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../responsive/responsive.dart';

/// Clean Production Header Bar for Mobile, Tablet & Desktop
class AppTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onCartTap;
  final int cartItemCount;

  const AppTopAppBar({
    super.key,
    this.title = 'Sawariya Dairy',
    this.onSearchTap,
    this.onNotificationTap,
    this.onCartTap,
    this.cartItemCount = 2,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Container(
      height: preferredSize.height,
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveHorizontalPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Left: Logo / Location Tag
          Row(
            children: [
              if (!isDesktop) ...[
                Container(
                  height: 36,
                  width: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: AppSizes.borderSmall,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.water_drop_rounded,
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
              ],
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.primaryBlue,
                        size: 16,
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.primaryBlue,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Deliver to Jaipur, 302001',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Search Field or Icon Button
          if (isDesktop)
            SizedBox(
              width: 380,
              height: 40,
              child: TextField(
                readOnly: true,
                onTap: onSearchTap,
                decoration: const InputDecoration(
                  hintText: 'Search milk, curd, paneer, ghee...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: AppSizes.borderMedium,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
              onPressed: onSearchTap,
            ),

          const SizedBox(width: AppSizes.p8),

          // Notification Button
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            onPressed: onNotificationTap,
          ),

          const SizedBox(width: AppSizes.p4),

          // Cart Button with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryBlue),
                onPressed: onCartTap,
              ),
              if (cartItemCount > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
