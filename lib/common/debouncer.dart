import 'dart:async';

/// A utility to debounce a generic [Function] by a given [Duration]
class Debouncer {
  Timer timer;
  final Duration duration;

  /// Creates a new [Debouncer] that will call a given function with a
  /// `duration` delay.
  Debouncer(this.duration);

  /// Executes a given `function` with a timed delay after cancelling any
  /// previously scheduled function for this [Debouncer]. This ensures that the
  /// function is never called more than once within the duration of this
  /// [Debouncer].
  call(void Function() function) {
    if (timer != null) {
      timer.cancel();
    }

    timer = Timer(duration, function);
  }
}
