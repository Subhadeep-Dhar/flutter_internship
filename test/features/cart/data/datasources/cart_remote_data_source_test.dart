import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:shopsphere/features/cart/data/models/cart_item_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('CartRemoteDataSourceImpl Tests', () {
    late MockDio mockDio;
    late CartRemoteDataSourceImpl dataSource;

    setUp(() {
      mockDio = MockDio();
      dataSource = CartRemoteDataSourceImpl(mockDio);
    });

    test(
      'checkout posts payload to /carts/add and returns CheckoutResultModel',
      () async {
        const item = CartItemModel(
          productId: 144,
          title: 'Cricket Helmet',
          price: 9.99,
          thumbnail: '',
          quantity: 2,
        );

        final responsePayload = <String, dynamic>{
          'id': 51,
          'total': 19.98,
          'discountedTotal': 17.98,
          'userId': 5,
          'totalProducts': 1,
          'totalQuantity': 2,
        };

        when(
          () => mockDio.post(
            ApiEndpoints.addCart,
            data: {
              'userId': 5,
              'products': [
                {'id': 144, 'quantity': 2},
              ],
            },
          ),
        ).thenAnswer(
          (_) async => Response(
            data: responsePayload,
            statusCode: 201,
            requestOptions: RequestOptions(path: ApiEndpoints.addCart),
          ),
        );

        final result = await dataSource.checkout(userId: 5, items: [item]);

        expect(result.id, 51);
        expect(result.total, 19.98);
        expect(result.discountedTotal, 17.98);
        expect(result.totalQuantity, 2);
        expect(result.userId, 5);

        verify(
          () => mockDio.post(
            ApiEndpoints.addCart,
            data: {
              'userId': 5,
              'products': [
                {'id': 144, 'quantity': 2},
              ],
            },
          ),
        ).called(1);
      },
    );

    test('checkout throws DioException when server fails', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.addCart),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ApiEndpoints.addCart),
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        () => dataSource.checkout(
          userId: 1,
          items: [
            const CartItemModel(
              productId: 1,
              title: 'Product',
              price: 10.0,
              thumbnail: '',
            ),
          ],
        ),
        throwsA(isA<DioException>()),
      );
    });
  });
}
