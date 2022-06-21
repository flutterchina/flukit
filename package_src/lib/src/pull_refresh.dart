import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide RefreshCallback;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'sliver_flexible_header.dart';

/// A widget provides pull refresh scope. Typically, the child is a [CustomScrollView].
class PullRefreshScope extends StatefulWidget {
  const PullRefreshScope({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  State<PullRefreshScope> createState() => _PullRefreshScopeState();
}

class _PullRefreshScopeState extends State<PullRefreshScope> {
  // set by SliverPullRefreshIndicator
  ValueChanged<bool>? _pointerStateSetter;

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: widget.child,
      onPointerDown: (e) => _pointerStateSetter?.call(false),
      onPointerUp: (e) => _pointerStateSetter?.call(true),
    );
  }
}

/// A indicator for PullRefreshScope.
class SliverPullRefreshIndicator extends StatefulWidget {
  /// Create a new refresh indicator for inserting into a list of slivers.
  ///
  /// The [refreshTriggerPullDistance] and [refreshIndicatorExtent] arguments
  /// must not be null and must be >= 0.
  ///
  /// The [builder] argument may be null, in which case no indicator UI will be
  /// shown but the [onRefresh] will still be invoked. By default, [builder]
  /// shows a [CircularProgressIndicator].
  ///
  /// The [onRefresh] argument will be called when pulled far enough to trigger
  /// a refresh.
  const SliverPullRefreshIndicator({
    Key? key,
    this.refreshTriggerPullDistance = 100,
    this.refreshIndicatorExtent = 60,
    this.duration = const Duration(milliseconds: 200),
    this.builder = buildRefreshIndicator,
    this.onRefresh,
  })  : assert(refreshTriggerPullDistance > 0.0),
        assert(refreshIndicatorExtent >= 0.0),
        assert(
          refreshTriggerPullDistance >= refreshIndicatorExtent,
          'The refresh indicator cannot take more space in its final state '
          'than the amount initially created by overscrolling.',
        ),
        super(key: key);

  /// duration for up to header
  final Duration duration;

  /// The amount of overscroll the scrollable must be dragged to trigger a reload.
  ///
  /// Must not be null, must be larger than 0.0 and larger than
  /// [refreshIndicatorExtent]. Defaults to 100px when not specified.
  ///
  /// When overscrolled past this distance and **pointer up** , [onRefresh] will be called
  /// if not null and the [builder] will build in the [RefreshIndicatorMode.refresh] state.
  final double refreshTriggerPullDistance;

  /// The amount of space the refresh indicator sliver will keep holding while
  /// [onRefresh]'s [Future] is still running.
  ///
  /// Must not be null and must be positive, but can be 0.0, in which case the
  /// sliver will start retracting back to 0.0 as soon as the refresh is started.
  /// Defaults to 60px when not specified.
  ///
  /// Must be smaller than [refreshTriggerPullDistance], since the sliver
  /// shouldn't grow further after triggering the refresh.
  final double refreshIndicatorExtent;

  /// A builder that's called as this sliver's size changes, and as the state
  /// changes.
  ///
  /// Can be set to null, in which case nothing will be drawn in the overscrolled
  /// space.
  ///
  /// Will not be called when the available space is zero such as before any
  /// overscroll.
  final RefreshControlIndicatorBuilder? builder;

  /// Callback invoked when pulled by [refreshTriggerPullDistance].
  ///
  /// If provided, must return a [Future] which will keep the indicator in the
  /// [RefreshIndicatorMode.refresh] state until the [Future] completes.
  ///
  /// Can be null, in which case a single frame of [RefreshIndicatorMode.armed]
  /// state will be drawn before going immediately to the [RefreshIndicatorMode.done]
  /// where the sliver will start retracting.
  final RefreshCallback? onRefresh;

  static Widget buildRefreshIndicator(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    Widget widget;
    double width = min(22, pulledExtent);
    if (refreshState == RefreshIndicatorMode.refresh) {
      widget = SizedBox(
        child: const CircularProgressIndicator(strokeWidth: 2),
        width: width,
        height: width,
      );
    } else {
      widget = Transform.rotate(
        angle: pulledExtent / 80 * 6.28,
        child: const CircularProgressIndicator(
          value: .85,
          strokeWidth: 2,
        ),
      );
    }
    return Center(
      child: SizedBox(
        width: width,
        height: width,
        child: Padding(padding: const EdgeInsets.all(2.0), child: widget),
      ),
    );
  }

  @override
  SliverPullRefreshIndicatorState createState() =>
      SliverPullRefreshIndicatorState();
}

class SliverPullRefreshIndicatorState
    extends State<SliverPullRefreshIndicator> {
  double _height = 0;
  late RefreshIndicatorMode refreshState;
  bool _refreshing = false;
  bool _pointerUp = false;
  bool _needAnimate = false;
  bool _visible = true;
  bool _done = false;

  @override
  void initState() {
    refreshState = RefreshIndicatorMode.inactive;
    var state = context.findAncestorStateOfType<_PullRefreshScopeState>();
    assert(
      state != null,
      'PullRefreshBox missed for SliverPullRefreshIndicator',
    );
    state!._pointerStateSetter = (bool value) {
      _pointerUp = value;
      if (_pointerUp && _needAnimate) {
        _needAnimate = false;
        goBack();
      }
    };
    super.initState();
  }

  double get _visibleExtent => _height;

  set _visibleExtent(double value) {
    if (value == _height) return;
    _height = value;
    // build/layout 过程中不能调用 setState
    SchedulerBinding.instance.addPostFrameCallback((_) => setState(() => {}));
  }

  void goBack() {
    _done = true;
    if (!mounted) return;
    if (!_visible) {
      _refreshing = false;
      return;
    }
    if (!_pointerUp) {
      // 手指还在屏幕上延迟执行动画
      setState(() {
        _needAnimate = true;
      });
      return;
    }
    _refreshing = false;
    _visibleExtent = 0;
  }

  @override
  Widget build(BuildContext context) {
    return SliverFlexibleHeader(
      visibleExtent: _visibleExtent,
      builder: (_, double availableExtent, ScrollDirection direction) {
        _visible = availableExtent > 0;
        if (!_visible) {
          refreshState = RefreshIndicatorMode.inactive;
          _visibleExtent = 0;
          _done = false;
        } else {
          if (direction == ScrollDirection.reverse &&
              !_refreshing &&
              _pointerUp &&
              availableExtent > widget.refreshTriggerPullDistance) {
            _refreshing = true;
            _visibleExtent = widget.refreshIndicatorExtent;
            widget.onRefresh?.call().whenComplete(goBack);
          }
          if (_refreshing) {
            refreshState = RefreshIndicatorMode.refresh;
          } else if (_done) {
            refreshState = RefreshIndicatorMode.done;
          } else if (availableExtent > widget.refreshTriggerPullDistance) {
            refreshState = RefreshIndicatorMode.armed;
          } else {
            refreshState = RefreshIndicatorMode.drag;
          }
        }
        return (widget.builder ??
            SliverPullRefreshIndicator.buildRefreshIndicator)(
          context,
          refreshState,
          availableExtent,
          widget.refreshTriggerPullDistance,
          widget.refreshIndicatorExtent,
        );
      },
    );
  }
}
