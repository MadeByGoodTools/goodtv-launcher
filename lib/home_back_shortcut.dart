import 'dart:async';

/// Receives Back presses only after the home route has handled navigation.
/// The first press waits briefly so it cannot exit Home before a second press.
class HomeBackShortcut {
  final void Function() onSingle;
  final void Function() onDouble;
  final Duration interval;
  Timer? _pending;

  HomeBackShortcut({
    required this.onSingle,
    required this.onDouble,
    this.interval = const Duration(milliseconds: 400),
  });

  void press() {
    if (_pending?.isActive ?? false) {
      cancel();
      onDouble();
    } else {
      _pending = Timer(interval, () {
        _pending = null;
        onSingle();
      });
    }
  }

  void cancel() {
    _pending?.cancel();
    _pending = null;
  }
}
