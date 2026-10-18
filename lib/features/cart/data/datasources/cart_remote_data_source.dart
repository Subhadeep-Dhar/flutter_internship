import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/cart_item_model.dart';
import '../models/checkout_result_model.dart';

/// Contract for remote cart network operations.
abstract class CartRemoteDataSource {
  /// Submits the cart items to DummyJSON to simulate order checkout.
  Future<CheckoutResultModel> checkout({
    required int userId,
    required List<CartItemModel> items,
  });
}

/// Implementation of [CartRemoteDataSource] using [Dio].
class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio _dio;

  const CartRemoteDataSourceImpl(this._dio);

  @override
  Future<CheckoutResultModel> checkout({
    required int userId,
    required List<CartItemModel> items,
  }) async {
    final payload = {
      'userId': userId,
      'products': items.map((item) {
        return {'id': item.productId, 'quantity': item.quantity};
      }).toList(),
    };

    final response = await _dio.post(ApiEndpoints.addCart, data: payload);

    return CheckoutResultModel.fromJson(response.data as Map<String, dynamic>);
  }
}
