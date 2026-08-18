import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/responsive/responsive.dart';
import '../../providers/navigation_provider.dart';

const String _logoAsset = 'assets/images/sawariya_logo.png';

/// Returns true when the widget is at least partially within the viewport.
bool _widgetVisible(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox) return false;
  final offset = box.localToGlobal(Offset.zero);
  final vh = MediaQuery.of(context).size.height;
  return offset.dy < vh * 0.88 && offset.dy + box.size.height > 0;
}

class _Stage {
  final String number;
  final String title;
  final String description;
  final String image;
  const _Stage(this.number, this.title, this.description, this.image);
}

class _Product {
  final String name;
  final String description;
  final String image;
  const _Product(this.name, this.description, this.image);
}

class _Value {
  final String title;
  final String description;
  final String image;
  const _Value(this.title, this.description, this.image);
}

const List<_Stage> _stages = [
  _Stage('01', 'FARM', 'Careful dairy farming and responsible animal care.',
      AppAssets.heroBannerPlaceholder),
  _Stage('02', 'FRESH MILK', 'Fresh milk collected with care.',
      AppAssets.milkPlaceholder),
  _Stage('03', 'QUALITY CHECK', 'Quality-focused inspection and handling.',
      AppAssets.a2BannerPlaceholder),
  _Stage('04', 'HYGIENIC PROCESS', 'Careful and hygienic handling.',
      AppAssets.curdPlaceholder),
  _Stage('05', 'PACKAGING', 'Packed carefully for freshness and convenience.',
      AppAssets.paneerPlaceholder),
  _Stage('06', 'HOME DELIVERY', 'Delivered to your doorstep.',
      AppAssets.gheePlaceholder),
];

const List<_Product> _products = [
  _Product('Milk', 'Farm-fresh pure cow milk.', AppAssets.milkPlaceholder),
  _Product('Lassi', 'Creamy traditional sweet lassi.', AppAssets.curdPlaceholder),
  _Product('Makhan', 'Soft white homemade butter.', AppAssets.a2BannerPlaceholder),
  _Product('Paneer', 'Fresh soft cottage cheese.', AppAssets.paneerPlaceholder),
  _Product('Ghee', 'Pure traditional bilona ghee.', AppAssets.gheePlaceholder),
];

const List<_Value> _values = [
  _Value('PURITY', 'Care in every drop.', AppAssets.milkPlaceholder),
  _Value('QUALITY', 'Quality at every stage.', AppAssets.a2BannerPlaceholder),
  _Value('FRESHNESS', 'Freshness for everyday life.', AppAssets.curdPlaceholder),
  _Value('TRUST', 'Building lasting customer relationships.',
      AppAssets.heroBannerPlaceholder),
];

/// Generic scroll-triggered fade + slide-up reveal.
class _Reveal extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  const _Reveal({
    required this.child,
    required this.controller,
  });

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    widget.controller.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_started) return;
    if (_widgetVisible(context)) {
      _started = true;
      widget.controller.removeListener(_check);
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_check);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Animated farm-to-home timeline (horizontal on desktop, vertical on mobile).
class _FarmToHomeTimeline extends StatefulWidget {
  final ScrollController scrollController;
  final bool isDesktop;
  const _FarmToHomeTimeline({
    required this.scrollController,
    required this.isDesktop,
  });

  @override
  State<_FarmToHomeTimeline> createState() => _FarmToHomeTimelineState();
}

class _FarmToHomeTimelineState extends State<_FarmToHomeTimeline>
    with SingleTickerProviderStateMixin {
  static const double _circle = 64;
  late final AnimationController _ctrl;
  late final Animation<double> _line;
  late final List<Animation<Offset>> _slides;
  late final List<Animation<double>> _fades;
  bool _started = false;
  final int _n = _stages.length;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _line = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.75, curve: Curves.easeInOut),
      ),
    );
    _slides = List.generate(
      _n,
      (i) => Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i / _n, (i + 0.7) / _n, curve: Curves.easeOutCubic),
        ),
      ),
    );
    _fades = List.generate(
      _n,
      (i) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(i / _n, (i + 0.7) / _n, curve: Curves.easeOut),
        ),
      ),
    );
    widget.scrollController.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_started) return;
    if (_widgetVisible(context)) {
      _started = true;
      widget.scrollController.removeListener(_check);
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_check);
    _ctrl.dispose();
    super.dispose();
  }

  Widget _stage(int i) {
    final s = _stages[i];
    return FadeTransition(
      opacity: _fades[i],
      child: SlideTransition(
        position: _slides[i],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: _circle,
              height: _circle,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppColors.cardShadowMd,
                border: Border.all(color: Colors.white, width: 3),
                image: DecorationImage(
                  image: NetworkImage(s.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.p12),
            Text(
              s.number,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              s.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.p6),
            SizedBox(
              width: 150,
              child: Text(
                s.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDesktop) {
      return LayoutBuilder(
        builder: (ctx, constraints) {
          final content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              _n,
              (i) => Expanded(child: _stage(i)),
            ),
          );
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: _circle / 2 - 1.5,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _line,
                  builder: (c, _) => FractionallySizedBox(
                    widthFactor: _line.value,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                    ),
                  ),
                ),
              ),
              content,
            ],
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            _n,
            (i) => Padding(
              padding: const EdgeInsets.only(left: 80),
              child: _stage(i),
            ),
          ),
        );
        return Stack(
          children: [
            Positioned(
              left: _circle / 2 - 1.5,
              top: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _line,
                builder: (c, _) => FractionallySizedBox(
                  heightFactor: _line.value,
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                  ),
                ),
              ),
            ),
            content,
          ],
        );
      },
    );
  }
}

