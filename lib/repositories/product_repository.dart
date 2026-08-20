import '../models/product.dart';
import '../models/banner_item.dart';
import '../core/constants/app_assets.dart';

class ProductRepository {
  List<BannerItem> getHeroBanners() {
    return const [
      BannerItem(
        id: 'b1',
        title: 'Pure A2 Gir Cow Milk',
        subtitle: '100% Farm Fresh Delivered Daily To Your Doorstep',
        tag: 'PURE & NATURAL',
        buttonText: 'Subscribe Now',
        imageUrl: AppAssets.heroBannerPlaceholder,
      ),
      BannerItem(
        id: 'b2',
        title: 'Fresh Malai Paneer & Butter',
        subtitle: 'Soft, Organic & Hygienically Packed Every Morning',
        tag: 'SPECIAL OFFER',
        buttonText: 'Order Fresh',
        imageUrl: AppAssets.paneerPlaceholder,
      ),
      BannerItem(
        id: 'b3',
        title: 'Bilona Desi Ghee — 10% Off',
        subtitle: 'Traditional hand-churned ghee, rich aroma & golden texture',
        tag: 'LIMITED DEAL',
        buttonText: 'Get Offer',
        imageUrl: AppAssets.gheePlaceholder,
      ),
    ];
  }

  List<Product> getFreshDeals() {
    return const [
      Product(
        id: 'p2',
        title: 'Sawariya Pure Desi Ghee',
        categoryId: 'cat_ghee',
        categoryName: 'Pure Ghee',
        price: 650.0,
        originalPrice: 720.0,
        unit: '1 L',
        imageUrl: AppAssets.gheePlaceholder,
        description: 'Traditional bilona method pure cow ghee with rich granular texture and aroma.',
        rating: 5.0,
        reviewCount: 512,
        isFreshDeal: true,
        isBestSeller: true,
      ),
      Product(
        id: 'p3',
        title: 'Sawariya Fresh Malai Paneer',
        categoryId: 'cat_paneer',
        categoryName: 'Paneer & Butter',
        price: 95.0,
        originalPrice: 110.0,
        unit: '200 g',
        imageUrl: AppAssets.paneerPlaceholder,
        description: 'Ultra-soft, protein-rich fresh cottage cheese prepared daily.',
        rating: 4.8,
        reviewCount: 210,
        isFreshDeal: true,
        isBestSeller: false,
      ),
      Product(
        id: 'p4',
        title: 'Sawariya Fresh Sweet Dahi',
        categoryId: 'cat_curd',
        categoryName: 'Curd & Lassi',
        price: 45.0,
        originalPrice: 50.0,
        unit: '400 g',
        imageUrl: AppAssets.curdPlaceholder,
        description: 'Thick, creamy set curd prepared naturally without preservatives.',
        rating: 4.7,
        reviewCount: 180,
        isFreshDeal: true,
      ),
    ];
  }

  List<Product> getA2MilkProducts() {
    return const [
      Product(
        id: 'p5',
        title: 'Sawariya Milk',
        categoryId: 'cat_milk',
        categoryName: 'Fresh Milk',
        price: 45.0,
        originalPrice: 50.0,
        unit: '500 ml',
        imageUrl: AppAssets.milkPng,
        description: 'Pure A2 protein cow milk from indigenous Indian Gir cows.',
        rating: 5.0,
        reviewCount: 620,
        isA2CowMilk: true,
        isBestSeller: true,
      ),
    ];
  }

  List<Product> getBestSellers() {
    return const [
      Product(
        id: 'p2',
        title: 'Sawariya Pure Desi Ghee',
        categoryId: 'cat_ghee',
        categoryName: 'Pure Ghee',
        price: 650.0,
        originalPrice: 720.0,
        unit: '1 L',
        imageUrl: AppAssets.gheePlaceholder,
        rating: 5.0,
        reviewCount: 512,
        isBestSeller: true,
      ),
      Product(
        id: 'p7',
        title: 'Sawariya Thick Creamy Lassi',
        categoryId: 'cat_curd',
        categoryName: 'Curd & Lassi',
        price: 30.0,
        originalPrice: 35.0,
        unit: '300 ml',
        imageUrl: AppAssets.lassiPng,
        rating: 4.8,
        reviewCount: 195,
        isBestSeller: true,
      ),
      Product(
        id: 'p8',
        title: 'Sawariya Table Butter (Unsalted)',
        categoryId: 'cat_paneer',
        categoryName: 'Paneer & Butter',
        price: 60.0,
        originalPrice: 65.0,
        unit: '100 g',
        imageUrl: AppAssets.paneerPlaceholder,
        rating: 4.7,
        reviewCount: 140,
        isBestSeller: true,
      ),
    ];
  }
}
