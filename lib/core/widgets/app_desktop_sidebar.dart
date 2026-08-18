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
        color: Color(0xFFE2EFE7),
        border: Border(right: BorderSide(color: Color(0xFFCBE0D4), width: 1.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Brand Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                // Custom Cow Logo
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/sawariya_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SAWARIYA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF005F38),
                          letterSpacing: 0.8,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'DAIRY',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF005F38),
                          letterSpacing: 1.5,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pure Milk. Pure Trust.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF005F38),
                          letterSpacing: 0.2,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFCBE0D4)),
          const SizedBox(height: AppSizes.p16),

          // Navigation Links List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  _SidebarNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: AppStrings.navHome,
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  const SizedBox(height: 6),
                  _SidebarNavItem(
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view_rounded,
                    label: AppStrings.navShop,
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  const SizedBox(height: 6),
                  _SidebarNavItem(
                    icon: Icons.local_shipping_outlined,
                    activeIcon: Icons.local_shipping_rounded,
                    label: AppStrings.navOrders,
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  const SizedBox(height: 6),
                  _SidebarNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: AppStrings.navProfile,
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Desktop Footer Profile Widget
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECF5F0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBE0D4), width: 0.8),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFF005F38),
                    radius: 18,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sawariya Customer',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF005F38),
                          ),
                        ),
                        Text(
                          'Fresh Member',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF005F38),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF005F38),
                    size: 18,
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
              ? const Color(0xFF005F38)
              : (_isHovered ? const Color(0xFFD4E6DC) : Colors.transparent),
          borderRadius: AppSizes.borderMedium,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppSizes.borderMedium,
          child: ListTile(
            onTap: widget.onTap,
            shape: const RoundedRectangleBorder(
              borderRadius: AppSizes.borderMedium,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p16,
              vertical: 2,
            ),
            leading: Icon(
              active ? widget.activeIcon : widget.icon,
              color: active
                  ? Colors.white
                  : (_isHovered
                        ? const Color(0xFF005F38)
                        : const Color(0xFF334E41)),
              size: 22,
            ),
            title: Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? Colors.white
                    : (_isHovered
                          ? const Color(0xFF005F38)
                          : const Color(0xFF334E41)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CowLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF005F38)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    double cx = size.width / 2;
    double cy = size.height / 2 + 3;
    
    // Face outline: rounded shape
    path.moveTo(cx - 10, cy - 14);
    path.quadraticBezierTo(cx, cy - 16, cx + 10, cy - 14);
    path.quadraticBezierTo(cx + 12, cy - 2, cx + 9, cy + 8);
    path.quadraticBezierTo(cx, cy + 13, cx - 9, cy + 8);
    path.quadraticBezierTo(cx - 12, cy - 2, cx - 10, cy - 14);
    
    // Snout / Muzzle
    path.moveTo(cx - 9, cy + 2);
    path.quadraticBezierTo(cx, cy - 1, cx + 9, cy + 2);
    path.quadraticBezierTo(cx + 9, cy + 8, cx + 7, cy + 10);
    path.quadraticBezierTo(cx, cy + 13, cx - 7, cy + 10);
    path.quadraticBezierTo(cx - 9, cy + 8, cx - 9, cy + 2);
    
    // Ears
    path.moveTo(cx - 11, cy - 10);
    path.cubicTo(cx - 20, cy - 12, cx - 22, cy - 2, cx - 12, cy + 2);
    path.close();
    
    path.moveTo(cx + 11, cy - 10);
    path.cubicTo(cx + 20, cy - 12, cx + 22, cy - 2, cx + 12, cy + 2);
    path.close();
    
    // Horns
    path.moveTo(cx - 9, cy - 13);
    path.quadraticBezierTo(cx - 15, cy - 22, cx - 8, cy - 25);
    path.quadraticBezierTo(cx - 5, cy - 21, cx - 6, cy - 14);
    path.close();
    
    path.moveTo(cx + 9, cy - 13);
    path.quadraticBezierTo(cx + 15, cy - 22, cx + 8, cy - 25);
    path.quadraticBezierTo(cx + 5, cy - 21, cx + 6, cy - 14);
    path.close();
    
    canvas.drawPath(path, paint);
    
    final nostrilPaint = Paint()
      ..color = const Color(0xFFE2EFE7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 3, cy + 6), 1.5, nostrilPaint);
    canvas.drawCircle(Offset(cx + 3, cy + 6), 1.5, nostrilPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
