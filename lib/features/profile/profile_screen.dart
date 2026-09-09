import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/responsive/responsive.dart';
import '../../core/widgets/app_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../services/firebase_storage_service.dart';
import 'edit_profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../subscription/subscriptions_screen.dart';
import 'about_screen.dart';
import '../../core/localization/app_language.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 700 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── 1. Header Card (Splash/Gradient Green with User Profile Info) ───
                  _buildProfileHeaderCard(context, ref),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── 2. My Orders Quick Stats Card ───
                        _buildMyOrdersStatsCard(context, ref),
                        const SizedBox(height: 20),



                        // ─── 4. Account Settings Menu ───
                        Text(
                          tr('Account Settings'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFFF1F5F9), width: 1.0),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                _buildMenuTile(
                                  context,
                                  Icons.person_outline_rounded,
                                  tr('My Profile'),
                                  tr('Manage your personal details'),
                                  () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const EditProfileScreen()));
                                  },
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFF1F5F9)),
                                _buildMenuTile(
                                  context,
                                  Icons.location_on_outlined,
                                  tr('Delivery Addresses'),
                                  tr('Add or edit delivery addresses'),
                                  () {
                                    context.push('/address');
                                  },
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFF1F5F9)),
                                _buildMenuTile(
                                  context,
                                  Icons.payment_outlined,
                                  'Payment Methods',
                                  'Manage your payment options',
                                  () {},
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFF1F5F9)),
                                _buildMenuTile(
                                  context,
                                  Icons.autorenew_rounded,
                                  'My Subscriptions',
                                  'Manage milk & product subscriptions',
                                  () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const SubscriptionsScreen()));
                                  },
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFF1F5F9)),
                                _buildMenuTile(
                                  context,
                                  Icons.notifications_none_rounded,
                                  'Notifications',
                                  'Manage your notification preferences',
                                  () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const NotificationsScreen()));
                                  },
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFF1F5F9)),
                                _buildMenuTile(
                                  context,
                                  Icons.support_agent_rounded,
                                  'Support / Complaints',
                                  'Raise queries & view ticket status',
                                  () {
                                    context.push('/support');
                                  },
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFF1F5F9)),
                                _buildMenuTile(
                                  context,
                                  Icons.info_outline_rounded,
                                  'About Sawariya Dairy',
                                  'Know more about us',
                                  () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const AboutScreen()));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Logout Button
                        _buildLogoutTile(context, ref),
                        const SizedBox(height: 32),
                      ],
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

  Widget _buildProfileHeaderCard(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    debugPrint('[PROFILE DEBUG T5] ProfileScreen: profileImageUrl received: ${user.profileImageUrl}');
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF5EF), Color(0xFFF1F9F5), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Stack(
        children: [
          // Main User Details
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User Avatar with Camera edit button
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: const Color(0xFFE2EFE7),
                          child: ClipOval(
                            child: SizedBox(
                              width: 92,
                              height: 92,
                              child: (user.profileImageUrl != null &&
                                      user.profileImageUrl!.trim().isNotEmpty &&
                                      user.profileImageUrl!.trim().startsWith('http'))
                                  ? Builder(
                                      builder: (context) {
                                        debugPrint('[PROFILE DEBUG] 10. Rendering avatar widget: AppNetworkImage');
                                        return AppNetworkImage(
                                          imageUrl: user.profileImageUrl!.trim(),
                                          width: 92,
                                          height: 92,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              debugPrint('[PROFILE DEBUG] 11. Image loading state: LOADED');
                                              return child;
                                            }
                                            debugPrint('[PROFILE DEBUG] 11. Image loading state: IN PROGRESS');
                                            return const Center(
                                              child: SizedBox(
                                                width: 28,
                                                height: 28,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Color(0xFF005F38),
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            debugPrint('[PROFILE DEBUG] 12. Image error: $error');
                                            return const Center(
                                              child: Icon(
                                                Icons.person_rounded,
                                                size: 55,
                                                color: Color(0xFF005F38),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    )
                                  : Builder(
                                      builder: (context) {
                                        debugPrint('[PROFILE DEBUG] 10. Rendering avatar widget: Fallback Person Icon (profileImageUrl is null/empty)');
                                        return const Center(
                                          child: Icon(
                                            Icons.person_rounded,
                                            size: 55,
                                            color: Color(0xFF005F38),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: GestureDetector(
                          onTap: () =>
                              _uploadProfilePhoto(context, ref, user.id),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 14,
                              color: Color(0xFF005F38),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(
                    user.name.isEmpty ? 'Sawariya Customer' : user.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF172033),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Phone Number
                  Text(
                    user.phone.isEmpty ? '+91 98765 43210' : user.phone,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF667085),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Membership Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF005F38), width: 1.0),
                    ),
                    child: const Text(
                      'Fresh Member',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF005F38),
                      ),
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

  Widget _buildMyOrdersStatsCard(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Title Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Orders',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF172033),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ref
                      .read(navigationProvider.notifier)
                      .setIndex(2); // Navigate to Orders Tab
                },
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF005F38),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF005F38),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Count stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOrderStatColumn(
                  Icons.shopping_bag_outlined, 'All Orders', '12'),
              _buildOrderStatColumn(
                  Icons.inventory_2_outlined, 'Processing', '3'),
              _buildOrderStatColumn(Icons.check_box_outlined, 'Delivered', '8'),
              _buildOrderStatColumn(
                  Icons.cancel_presentation_outlined, 'Cancelled', '1'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatColumn(IconData icon, String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFFEAF5EF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF005F38), size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF667085),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          count,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: Color(0xFF005F38),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(0xFFEAF5EF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF005F38), size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF172033),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF98A2B3),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFCBD5E1),
        size: 18,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutTile(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded,
                color: Colors.redAccent, size: 18),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
            ),
          ),
          subtitle: const Text(
            'Log out of your account',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF98A2B3),
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFCBD5E1),
            size: 18,
          ),
          onTap: () => showLogoutDialog(context, ref),
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content:
            const Text('Are you sure you want to log out of Sawariya Dairy?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cartProvider.notifier).clearLocalCart();
              ref.read(userProvider.notifier).clearSession();
            },
            child: const Text('Log Out',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadProfilePhoto(
      BuildContext context, WidgetRef ref, String uid) async {
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final effectiveUid = (uid.trim().isNotEmpty) ? uid.trim() : (authUid ?? '');

    debugPrint('[PROFILE DEBUG T0] 1. Firebase Auth UID: $authUid (effective: $effectiveUid)');
    debugPrint('[PROFILE DEBUG T0] profileImageUrl before upload: ${ref.read(userProvider).profileImageUrl}');

    if (effectiveUid.isEmpty) {
      debugPrint('[PROFILE DEBUG] Upload aborted: no authenticated user found');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to update your profile photo.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) {
        debugPrint('[PROFILE DEBUG] Image picker cancelled by user');
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading profile photo...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      final bytes = await picked.readAsBytes();
      final storagePath = 'profiles/$effectiveUid/image';
      debugPrint('[PROFILE DEBUG] 2. Storage upload path: $storagePath');

      final downloadUrl = await FirebaseStorageService.instance
          .uploadProfileImage(uid: effectiveUid, bytes: bytes);

      final uri = Uri.tryParse(downloadUrl);
      final safeUrlSummary = uri != null ? '${uri.scheme}://${uri.host}${uri.path}' : '[unparseable]';
      debugPrint('[PROFILE DEBUG T1] 3. Storage upload succeeded: true');
      debugPrint('[PROFILE DEBUG T1] 4. downloadUrl exists: ${downloadUrl.isNotEmpty}');
      debugPrint('[PROFILE DEBUG T1] 5. Download URL host/path: $safeUrlSummary');

      debugPrint('[PROFILE DEBUG T2] 6. Firestore document path: users/$effectiveUid');
      await ref
          .read(userProvider.notifier)
          .updateProfile(profileImageUrl: downloadUrl);

      final userAfter = ref.read(userProvider);
      debugPrint('[PROFILE DEBUG T3] 7. Firestore profileImageUrl after write: $safeUrlSummary');
      debugPrint('[PROFILE DEBUG T3] 8. userProvider.profileImageUrl immediately after updateProfile(): ${userAfter.profileImageUrl}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully!'),
            backgroundColor: Color(0xFF005F38),
          ),
        );
      }
    } catch (e) {
      debugPrint('[PROFILE DEBUG] Failed to upload photo error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile photo: ${e.toString().replaceAll("Exception: ", "")}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
