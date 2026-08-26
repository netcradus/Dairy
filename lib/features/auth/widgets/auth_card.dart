import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/responsive/responsive.dart';

/// Responsive Luxury Authentication Shell Container Card for Sawariya Dairy
class AuthCard extends StatelessWidget {
  final Widget child;
  final String? featureTitle;
  final String? featureSubtitle;
  final String videoPath;

  const AuthCard({
    super.key,
    required this.child,
    this.featureTitle = 'Pure Dairy at Your Doorstep',
    this.featureSubtitle =
        'Order farm-fresh A2 milk, ghee, paneer, and butter with daily morning delivery.',
    this.videoPath = 'assets/images/logvn.mp4',
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0), // Soft Parchment / Off-White
      body: Stack(
        children: [
          // Full-screen background image
          Positioned.fill(
            child: Image.asset(
              AppAssets.landingBg,
              fit: BoxFit.cover,
            ),
          ),
          // Ambient overlay to ensure contrast
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ),
          // 1. Background Watermark Graphics
          // Bottom-Left Watermark (Milk drops & Reeds)
          Positioned(
            left: -30,
            bottom: -20,
            child: Opacity(
              opacity: 0.08,
              child: CustomPaint(
                size: const Size(260, 260),
                painter: _WatermarkDropsPainter(),
              ),
            ),
          ),

          // Right Watermark (Vintage Milk Can Line Art)
          Positioned(
            right: size.width * 0.02,
            bottom: size.height * 0.05,
            child: Opacity(
              opacity: 0.07,
              child: CustomPaint(
                size: Size(size.height * 0.55, size.height * 0.75),
                painter: _MilkCanWatermarkPainter(),
              ),
            ),
          ),

          // 2. Main Centered Gold-Bordered Container Card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 36.0 : 16.0,
                  vertical: isDesktop ? 28.0 : 16.0,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 960 : 460,
                  ),
                  // Outer Gold Frame
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFF5E4B5),
                        Color(0xFFC5A059),
                        Color(0xFF8C6D2B),
                        Color(0xFFF5E4B5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 32,
                        spreadRadius: 2,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2.5), // Gold Border Thickness
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFFFAF7EE), // Inner Cream Parchment Surface
                      borderRadius: BorderRadius.circular(21.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21.5),
                      child: isDesktop
                          ? Row(
                              children: [
                                // Left Column: Dairy Mascot Visual Panel
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    height: 520,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: _AuthVideoPlayer(
                                        videoPath: videoPath,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),

                                // Right Column: Form Content Child
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(36),
                                    child: child,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 240,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: _AuthVideoPlayer(
                                      videoPath: videoPath,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: child,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Bottom-Left Watermark Drops
class _WatermarkDropsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8C6D2B)
      ..style = PaintingStyle.fill;

    // Draw milk drops
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 14, paint);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.3), 10, paint);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.65), 18, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Right Watermark Vintage Milk Can
class _MilkCanWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF786236)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final w = size.width;
    final h = size.height;

    // Milk Can Outer Contour
    final path = Path();
    path.moveTo(w * 0.3, h * 0.1);
    path.lineTo(w * 0.7, h * 0.1);
    path.lineTo(w * 0.75, h * 0.22);
    path.lineTo(w * 0.85, h * 0.35);
    path.lineTo(w * 0.85, h * 0.9);
    path.lineTo(w * 0.15, h * 0.9);
    path.lineTo(w * 0.15, h * 0.35);
    path.lineTo(w * 0.25, h * 0.22);
    path.close();

    canvas.drawPath(path, paint);

    // Can lid handle
    canvas.drawArc(
      Rect.fromLTWH(w * 0.35, h * 0.02, w * 0.3, h * 0.12),
      3.14,
      3.14,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Video Player Widget for Login Page
// ─────────────────────────────────────────────────────────────────────────────

class _AuthVideoPlayer extends StatefulWidget {
  final BoxFit fit;
  final String videoPath;
  const _AuthVideoPlayer({
    required this.videoPath,
    this.fit = BoxFit.contain,
  });

  @override
  State<_AuthVideoPlayer> createState() => _AuthVideoPlayerState();
}

class _AuthVideoPlayerState extends State<_AuthVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.play();
        _controller.setVolume(0.0); // Mute
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF005F38),
        ),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
