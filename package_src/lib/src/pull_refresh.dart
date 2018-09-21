import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'animated_rotation_box.dart';

enum PullRefreshIndicatorMode {
  ///Pointer is down(over scroll)
  drag,

  /// Running the refresh callback.
  refresh,

  /// Animating the indicator's fade-out after refreshing.
  done,

  /// Animating the indicator's fade-out after not arming.
  canceled,
}

/// The signature for a function that's called when the user has dragged a
/// [PullRefreshBox] far enough to demonstrate that they want the app to
/// refresh. The returned [Future] must complete when the refresh operation is
/// finished.
///
/// Used by [PullRefreshBox.onRefresh].
typedef Future PullRefreshCallback();


/// [PullRefreshBox] header builder interface. If you want to custom indicator,
/// implement this interface.
///
/// See also:
///
///  * [DefaultPullRefreshIndicator], a default PullRefreshIndicator.
///
abstract class PullRefreshIndicator {

  /// Indicator height, you must specify the header height.
  @required double get height;

  Widget build(BuildContext context,
      PullRefreshIndicatorMode mode,
      double offset, //drag offset(over scroll)
      ScrollDirection direction);
}

/// This is a default PullRefreshIndicator.
class DefaultPullRefreshIndicator implements PullRefreshIndicator {
  DefaultPullRefreshIndicator({
    this.style = const TextStyle(color: Colors.grey),
    this.arrowColor = Colors.grey,
    this.loadingTip,
    this.pullTip,
    this.loosenTip,
    this.progressIndicator
  });

  final TextStyle style;
  final Color arrowColor;
  final String loadingTip;
  final String pullTip;
  final String loosenTip;
  ProgressIndicator progressIndicator;

  @override
  double get height => 100.0;

  @override
  Widget build(BuildContext context, PullRefreshIndicatorMode mode, offset,
      ScrollDirection direction) {
    if (mode == PullRefreshIndicatorMode.refresh) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          progressIndicator ?? SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(strokeWidth: 1.5,),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(loadingTip ?? "正在刷新...", style: style),
          )
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        AnimatedRotationBox(
          turns: offset > 100 ? 0.5 : .0,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.arrow_upward, color: Colors.grey,),
          ),
        ),
        Text(offset > 100 ? loosenTip ?? "松开刷新" : pullTip ?? "继续下拉",
            style: style)
      ],
    );
  }
}


/// A widget that supports "swipe to refresh" idiom.
///
/// When the child's [Scrollable] descendant overscrolls, an indicator is
/// faded into view. When the scroll ends, if the
/// indicator has been dragged far enough for it to become completely visible,
/// the [onRefresh] callback is called. The callback is expected to update the
/// scrollable's contents and then complete the [Future] it returns. The refresh
/// indicator disappears after the callback's [Future] has completed.
///
/// If the [Scrollable] might not have enough content to overscroll, consider
/// settings its `physics` property to [AlwaysScrollableScrollPhysics]:
///
/// ```dart
/// new ListView(
///   physics: const AlwaysScrollableScrollPhysics(),
///   children: ...
//  )
/// ```
///
/// Using [AlwaysScrollableScrollPhysics] will ensure that the scroll view is
/// always scrollable and, therefore, can trigger the [PullRefreshBox].
///
/// See also:
///
///  * [PullRefreshBoxState], can be used to programmatically show the refresh indicator.
///
class PullRefreshBox extends StatefulWidget {
  PullRefreshBox({
    Key key,
    this.child,
    @required this.onRefresh,
    this.indicator
  }) :super(key: key) {
    this.indicator ??= DefaultPullRefreshIndicator();
  }

  PullRefreshCallback onRefresh;
  PullRefreshIndicator indicator;
  Widget child;


  @override
  PullRefreshBoxState createState() => new PullRefreshBoxState();
}

