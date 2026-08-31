/// Sawariya Dairy Asset Paths
abstract class AppAssets {
  static const String imagePath = 'assets/images';
  static const String logoPath = '$imagePath/logo';
  static const String productPath = '$imagePath/products';
  static const String categoryPath = '$imagePath/categories';
  static const String bannerPath = '$imagePath/banners';
  static const String iconPath = '$imagePath/icons';

  static const String landingHeroMilk = '$imagePath/landing_hero_milk.jpg';
  static const String landingHeroProducts =
      '$imagePath/landing_hero_products.jpg';
  static const String landingHeroScooter =
      '$imagePath/landing_hero_scooter.jpg';
  static const String landingBgMeadow = '$imagePath/landing_bg_meadow.jpg';
  static const String landingBg = '$imagePath/landing.jpg';
  static const String loginHeroCow = '$imagePath/login_hero_cow.jpg';
  static const String dairyMascot = '$imagePath/dairy_mascot.jpg';
  static const String sawariyaLogo = '$imagePath/sawariya_logo.png';
  static const String milkBottle = '$productPath/sawariya_milk_bottle.jpg';
  static const String lassiBottle = '$productPath/sawariya_lassi_bottle.jpg';

  // PNG product images for hero / banner use
  static const String milkPng = '$imagePath/nnd.png';
  static const String lassiPng = '$imagePath/nnl.png';
  static const String gheePng = '$imagePath/nng.png';
  static const String paneerPng = '$imagePath/nnp.png';
  static const String makhanPng = '$imagePath/nnm.png';
  static const String uplePng = '$imagePath/uple.png';
  static const String waterPng = '$imagePath/water.png';

  // PNG category images (Home / Shop category cards)
  static const String milkCategory = '$imagePath/doodh.png';
  static const String gheeCategory = '$imagePath/gh.png';
  static const String lassiCategory = '$imagePath/las.png';
  static const String makhanCategory = '$imagePath/mak.png';
  static const String paneerCategory = '$imagePath/pan.png';
  static const String upleCategory = '$imagePath/u3.png';
  static const String waterCategory = '$imagePath/w3.png';

  // Placeholder URLs for remote network fallback images
  static const String milkPlaceholder =
      'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=600&q=80';
  static const String curdPlaceholder =
      'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=600&q=80';
  static const String paneerPlaceholder =
      'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=600&q=80';
  static const String gheePlaceholder =
      'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=600&q=80';
  static const String heroBannerPlaceholder =
      'https://images.unsplash.com/photo-1527153857715-3908f2bae5e8?auto=format&fit=crop&w=1200&q=80';
  static const String a2BannerPlaceholder =
      'https://images.unsplash.com/photo-1500595046743-cd271d694d30?auto=format&fit=crop&w=1200&q=80';

  // ─── Image resolution helpers ──────────────────────────────────────────────
  // Category cards pick a default from the category mapping; product cards pick
  // a default from the product mapping. Network URLs and valid local asset paths
  // are returned untouched so nothing valid is ever overwritten.

  /// Default local asset for each category (category card thumbnails).
  static const Map<String, String> _categoryDefaultByKey = {
    'cat_milk': milkCategory,
    'cat_ghee': gheeCategory,
    'cat_lassi': lassiCategory,
    'cat_makhan': makhanCategory,
    'cat_paneer': paneerCategory,
    'cat_uple': upleCategory,
    'cat_water': waterCategory,
  };

  /// Default local asset for the products that belong to each category.
  static const Map<String, String> _productDefaultByKey = {
    'cat_milk': milkPng,
    'cat_ghee': gheePng,
    'cat_lassi': lassiPng,
    'cat_makhan': makhanPng,
    'cat_paneer': paneerPng,
    'cat_uple': uplePng,
    'cat_water': waterPng,
  };

  /// Every known-valid local asset path (supports obsolete-path detection).
  static const Set<String> _validAssetPaths = {
    '$imagePath/all.png',
    milkCategory,
    gheeCategory,
    lassiCategory,
    makhanCategory,
    paneerCategory,
    upleCategory,
    waterCategory,
    milkPng,
    gheePng,
    lassiPng,
    makhanPng,
    paneerPng,
    uplePng,
    waterPng,
  };

  static bool _isNetwork(String? url) =>
      url != null && (url.startsWith('http://') || url.startsWith('https://'));

  static bool _isAsset(String? url) =>
      url != null &&
      url.startsWith('assets/') &&
      _validAssetPaths.contains(url);

  static String? _fallbackDefault(
      Map<String, String> defaults, String? categoryKey) {
    if (categoryKey == null) return null;
    final key = categoryKey.toLowerCase();
    for (final entry in defaults.entries) {
      if (entry.key == categoryKey || entry.key == key) {
        return entry.value;
      }
    }
    for (final entry in defaults.entries) {
      final defaultKey = entry.key.replaceFirst('cat_', '').toLowerCase();
      if (key == defaultKey ||
          key.contains(defaultKey) ||
          defaultKey.contains(key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Resolves which image source to use for a category thumbnail.
  static String? categoryImage({String? imageUrl, String? categoryKey}) {
    if (_isNetwork(imageUrl) || _isAsset(imageUrl)) return imageUrl;
    return _fallbackDefault(_categoryDefaultByKey, categoryKey);
  }

  /// Resolves which image source to use for a product thumbnail.
  static String? productImage({String? imageUrl, String? categoryKey}) {
    if (_isNetwork(imageUrl) || _isAsset(imageUrl)) return imageUrl;
    return _fallbackDefault(_productDefaultByKey, categoryKey);
  }
}
