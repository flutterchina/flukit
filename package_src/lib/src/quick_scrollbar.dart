import 'dart:async';
import 'package:flutter/material.dart';

/// A quick scrollbar not only indicates which portion of a [Scrollable]
/// widget is actually visible, but also control the scroll position of
/// [Scrollable] widget by [ScrollController].
///
/// Quick scrollbar support the drag gesture to scroll the [Scrollable]
/// widget quickly.

class QuickScrollbar extends StatefulWidget {
  QuickScrollbar(
      {Key key, this.controller, this.velocity = 10, @required this.child})
      : super(key: key);

  final Widget child;

  /// The [Scrollable] widget's Controller, by which quick scrollbar
  /// will control the scroll position of [Scrollable] widget.
  final ScrollController controller;

  /// Critical value that determine to show [QuickScrollbar].
  /// If the scroll delta offset greater than [velocity], the
  /// quick scrollbar will show.
  final int velocity;

  @override
  _QuickScrollBarState createState() => new _QuickScrollBarState();
}

class _QuickScrollBarState extends State<QuickScrollbar>
    with SingleTickerProviderStateMixin {
  double _offsetTop = 0.0;
  double _barHeight = 35.0;

  // Animation controller for show/hide bar .
  AnimationController _animationController;
  Animation _animation;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 200));
    _animation = Tween(begin: 1.0, end: 0.0).animate(_animationController);
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = widget.controller ??
        PrimaryScrollController.of(context) ??
        ScrollController();
    Widget stack = Stack(
      children: <Widget>[
        RepaintBoundary(
          child: widget.child,
        ),
        Positioned(
          top: _offsetTop,
          right: 0.0,
          child: RepaintBoundary(
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: FadeTransition(
                  child: Material(
                    color: Color(0xffe8e8e8),
                    elevation: .8,
                    child: SizedBox(
                        height: _barHeight,
                        width: 28.0,
                        child: Icon(
                          Icons.unfold_more,
                          color: Colors.grey[600],
                          size: 24.0,
                        )),
                  ),
                  opacity: _animation,
                ),
              ),
              onVerticalDragStart: (DragStartDetails details) {
                _timer?.cancel();
              },
              onVerticalDragUpdate: (DragUpdateDetails details) {
                var position = scrollController.position;

                double pixels = (position.extentBefore + position.extentAfter) *
                    details.delta.dy /
                    (position.extentInside - _barHeight);
                pixels += position.pixels;
                scrollController
                    .jumpTo(pixels.clamp(0.0, position.maxScrollExtent));
              },
              onVerticalDragEnd: (details) {
                _fadeBar();
              },
            ),
          ),
        )
      ],
    );
    return NotificationListener<ScrollNotification>(
      onNotification: _handleNotification,
      child: stack,
    );
  }

  void _fadeBar() {
    if (_animationController.value == 1.0) return;
    _timer?.cancel();
    _timer = new Timer(Duration(seconds: 1), () {
      _animationController.animateTo(1.0);
      _animationController.forward();
    });
  }

  bool _handleNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.scrollDelta.abs() > widget.velocity &&
          notification.metrics.maxScrollExtent != double.infinity) {
        _animationController.value = 0.0;
      }
    }
    setState(() {
      double total =
          notification.metrics.extentBefore + notification.metrics.extentAfter;
      _offsetTop = notification.metrics.extentBefore /
          total *
          (notification.metrics.extentInside - _barHeight);
      _fadeBar();
    });
    return true;
  }
}
