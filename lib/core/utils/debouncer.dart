import 'dart:async';

/// Pure Dart debouncer to delay execution of actions such as search queries.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 400)});

  /// Runs the [action] after [delay]. If called again before [delay] has elapsed,
  /// the previous timer is cancelled.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any currently pending debounced action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether an action is currently waiting to execute.
  bool get isRunning => _timer?.isActive ?? false;

  void dispose() {
    cancel();
  }
}
