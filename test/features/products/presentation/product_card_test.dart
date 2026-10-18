import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/features/products/domain/entities/product.dart';
import 'package:shopsphere/features/products/presentation/widgets/product_card.dart';

void main() {
  group('ProductCard Widget Tests', () {
    const tProduct = Product(
      id: 42,
      title: 'Essence Mascara Lash Princess Full Packaging',
      description: 'Popular lengthening mascara',
      category: 'beauty',
      price: 19.99,
      discountPercentage: 15.0,
      rating: 4.8,
      stock: 5,
      thumbnail: 'https://dummyjson.com/image/mascara.png',
      availabilityStatus: 'Low Stock',
      brand: 'Essence',
    );

    const tOutOfStockProduct = Product(
      id: 43,
      title: 'Sold Out Perfume Oil',
      description: 'Fragrance oil',
      category: 'fragrances',
      price: 29.99,
      discountPercentage: 0,
      rating: 4.2,
      stock: 0,
      thumbnail: 'https://dummyjson.com/image/perfume.png',
      availabilityStatus: 'Out of Stock',
    );

    testWidgets(
      'thumbnail uses BoxFit.contain to preserve full product imagery without cropping',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: SizedBox(width: 200, child: ProductCard(product: tProduct)),
            ),
          ),
        );

        final imageFinder = find.byType(CachedNetworkImage);
        expect(imageFinder, findsOneWidget);

        final cachedImage = tester.widget<CachedNetworkImage>(imageFinder);
        expect(cachedImage.fit, BoxFit.contain);
      },
    );

    testWidgets('renders discount badge and low stock pill correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SizedBox(width: 200, child: ProductCard(product: tProduct)),
          ),
        ),
      );

      expect(find.text('-15%'), findsOneWidget);
      expect(find.text('Low Stock'), findsOneWidget);
      expect(find.text('BEAUTY'), findsOneWidget);
    });

    testWidgets('renders out of stock label for products with zero inventory', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SizedBox(
              width: 200,
              child: ProductCard(product: tOutOfStockProduct),
            ),
          ),
        ),
      );

      expect(find.text('Out of Stock'), findsOneWidget);
      expect(find.text('-0%'), findsNothing); // No discount badge
    });

    testWidgets(
      'renders without RenderFlex overflow when text scaling is 1.3x',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.3),
              size: Size(360, 640),
            ),
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const Scaffold(
                body: SizedBox(
                  width: 170,
                  height: 310,
                  child: ProductCard(product: tProduct),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text(tProduct.title), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('tapping ProductCard invokes onTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: ProductCard(product: tProduct, onTap: () => tapped = true),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ProductCard));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
