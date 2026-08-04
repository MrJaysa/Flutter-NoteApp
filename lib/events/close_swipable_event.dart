import 'dart:async';

class CloseSwipeableEventBus {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void emit() {
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

final closeSwipeableEventBus = CloseSwipeableEventBus();
