import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('executes action only after specified delay has elapsed', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      var executionCount = 0;

      debouncer.run(() => executionCount++);
      expect(executionCount, 0);
      expect(debouncer.isRunning, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 70));

      expect(executionCount, 1);
      expect(debouncer.isRunning, isFalse);
    });

    test(
      'cancels previous pending execution when run is invoked rapidly',
      () async {
        final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
        var latestValue = '';

        debouncer.run(() => latestValue = 'first');
        await Future<void>.delayed(const Duration(milliseconds: 20));

        debouncer.run(() => latestValue = 'second');
        await Future<void>.delayed(const Duration(milliseconds: 20));

        debouncer.run(() => latestValue = 'third');
        await Future<void>.delayed(const Duration(milliseconds: 70));

        expect(latestValue, 'third');
      },
    );

    test('cancel aborts pending timer without executing action', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      var executed = false;

      debouncer.run(() => executed = true);
      debouncer.cancel();

      await Future<void>.delayed(const Duration(milliseconds: 70));

      expect(executed, isFalse);
      expect(debouncer.isRunning, isFalse);
    });
  });
}
