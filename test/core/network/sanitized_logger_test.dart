import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/network/sanitized_logger_interceptor.dart';

void main() {
  group('SanitizedLoggerInterceptor', () {
    const interceptor = SanitizedLoggerInterceptor(isEnabled: false);

    test('redacts sensitive auth fields from request/response maps', () {
      final input = {
        'username': 'emilys',
        'password': 'secret_password_123',
        'token': 'jwt_access_token_xyz',
        'refreshToken': 'jwt_refresh_token_abc',
        'cart': {'id': 1, 'total': 59.99, 'secret': 'nested_secret'},
      };

      final sanitized =
          interceptor.sanitizeForTesting(input) as Map<String, dynamic>;

      expect(sanitized['username'], 'emilys');
      expect(sanitized['password'], '[REDACTED]');
      expect(sanitized['token'], '[REDACTED]');
      expect(sanitized['refreshToken'], '[REDACTED]');

      final nestedCart = sanitized['cart'] as Map<String, dynamic>;
      expect(nestedCart['id'], 1);
      expect(nestedCart['total'], 59.99);
      expect(nestedCart['secret'], '[REDACTED]');
    });

    test('redacts Authorization headers with Bearer prefix intact', () {
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer confidential_access_token_token',
      };

      final sanitized =
          interceptor.sanitizeForTesting(headers) as Map<String, dynamic>;

      expect(sanitized['Accept'], 'application/json');
      expect(sanitized['Authorization'], 'Bearer [REDACTED]');
    });

    test('preserves harmless non-sensitive lists and primitive structures', () {
      final list = ['electronics', 'groceries', 42, true];
      final sanitized = interceptor.sanitizeForTesting(list);

      expect(sanitized, list);
    });
  });
}
