import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Animation scheduling helper for RenderObject.
mixin RenderObjectAnimationMixin on RenderObject {
  double _progress = 0;
  int? _lastTimeStamp;

  double get progress => _progress;

  Duration get duration => const Duration(milliseconds: 200);

  AnimationStatus _animationStatus = AnimationStatus.completed;

  set animationStatus(AnimationStatus v) {
    if (_animationStatus != v) {
      markNeedsPaint();
    }
    _animationStatus = v;
  }

  set progress(double v) {
    _progress = v.clamp(0, 1);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    doPaint(context, offset);
    _scheduleAnimation();
  }

  void _scheduleAnimation() {
    //SchedulerBinding.instance.remo
    if (_animationStatus != AnimationStatus.completed) {
      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
        if (_lastTimeStamp != null) {
          double delta = (timeStamp.inMilliseconds - _lastTimeStamp!) /
              duration.inMilliseconds;
          //在特定情况下，可能在一帧中连续的往frameCallback中添加了多次，导致两次回调时间间隔为0，
          //这种情况下应该继续请求重绘。
          if (delta == 0) {
            markNeedsPaint();
            return;
          }
          if (_animationStatus == AnimationStatus.reverse) {
            delta = -delta;
          }

          _progress = _progress + delta;
          if (_progress >= 1 || _progress <= 0) {
            _animationStatus = AnimationStatus.completed;
            _progress = _progress.clamp(0, 1);
          }
        }
        markNeedsPaint();
        _lastTimeStamp = timeStamp.inMilliseconds;
      });
    } else {
      _lastTimeStamp = null;
    }
  }

  // 子类实现绘制逻辑的地方
  void doPaint(PaintingContext context, Offset offset);
}
