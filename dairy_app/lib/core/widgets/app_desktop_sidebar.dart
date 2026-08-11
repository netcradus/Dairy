import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';

/// Desktop Left Sidebar Navigation Component
class AppDesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppDesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.desktopSidebarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Brand Logo
          Padding(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: AppSizes.borderMedium,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.water_drop_rounded,
                      color: AppColors.primaryBlue,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SAWARIYA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlue,
                        letterSpacing: 1.0,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'DAIRY',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 2.0,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: AppSizes.p16),

          // Navigation Links List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              child: Column(
                children: [
                  _SidebarNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: AppStrings.navHome,
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  _SidebarNavItem(
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view_rounded,
                    label: AppStrings.navShop,
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  _SidebarNavItem(
                    icon: Icons.local_shipping_outlined,
                    activeIcon: Icons.local_shipping_rounded,
                    label: AppStrings.navOrders,
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  _SidebarNavItem(
                    icon: Icons.local_offer_outlined,
                    activeIcon: Icons.local_offer_rounded,
                    label: AppStrings.navOffers,
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  _SidebarNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: AppStrings.navProfile,
                    isSelected: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Desktop Footer Profile Widget
          Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Container(
              padding: const EdgeInsets.all(AppSizes.p12),
              decoration: BoxDecoration(
                color: AppColors.lightBlue.withValues(alpha: 0.6),
                borderRadius: AppSizes.borderMedium,
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primaryBlue,
                    radius: 18,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sawariya Customer',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Fresh Member',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryBlue
              : (_isHovered ? AppColors.lightBlue : Colors.transparent),
          borderRadius: AppSizes.borderMedium,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppSizes.borderMedium,
          child: ListTile(
            onTap: widget.onTap,
            shape: RoundedRectangleBorder(borderRadius: AppSizes.borderMedium),
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 2),
            leading: Icon(
              active ? widget.activeIcon : widget.icon,
              color: active
                  ? Colors.white
                  : (_isHovered ? AppColors.primaryBlue : AppColors.textSecondary),
              size: 22,
            ),
            title: Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? Colors.white
                    : (_isHovered ? AppColors.primaryBlue : AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
