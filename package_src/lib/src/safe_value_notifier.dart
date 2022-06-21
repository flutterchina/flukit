import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Make sure notifying is safe during build/layout/paint phase.
///
/// When notifying, [ValueListenableBuilder] will call `setState`
/// to rebuild its child tree. However, as we known, `setState`
/// shouldn't be called during build/layout/paint phase since it
/// may cause loop call, so flutter will throw errors when detecting
/// that case. [SafeValueNotifier] can resolve this problem by delaying
/// to call `setState` during build/layout/paint phase.
class SafeValueNotifier<T> extends ValueNotifier<T> {
  SafeValueNotifier(T value) : super(value);

  @override
  void notifyListeners() {
    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
    // build/layout/paint are performed in persistentCallbacks.
    if (schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        super.notifyListeners();
      });
    } else {
      super.notifyListeners();
    }
  }

  void notifyListenersUnsafe() {
    super.notifyListeners();
  }
}
