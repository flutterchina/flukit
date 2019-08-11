import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'turn_box.dart';

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
  /// The distance from the child's top or bottom edge to where the refresh
  /// indicator will settle. During the drag that exposes the refresh indicator,
  /// its actual displacement may significantly exceed this value.
  double get displacement;

  /// Header height
  double get height;

  Widget build(
    BuildContext context,
    PullRefreshIndicatorMode mode,
    double offset, //drag offset(over scroll)
    ScrollDirection direction,
  );
}

/// This is a default PullRefreshIndicator.
class DefaultPullRefreshIndicator implements PullRefreshIndicator {
  DefaultPullRefreshIndicator({
    this.style = const TextStyle(color: Colors.grey),
    this.arrowColor = Colors.grey,
    this.loadingTip,
    this.pullTip,
    this.loosenTip,
    this.progressIndicator,
  });

  final TextStyle style;
  final Color arrowColor;
  final String loadingTip;
  final String pullTip;
  final String loosenTip;
  ProgressIndicator progressIndicator;

  @override
  double get displacement => 100.0;

  @override
  double get height => displacement;

  @override
  Widget build(BuildContext context, PullRefreshIndicatorMode mode, offset,
      ScrollDirection direction) {
    if (mode == PullRefreshIndicatorMode.refresh) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          progressIndicator ??
              SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                ),
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
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: TurnBox(
            turns: offset > 100 ? 0.5 : .0,
            child: Icon(
              Icons.arrow_upward,
              color: Colors.grey,
            ),
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
    PullRefreshIndicator indicator,
    this.overScrollEffect,
  })  : this.indicator = indicator ?? DefaultPullRefreshIndicator(),
        super(key: key);

  final PullRefreshCallback onRefresh;
  final Widget child;
  final TargetPlatform overScrollEffect;
  final PullRefreshIndicator indicator;

  @override
  PullRefreshBoxState createState() => new PullRefreshBoxState();
}

/// Contains the state for a [PullRefreshBox]. This class can be used to
/// programmatically show the refresh indicator, see the [show] method.
/// [RefreshIndicatorState], can be used to programmatically show the refresh indicator.

class PullRefreshBoxState extends State<PullRefreshBox>
    with TickerProviderStateMixin {
  PullRefreshIndicatorMode _mode;
  AnimationController _controller;
  double _dragOffset = .0;
  ScrollDirection _direction;
  bool _refreshing = false;

  bool get _androidEffect =>
      widget.overScrollEffect == TargetPlatform.android ||
      (widget.overScrollEffect == null &&
          defaultTargetPlatform == TargetPlatform.android);

  double get _indicatorHeight =>
      widget.indicator.height ?? widget.indicator.displacement ?? 100.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 2),
        lowerBound: -500.0,
        upperBound: 500.0);
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

  Future<void> show() {
    _mode = PullRefreshIndicatorMode.refresh;
    return _checkIfNeedRefresh();
  }

  _goBack() {
    _dragOffset = .0;
    if (mounted) {
      _controller
          .animateTo(
        0.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      )
          .then((e) {
        _mode = PullRefreshIndicatorMode.done;
      });
    }
  }

  Future _checkIfNeedRefresh() {
    if (_mode == PullRefreshIndicatorMode.refresh && !_refreshing) {
      _refreshing = true;
      _controller.animateTo(widget.indicator.displacement ?? 100.0,
          duration: Duration(milliseconds: 200));
      return widget.onRefresh().whenComplete(() {
        _mode = PullRefreshIndicatorMode.done;
        _goBack();
        _refreshing = false;
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
            return Transform.translate(
              offset: Offset(0.0, _controller.value),
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child:
                    new NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: _handleGlowNotification,
                        child: Theme(
                          data: Theme.of(context)
                              .copyWith(platform: TargetPlatform.android),
                          child: widget.child,
                        )),
              ),
            );
          },
          animation: _controller,
        ),
        //Header
        AnimatedBuilder(
          builder: (BuildContext context, Widget child) {
            return Transform.translate(
                offset: Offset(0.0, -_indicatorHeight + _controller.value + 1),
                child: SizedBox(
                    height: _indicatorHeight,
                    width: double.infinity,
                    child: widget.indicator.build(
                      context,
                      _mode,
                      _dragOffset,
                      _direction,
                    )));
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
        double _temp = _dragOffset;
        _dragOffset -= notification.overscroll / 3.0;
        _mode = PullRefreshIndicatorMode.drag;
        if (_androidEffect) {
          if (_dragOffset < .0) {
            _dragOffset = .0;
          }
        }
        if (_temp != _dragOffset) {
          _controller.value = _dragOffset;
        }
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_dragOffset > 0.0) {
        _dragOffset -= notification.scrollDelta;
        _controller.value = _dragOffset;
      }
    } else if (notification is ScrollEndNotification) {
      if (_dragOffset >= (widget.indicator.displacement ?? 100.0) &&
          _mode != PullRefreshIndicatorMode.refresh) {
        setState(() {
          _mode = PullRefreshIndicatorMode.refresh;
        });
      }
      if (_mode != PullRefreshIndicatorMode.refresh) {
        _mode = PullRefreshIndicatorMode.canceled;
        _goBack();
      }
    } else if (notification is UserScrollNotification) {
      _direction = notification.direction;
    }
    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (!_androidEffect || notification.leading) {
      notification.disallowGlow();
    }
    return true;
  }
}