/// Contains the state for a [PullRefreshBox]. This class can be used to
/// programmatically show the refresh indicator, see the [show] method.
/// [RefreshIndicatorState], can be used to programmatically show the refresh indicator.

class PullRefreshBoxState extends State<PullRefreshBox>
    with TickerProviderStateMixin {
  //double _height = 50.0;
  PullRefreshIndicatorMode _mode;
  AnimationController _controller;
  double _dragOffset = .0;
  ScrollDirection _direction;
  double _height = 0.0;
  bool _refreshing = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this,
        duration: Duration(seconds: 2),
        lowerBound: -500.0,
        upperBound: 500.0
    );
    _controller.value = 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Show the refresh indicator and run the refresh callback as if it had
  /// been started interactively. If this method is called while the refresh
  /// callback is running, it quietly does nothing.
  ///
  /// Creating the [PullRefreshBox] with a [GlobalKey<PullRefreshBoxState>]
  /// makes it possible to refer to the [PullRefreshBoxState].
  ///
  /// The future returned from this method completes when the
  /// [PullRefreshBox.onRefresh] callback's future completes.
  ///
  /// If you await the future returned by this function from a [State], you
  /// should check that the state is still [mounted] before calling [setState].

  Future show() {
    _mode = PullRefreshIndicatorMode.refresh;
    _checkIfNeedRefresh();
  }

  Future _checkIfNeedRefresh() {
    _height = widget.indicator.height;
    if (_mode == PullRefreshIndicatorMode.refresh && !_refreshing) {
      _refreshing = true;
      _controller.animateTo(_height, duration: Duration(milliseconds: 200));
      return widget.onRefresh().whenComplete(() {
        _mode = PullRefreshIndicatorMode.done;
        _controller.animateTo(0.0, duration: Duration(milliseconds: 300));
        _dragOffset = 0.0;
        _refreshing = false;
        _mode = null;
      });
    }
    return Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    _checkIfNeedRefresh();
    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          builder: (BuildContext context, Widget child) {
            return Transform.translate(offset: Offset(0.0, _controller.value),
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: new NotificationListener<
                    OverscrollIndicatorNotification>(
                    onNotification: _handleGlowNotification,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                          platform: TargetPlatform.android),
                      child: AbsorbPointer(
                        absorbing: _dragOffset != 0.0,
                        child: widget.child,
                      ),
                    )
                ),
              ),
            );
          },
          animation: _controller,
        ),
        //Header
        AnimatedBuilder(
          builder: (BuildContext context, Widget child) {
            return Transform.translate(offset: Offset(
                0.0, -_height + _controller.value),
                child: SizedBox(
                  height: _height,
                  width: double.infinity,
                  child: widget.indicator.build(
                      context, _mode, _dragOffset, _direction
                  ),
                )
            );
          },
          animation: _controller,
        )
      ],
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_mode == PullRefreshIndicatorMode.refresh) {
      return true;
    }
    if (notification is OverscrollNotification) {
      if (_mode != PullRefreshIndicatorMode.refresh) {
        _dragOffset -= notification.overscroll / 2.0;
        _mode = PullRefreshIndicatorMode.drag;
        _controller.value = _dragOffset;
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_dragOffset > 0.0) {
        _dragOffset -= notification.scrollDelta;
        _controller.value = _dragOffset;
      }
    } else if (notification is ScrollEndNotification) {
      if (_dragOffset >= _height && _mode != PullRefreshIndicatorMode.refresh) {
        setState(() {
          _mode = PullRefreshIndicatorMode.refresh;
        });
      }
      if (_mode != PullRefreshIndicatorMode.refresh) {
        _mode = PullRefreshIndicatorMode.canceled;
        _dragOffset = .0;
        _controller.animateTo(0.0, duration: Duration(milliseconds: 200));
      }
    } else if (notification is UserScrollNotification) {
      _direction = notification.direction;
    }
    return false;
  }


  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    notification.disallowGlow();
    return true;
  }
}

