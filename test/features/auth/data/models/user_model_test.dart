import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';
import 'package:shopsphere/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    final fullJson = {
      'id': 1,
      'username': 'emilys',
      'email': 'emily.johnson@x.dummyjson.com',
      'firstName': 'Emily',
      'lastName': 'Johnson',
      'gender': 'female',
      'image': 'https://dummyjson.com/icon/emilys/128',
      'phone': '+81 965-431-3024',
    };

    test('is a subtype of User entity', () {
      final model = UserModel.fromJson(fullJson);
      expect(model, isA<User>());
    });

    test('fromJson parses complete payload correctly', () {
      final model = UserModel.fromJson(fullJson);

      expect(model.id, 1);
      expect(model.username, 'emilys');
      expect(model.email, 'emily.johnson@x.dummyjson.com');
      expect(model.firstName, 'Emily');
      expect(model.lastName, 'Johnson');
      expect(model.fullName, 'Emily Johnson');
      expect(model.initials, 'EJ');
      expect(model.gender, 'female');
      expect(model.image, 'https://dummyjson.com/icon/emilys/128');
      expect(model.phone, '+81 965-431-3024');
    });

    test('fromJson handles null or missing optional fields defensively', () {
      final minimalJson = {
        'id': 2,
        'username': 'alex',
        'email': 'alex@example.com',
        'firstName': 'Alex',
        'lastName': '',
      };

      final model = UserModel.fromJson(minimalJson);

      expect(model.id, 2);
      expect(model.username, 'alex');
      expect(model.fullName, 'Alex');
      expect(model.initials, 'A');
      expect(model.gender, isNull);
      expect(model.image, isNull);
      expect(model.phone, isNull);
    });

    test('toJson serializes correctly', () {
      final model = UserModel.fromJson(fullJson);
      final json = model.toJson();

      expect(json['id'], 1);
      expect(json['username'], 'emilys');
      expect(json['firstName'], 'Emily');
      expect(json['phone'], '+81 965-431-3024');
    });
  });
}
