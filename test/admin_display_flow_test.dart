import 'package:flutter_test/flutter_test.dart';
import 'package:dairy_app/models/product_model.dart';
import 'package:dairy_app/models/product.dart';
import 'package:dairy_app/core/constants/app_assets.dart';

void main() {
  group('Admin Display Flow Trace for prod_1788762789345', () {
    const testProductId = 'prod_1788762789345';
    const testDownloadUrl =
        'https://firebasestorage.googleapis.com/v0/b/dairy-app.appspot.com/o/products%2Fprod_1788762789345%2Fimage?alt=media&token=12345678-abcd';

    test('Step 1 & 2: Firestore raw document map containing imageUrl', () {
      final rawFirestoreDoc = {
        'id': testProductId,
        'title': 'Fresh Milk',
        'description': 'Pure Cow Milk',
        'categoryName': 'Milk',
        'unit': '1 Litre',
        'price': 65.0,
        'imageUrl': testDownloadUrl,
        'emoji': '🥛',
        'inStock': true,
      };

      expect(rawFirestoreDoc['imageUrl'], equals(testDownloadUrl));
    });

    test('Step 3: DairyProduct model receiving imageUrl', () {
      const product = DairyProduct(
        id: testProductId,
        name: 'Fresh Milk',
        subtitle: 'Pure Cow Milk',
        category: 'Milk',
        unit: '1 Litre',
        price: 65.0,
        imageUrl: testDownloadUrl,
      );

      expect(product.imageUrl, equals(testDownloadUrl));
      expect(product.resolvedImageUrl, equals(testDownloadUrl));
    });

    test('Step 4 & 5: AppAssets.productImage does NOT replace HTTPS URL', () {
      final resolved = AppAssets.productImage(
        imageUrl: testDownloadUrl,
        categoryKey: 'Milk',
      );

      expect(resolved, equals(testDownloadUrl));
      expect(resolved!.startsWith('https://'), isTrue);
      expect(resolved.startsWith('assets/'), isFalse);
    });

    test('Step 6: Product model from models/product.dart handles imageUrl', () {
      final p = Product.fromFirestore({
        'title': 'Fresh Milk',
        'categoryId': 'cat_milk',
        'categoryName': 'Milk',
        'price': 65.0,
        'unit': '1 Litre',
        'imageUrl': testDownloadUrl,
      }, testProductId);

      expect(p.imageUrl, equals(testDownloadUrl));
      expect(p.resolvedImageUrl, equals(testDownloadUrl));
    });

    test(
        'Step 7: Presets continue resolving to local assets when no network URL',
        () {
      for (final label in [
        'Milk',
        'Paneer',
        'Ghee',
        'Lassi',
        'Makhan',
        'Uple',
        'Water'
      ]) {
        final resolved = AppAssets.productImage(
          imageUrl: '',
          categoryKey: label,
        );
        expect(resolved, isNotNull, reason: 'Failed for $label');
        expect(resolved!.startsWith('assets/'), isTrue,
            reason: 'Failed for $label');
      }
    });

    test('Step 8: Bidirectional adapter preserves imageUrl without loss', () {
      const dp = DairyProduct(
        id: testProductId,
        name: 'Fresh Milk',
        subtitle: 'Pure Cow Milk',
        category: 'Milk',
        unit: '1 Litre',
        price: 65.0,
        imageUrl: testDownloadUrl,
      );

      final p = dp.toProduct();
      expect(p.id, equals(testProductId));
      expect(p.imageUrl, equals(testDownloadUrl));
      expect(p.resolvedImageUrl, equals(testDownloadUrl));

      final backToDp = DairyProduct.fromProduct(p);
      expect(backToDp.id, equals(testProductId));
      expect(backToDp.imageUrl, equals(testDownloadUrl));
      expect(backToDp.resolvedImageUrl, equals(testDownloadUrl));
    });

    test('Step 9: Resilient reading if field is "image" instead of "imageUrl"',
        () {
      final p = Product.fromFirestore({
        'title': 'Fresh Milk',
        'categoryId': 'cat_milk',
        'categoryName': 'Milk',
        'price': 65.0,
        'unit': '1 Litre',
        'image': testDownloadUrl,
      }, testProductId);

      expect(p.imageUrl, equals(testDownloadUrl));
      expect(p.resolvedImageUrl, equals(testDownloadUrl));
    });
  });
}
