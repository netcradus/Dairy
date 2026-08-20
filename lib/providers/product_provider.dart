import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/banner_item.dart';
import '../repositories/product_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/firestore_product_repository.dart';

export 'cart_provider.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

/// Provides the Cloud Firestore-backed product/category repository.
final firestoreProductRepoProvider = Provider<FirestoreProductRepository>((ref) {
  return FirestoreProductRepository();
});

final heroBannersProvider = Provider<List<BannerItem>>((ref) {
  return ref.watch(productRepositoryProvider).getHeroBanners();
});

final categoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).getCategories();
});

final freshDealsProvider = Provider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getFreshDeals();
});

final a2ProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getA2MilkProducts();
});

final bestSellersProvider = Provider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getBestSellers();
});

final allProductsProvider = Provider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  final fresh = repo.getFreshDeals();
  final a2 = repo.getA2MilkProducts();
  final best = repo.getBestSellers();

  final Map<String, Product> productMap = {};
  for (final p in [...fresh, ...a2, ...best]) {
    productMap[p.id] = p;
  }
  return productMap.values.toList();
});
