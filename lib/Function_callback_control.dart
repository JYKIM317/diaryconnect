import 'dart:async';

class Throttle {
  Duration delay;
  Timer? throttleTimer;

  Throttle({required this.delay});

  void run(Function callback) {
    if (throttleTimer == null || !throttleTimer!.isActive) {
      throttleTimer = Timer(delay, () {
        callback();
      });
    }
  }
}

class Debounce {
  Duration delay;
  Timer? debounceTimer;

  Debounce({required this.delay});

  void run(Function callback) {
    if (debounceTimer != null && debounceTimer!.isActive) {
      debounceTimer!.cancel();
    }

    debounceTimer = Timer(delay, () {
      callback();
    });
  }
}