/// Product showcase card with hover / press scale animation.
class _ProductCard extends StatefulWidget {
  final _Product product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;
  bool _pressed = false;

  double get _scale => _hovered ? 1.05 : (_pressed ? 0.97 : 1.0);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSizes.borderLarge,
              border: Border.all(color: AppColors.border, width: 1.0),
              boxShadow: AppColors.cardShadowSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusLarge),
                    topRight: Radius.circular(AppSizes.radiusLarge),
                  ),
                  child: Image.network(
                    widget.product.image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.p14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.description,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand value card with real photo background, overlay and subtle hover scale.
class _ValueCard extends StatefulWidget {
  final _Value value;
  const _ValueCard({required this.value});

  @override
  State<_ValueCard> createState() => _ValueCardState();
}

class _ValueCardState extends State<_ValueCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: AppSizes.borderLarge,
            boxShadow: AppColors.cardShadowSm,
            image: DecorationImage(
              image: NetworkImage(widget.value.image),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppSizes.borderLarge,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryBlue.withValues(alpha: 0.45),
                  AppColors.primaryBlue.withValues(alpha: 0.88),
                ],
              ),
            ),
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.value.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.value.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width farm visual with subtle zoom + fade on enter.
class _StorySection extends StatefulWidget {
  final ScrollController scrollController;
  final String image;
  final String title;
  final String paragraph;
  const _StorySection({
    required this.scrollController,
    required this.image,
    required this.title,
    required this.paragraph,
  });

  @override
  State<_StorySection> createState() => _StorySectionState();
}

