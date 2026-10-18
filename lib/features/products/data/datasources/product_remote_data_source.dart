import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/product_page_response_model.dart';

/// Contract for remote product catalogue network requests.
abstract interface class ProductRemoteDataSource {
  /// Calls `GET /products` with pagination and optional sort parameters.
  Future<ProductPageResponseModel> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  });

  /// Calls `GET /products/search` with query, pagination, and optional sort parameters.
  Future<ProductPageResponseModel> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  });

  /// Calls `GET /products/category/{category}` with pagination and optional sort parameters.
  Future<ProductPageResponseModel> getProductsByCategory({
    required String category,
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  });

  /// Calls `GET /products/categories` to retrieve available product categories.
  Future<List<CategoryModel>> getCategories();

  /// Calls `GET /products/{id}` to fetch a single product's details.
  Future<ProductModel> getProductById(int id);
}

/// Concrete implementation of [ProductRemoteDataSource] using [Dio].
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  const ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<ProductPageResponseModel> getProducts({
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'skip': skip,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (order != null && order.isNotEmpty) 'order': order,
    };

    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.products,
      queryParameters: queryParams,
    );

    return ProductPageResponseModel.fromJson(response.data ?? {});
  }

  @override
  Future<ProductPageResponseModel> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query,
      'limit': limit,
      'skip': skip,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (order != null && order.isNotEmpty) 'order': order,
    };

    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.searchProducts,
      queryParameters: queryParams,
    );

    return ProductPageResponseModel.fromJson(response.data ?? {});
  }

  @override
  Future<ProductPageResponseModel> getProductsByCategory({
    required String category,
    int limit = 20,
    int skip = 0,
    String? sortBy,
    String? order,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'skip': skip,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (order != null && order.isNotEmpty) 'order': order,
    };

    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.productsByCategory(category),
      queryParameters: queryParams,
    );

    return ProductPageResponseModel.fromJson(response.data ?? {});
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dio.get<dynamic>(ApiEndpoints.categories);

    final data = response.data;
    if (data is List) {
      return data.map((item) => CategoryModel.fromJson(item)).toList();
    }
    return const [];
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiEndpoints.productById(id),
    );

    return ProductModel.fromJson(response.data ?? {});
  }
}
