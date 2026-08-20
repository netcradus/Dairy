import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';
import '../models/category.dart';

/// Fetches dairy products, categories, and prices from Cloud Firestore.
///
/// Expected Firestore collections:
///   products/{productId}   -> Product.toFirestore()
///   categories/{categoryId} -> Category.toFirestore()
class FirestoreProductRepository {
  final FirebaseFirestore _firestore;

  FirestoreProductRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  /// Real-time stream of all products.
  Stream<List<Product>> streamProducts() {
    return _products.snapshots().map((snap) =>
        snap.docs.map((d) => Product.fromFirestore(d.data(), d.id)).toList());
  }

  /// Real-time stream of all categories.
  Stream<List<Category>> streamCategories() {
    return _categories.snapshots().map((snap) =>
        snap.docs.map((d) => Category.fromFirestore(d.data(), d.id)).toList());
  }

  /// One-time fetch of all products (useful with a [FutureBuilder]).
  Future<List<Product>> fetchProducts() async {
    final snap = await _products.get();
    return snap.docs.map((d) => Product.fromFirestore(d.data(), d.id)).toList();
  }

  /// One-time fetch of all categories (useful with a [FutureBuilder]).
  Future<List<Category>> fetchCategories() async {
    final snap = await _categories.get();
    return snap.docs.map((d) => Category.fromFirestore(d.data(), d.id)).toList();
  }

  /// Writes (or overwrites) a product document.
  Future<void> setProduct(Product product) =>
      _products.doc(product.id).set(product.toFirestore());

  /// Writes (or overwrites) a category document.
  Future<void> setCategory(Category category) =>
      _categories.doc(category.id).set(category.toFirestore());
}
