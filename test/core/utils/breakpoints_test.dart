import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/utils/breakpoints.dart';

void main() {
  group('Breakpoints', () {
    test('categorizes width < 600 as compact', () {
      expect(Breakpoints.fromWidth(360), ScreenType.compact);
      expect(Breakpoints.fromWidth(599), ScreenType.compact);
    });

    test('categorizes width 600..1024 as medium', () {
      expect(Breakpoints.fromWidth(600), ScreenType.medium);
      expect(Breakpoints.fromWidth(800), ScreenType.medium);
      expect(Breakpoints.fromWidth(1024), ScreenType.medium);
    });

    test('categorizes width > 1024 as expanded', () {
      expect(Breakpoints.fromWidth(1025), ScreenType.expanded);
      expect(Breakpoints.fromWidth(1440), ScreenType.expanded);
    });

    test('calculates responsive column count according to viewport width', () {
      expect(Breakpoints.gridColumnCount(320), 1);
      expect(Breakpoints.gridColumnCount(420), 2);
      expect(Breakpoints.gridColumnCount(720), 3);
      expect(Breakpoints.gridColumnCount(900), 4);
      expect(Breakpoints.gridColumnCount(1200), 5);
    });
  });
}
