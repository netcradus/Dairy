import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_language.dart';
import 'app_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';

/// Desktop Left Sidebar Navigation Component matching the dark green aesthetic
class AppDesktopSidebar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppDesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Container(
      width: 235,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF063A24), // Rich dark forest green
        border: Border(right: BorderSide(color: Color(0xFF08422A), width: 1.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Brand Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: Row(
              children: [
                // Custom Cow Logo
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/newlogo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'SAWARIYA',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'DAIRY',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr('Pure Milk. Pure Trust.'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB4D3C5),
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

          const SizedBox(height: 12),

          // Navigation Links List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  _SidebarNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: tr('Home'),
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  const SizedBox(height: 8),
                  _SidebarNavItem(
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view_rounded,
                    label: tr('Shop'),
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                  const SizedBox(height: 8),
                  _SidebarNavItem(
                    icon: Icons.local_shipping_outlined,
                    activeIcon: Icons.local_shipping_rounded,
                    label: tr('Orders'),
                    isSelected: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  const SizedBox(height: 8),
                  _SidebarNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: tr('Profile'),
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Desktop Footer Profile Widget
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showUserPopup(context, ref),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF072E1C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF0F4E34),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF1B6B4C),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: (user.profileImageUrl != null &&
                                  user.profileImageUrl!.trim().isNotEmpty &&
                                  user.profileImageUrl!
                                      .trim()
                                      .startsWith('http'))
                              ? AppNetworkImage(
                                  imageUrl: user.profileImageUrl!.trim(),
                                  width: 38,
                                  height: 38,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Color(0xFFC7E2D6),
                                      size: 22,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFF0D4830),
                                  child: const Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Color(0xFFC7E2D6),
                                      size: 22,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          user.name.isNotEmpty ? user.name : tr('Zehra Khan'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFC7E2D6),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserPopup(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    final displayName = user.name.isNotEmpty ? user.name : tr('Zehra Khan');

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        alignment: Alignment.bottomLeft,
        child: Container(
          width: 250,
          margin: const EdgeInsets.only(left: 14, bottom: 65),
          decoration: BoxDecoration(
            color: const Color(0xFF072E1C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1B6B4C), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Card Header
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1B6B4C),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: (user.profileImageUrl != null &&
                                user.profileImageUrl!.trim().isNotEmpty &&
                                user.profileImageUrl!.trim().startsWith('http'))
                            ? AppNetworkImage(
                                imageUrl: user.profileImageUrl!.trim(),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFFC7E2D6),
                                    size: 24,
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFF0D4830),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFFC7E2D6),
                                    size: 24,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (user.phone.isNotEmpty ||
                              (user.email != null && user.email!.isNotEmpty))
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                user.phone.isNotEmpty
                                    ? user.phone
                                    : (user.email ?? ''),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFFC7E2D6),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF0F4E34), height: 1),
              // View Profile Option
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    onTap(3);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            color: Color(0xFFC7E2D6), size: 19),
                        const SizedBox(width: 10),
                        Text(
                          tr('My Profile'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded,
                            color: Color(0xFFC7E2D6), size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(color: Color(0xFF0F4E34), height: 1),
              // Log Out Option
              Material(
                color: Colors.transparent,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: InkWell(
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showLogoutDialog(context, ref);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: Color(0xFFFF7B7B), size: 19),
                        const SizedBox(width: 10),
                        Text(
                          tr('Log Out'),
                          style: const TextStyle(
                            color: Color(0xFFFF7B7B),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Colors.redAccent, size: 22),
            ),
            const SizedBox(width: 10),
            Text(tr('Log Out'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          tr('Are you sure you want to log out of Sawariya Dairy?'),
          style: const TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              tr('Cancel'),
              style: const TextStyle(
                  color: Color(0xFF4A5568), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cartProvider.notifier).clearLocalCart();
              ref.read(userProvider.notifier).clearSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              tr('Log Out'),
              style: const TextStyle(fontWeight: FontWeight.bold),
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
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF0D4830)
              : (_isHovered ? const Color(0xFF0A4029) : Colors.transparent),
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    active ? widget.activeIcon : widget.icon,
                    color: active ? Colors.white : const Color(0xFFC7E2D6),
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? Colors.white : const Color(0xFFC7E2D6),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