class _StorySectionState extends State<_StorySection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 1.12, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    widget.scrollController.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_started) return;
    if (_widgetVisible(context)) {
      _started = true;
      widget.scrollController.removeListener(_check);
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_check);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: AppSizes.borderLarge,
          child: FadeTransition(
            opacity: _opacity,
            child: AnimatedBuilder(
              animation: _scale,
              builder: (c, child) => Transform.scale(
                scale: _scale.value,
                child: child,
              ),
              child: Image.network(
                widget.image,
                height: context.isDesktop ? 320 : 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p20),
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        Text(
          widget.paragraph,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final maxWidth = isDesktop ? 1080.0 : double.infinity;
    final hPadding = context.responsiveHorizontalPadding;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About Sawariya Dairy'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: hPadding,
              vertical: AppSizes.p24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO
                _Reveal(
                  controller: _scrollController,
                  child: ClipRRect(
                    borderRadius: AppSizes.borderXLarge,
                    child: Stack(
                      children: [
                        Image.network(
                          AppAssets.heroBannerPlaceholder,
                          height: isDesktop ? 440 : 320,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          height: isDesktop ? 440 : 320,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.primaryBlue.withValues(alpha: 0.55),
                                AppColors.primaryBlue.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: AppSizes.p24,
                          right: AppSizes.p24,
                          bottom: AppSizes.p24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSizes.p8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppSizes.borderMedium,
                                  boxShadow: AppColors.cardShadowMd,
                                ),
                                child: Image.asset(
                                  _logoAsset,
                                  height: 44,
                                  width: 44,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: AppSizes.p16),
                              const Text(
                                'SAWARIYA SARKAR DAIRY LLP',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Pure Milk. Pure Trust. Pure Goodness.',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p40),

                // 2. ABOUT US — IMAGE + TEXT
                _Reveal(
                  controller: _scrollController,
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: AppSizes.borderLarge,
                                child: Image.network(
                                  AppAssets.a2BannerPlaceholder,
                                  height: 320,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.p32),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle('About Sawariya Dairy'),
                                  const Text(
                                    'Sawariya Sarkar Dairy LLP is a dairy brand '
                                    'focused on bringing fresh, quality dairy '
                                    'products from our dairy operations to '
                                    'families. We believe good dairy begins with '
                                    'responsible care, cleanliness, freshness and '
                                    'consistent quality.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.7,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: AppSizes.borderLarge,
                              child: Image.network(
                                AppAssets.a2BannerPlaceholder,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: AppSizes.p20),
                            _sectionTitle('About Sawariya Dairy'),
                            const Text(
                              'Sawariya Sarkar Dairy LLP is a dairy brand '
                              'focused on bringing fresh, quality dairy '
                              'products from our dairy operations to families. '
                              'We believe good dairy begins with responsible '
                              'care, cleanliness, freshness and consistent '
                              'quality.',
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.7,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: AppSizes.p40),

                // 3. FARM-TO-HOME TIMELINE
                _sectionTitle('From Our Farm to Your Home'),
                const SizedBox(height: AppSizes.p8),
                _FarmToHomeTimeline(
                  scrollController: _scrollController,
                  isDesktop: isDesktop,
                ),
                const SizedBox(height: AppSizes.p40),

                // 4. PRODUCT SHOWCASE
                _Reveal(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Our Dairy Products'),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isDesktop ? 5 : (isTablet ? 3 : 2),
                        mainAxisSpacing: AppSizes.p16,
                        crossAxisSpacing: AppSizes.p16,
                        childAspectRatio: 0.72,
                        children: _products
                            .map((p) => _ProductCard(product: p))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.p40),

                // 5. BRAND VALUES
                _Reveal(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Our Values'),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isDesktop ? 4 : 2,
                        mainAxisSpacing: AppSizes.p16,
                        crossAxisSpacing: AppSizes.p16,
                        childAspectRatio: 0.82,
                        children:
                            _values.map((v) => _ValueCard(value: v)).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.p40),

                // 6. BRAND STORY / FARM VISUAL
                _StorySection(
                  scrollController: _scrollController,
                  image: AppAssets.heroBannerPlaceholder,
                  title: 'Pure Dairy. From Our Farm to Your Family.',
                  paragraph: 'Every Sawariya Dairy product carries the care of '
                      'our farms — from the animals we nurture to the families '
                      'we serve. We keep traditional dairy values at the heart '
                      'of everything we do, so that pure, fresh goodness reaches '
                      'your home every single day.',
                ),
                const SizedBox(height: AppSizes.p40),

                // 7. OUR VISION
                _Reveal(
                  controller: _scrollController,
                  child: isDesktop
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: AppSizes.borderXLarge,
                            boxShadow: AppColors.cardShadowMd,
                            image: const DecorationImage(
                              image: NetworkImage(AppAssets.a2BannerPlaceholder),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: AppSizes.borderXLarge,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryBlue.withValues(alpha: 0.85),
                                  AppColors.primaryBlue.withValues(alpha: 0.95),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(AppSizes.p40),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Our Vision',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: AppSizes.p16),
                                Text(
                                  'To build a trusted dairy brand that makes '
                                  'fresh, quality dairy products accessible and '
                                  'convenient for everyday families while keeping '
                                  'traditional dairy values at the heart of '
                                  'everything we do.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.7,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: AppSizes.borderXLarge,
                            gradient: AppColors.brandGradient,
                            boxShadow: AppColors.cardShadowMd,
                          ),
                          padding: const EdgeInsets.all(AppSizes.p24),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Our Vision',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: AppSizes.p16),
                              Text(
                                'To build a trusted dairy brand that makes fresh, '
                                'quality dairy products accessible and convenient '
                                'for everyday families while keeping traditional '
                                'dairy values at the heart of everything we do.',
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.7,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: AppSizes.p40),

                // 8. FINAL CTA
                _Reveal(
                  controller: _scrollController,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: AppSizes.borderXLarge,
                      gradient: AppColors.brandGradientVertical,
                      boxShadow: AppColors.primaryShadow,
                    ),
                    padding: EdgeInsets.all(isDesktop ? AppSizes.p40 : AppSizes.p24),
                    child: Column(
                      children: [
                        const Text(
                          'Fresh Dairy, Delivered to Your Door',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSizes.p12),
                        const Text(
                          'Enjoy your favourite Sawariya Dairy products from the '
                          'comfort of your home.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSizes.p20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ref
                                .read(navigationProvider.notifier)
                                .setIndex(1);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.p32,
                              vertical: AppSizes.p14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Start Shopping',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.p24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
