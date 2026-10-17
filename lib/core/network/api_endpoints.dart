/// Centralized API endpoint constants for the DummyJSON REST API.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = 'https://dummyjson.com';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Auth
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';

  // Products
  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/categories';
  static const String categoryList = '/products/category-list';

  static String productById(int id) => '/products/$id';
  static String productsByCategory(String slug) => '/products/category/$slug';

  // Cart
  static const String addCart = '/carts/add';
  static String userCarts(int userId) => '/carts/user/$userId';

  // Error simulation endpoints (as specified in assignment)
  static const String simulate500 = '/http/500';
  static const String simulate404 = '/http/404';
  static const String nonExistentProduct = '/products/9999';
}
