import 'package:flutter/material.dart';
import 'after_layout.dart';

/// Control the scale of a child widget.
///
/// ScaleView not only support scare and double click gesture,
/// but also support move widget in horizontal and vertical direction
/// when its child widget is scaled.
///
/// The child scale range is `minScale`< scale < `maxScale`. the size will
/// be scale*widgetSize
///
/// When the child widget is scaled and the content is overflow,
/// you can use [ClipRect] to clip the content to equal the room of ScaleView
///
/// ```dart
///   ClipRect(
///    child: ScaleView(
///       child: Image.asset("images/xx.png")
///     )
///  )
/// ```
///
/// Gesture conflicts may occur When the scale view in a [Scrollable] widget
/// such as [ListView], in this scenario, you can specify the [parentScrollableAxis]
/// explicitly.
///

class ScaleView extends StatefulWidget {
  ScaleView({Key key,
    this.minScale = 1.0,
    this.maxScale = 10.0,
    this.doubleClickScale = 3.0,
    this.alignment: Alignment.center,
    this.behavior: HitTestBehavior.opaque,
    this.parentScrollableAxis = Axis.horizontal,
    this.child,
  })
      : super(key: key);

  /// Minimum scale multiplier
  final double minScale;

  /// Maximum scale multiplier
  final double maxScale;

  /// Determine how many times to scale after double click.
  final double doubleClickScale;

  /// Child widget alignment in scale view.
  final Alignment alignment;

  /// It must be the same width as the scroll direction of
  /// parent [Scrollable] widget when it exists.
  final Axis parentScrollableAxis;

  /// Gesture hit test room, defaults to [HitTestBehavior.opaque],
  /// means the entire scale view room will respond to the user input.
  /// If you just expect the child self respond to the user input, set
  /// value as [HitTestBehavior.deferToChild].
  final HitTestBehavior behavior;

  final Widget child;

  @override
  _ScaleViewState createState() => new _ScaleViewState();
}

const double _kMinFlingVelocity = 800.0;

class _ScaleViewState extends State<ScaleView>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _flingAnimation;
  Animation<double> _scaleAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;
  bool _doubleClick = true;
  BuildContext _childContext;
  Size _childSize;
  Offset _origin;
  Offset _focalPoint;

  //缓存子widget Size
  Size get childSize {
    //if (_childContext.size.width == Size.zero) return Size(10, 10);
    if (_childSize == null) {
      if(_childContext.size.width<context.size.width&&_childContext.size.height<context.size.height){
        _childSize=_childContext.size;
      }else {
        _childSize =
            applyBoxFit(BoxFit.contain, _childContext.size, context.size)
                .destination;
      }
      print("_childContext.size ${_childContext.size} context.size ${context.size} _childSize $_childSize", );
    }
    return _childSize;
  }

  //缓存子Widget中心点
  Offset get origin {
    if (_origin == null) {
      _origin = Offset(childSize.width / 2.0, childSize.height / 2.0);
    }
    return _origin;
  }

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 150))
      ..addListener(_handleFlingAnimation)
      ..addStatusListener((status) {
        if (_doubleClick && status == AnimationStatus.completed) {
          _doubleClick = false;
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _clampOffset(Offset offset) {
    final Offset minOffset =
        Offset(childSize.width, childSize.height) * (1 - _scale);
    if (_scale >= 1.0) {
      return Offset(
          offset.dx.clamp(minOffset.dx, .0), offset.dy.clamp(minOffset.dy, .0));
    } else {
      return Offset(offset.dx.clamp(0.0, _childSize.width * (1 - _scale)),
          offset.dy.clamp(0.0, _childSize.height * (1 - _scale)));
    }
  }

  void _handleFlingAnimation() {
    //执行Fling动画，不停的去修改_offset和_scale值
    if (_flingAnimation == null) return;
    setState(() {
      if (_doubleClick) {
        _offset = _flingAnimation.value;
        _scale = _scaleAnimation.value;
      } else {
        _offset = _flingAnimation.value;
      }
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (origin - _offset) / _scale;
      _focalPoint = details.focalPoint;
      //开始缩放，停止之前的fling动画
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    _doubleClick = false;
    setState(() {
      //放大或缩小
      if (details.scale != 1.0) {
        //放大倍数在widget.minScale-maxScale倍之间。
        _scale = (_previousScale * details.scale)
            .clamp(widget.minScale, widget.maxScale);
        _offset = origin - _normalizedOffset * _scale;
      } else {
        //垂直方向拖动
        _offset += details.focalPoint - _focalPoint;
        _focalPoint = details.focalPoint;
      }
      _offset = _clampOffset(_offset);
    });
  }

  void _handleFling(details) {
    //缩放结束后根据结束时的速度，执行一个fling动画。
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    if (magnitude < _kMinFlingVelocity) {
      setState(() {
        _offset = _clampOffset(_offset);
      });
      return;
    }

    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation = new Tween<Offset>(
        begin: _offset, end: _clampOffset(_offset + direction * distance))
        .animate(_controller);
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  void _handleOnDoubleTab() {
    _flingAnimation = null;
    _controller.reset();
    _doubleClick = true;
    Size size = childSize;
    if (_scale != 1.0) {
      _flingAnimation = new Tween<Offset>(begin: _offset, end: Offset.zero)
          .animate(_controller);
      _scaleAnimation =
          new Tween<double>(begin: _scale, end: 1.0).animate(_controller);
      _controller.forward();
    } else {
      size = size * (widget.doubleClickScale - 1);
      _flingAnimation = new Tween<Offset>(
          begin: Offset.zero, end: Offset(size.width, size.height) / -2.0)
          .animate(_controller);
      _scaleAnimation =
          new Tween<double>(begin: _scale, end: widget.doubleClickScale)
              .animate(_controller);
      _controller.forward();
    }
  }

  void _handleOnDragUpdate(de) {
    setState(() {
      _offset += de.delta;
      _offset = _clampOffset(_offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool horizontal = widget.parentScrollableAxis == Axis.horizontal;
    return GestureDetector(
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleFling,
      onDoubleTap: _handleOnDoubleTab,
      onVerticalDragEnd: (_scale == 1.0 || horizontal) ? null : _handleFling,
      onVerticalDragUpdate:
      (_scale == 1.0 || horizontal) ? null : _handleOnDragUpdate,
      onHorizontalDragEnd:
      (_scale == 1.0 || !horizontal) ? null : _handleFling,
      onHorizontalDragUpdate:
      (_scale == 1.0 || !horizontal) ? null : _handleOnDragUpdate,
      behavior: widget.behavior,
      child: Align(
        alignment: widget.alignment,
        child: new Transform(
          transform: new Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: FittedBox(
            fit: BoxFit.contain,
            child: AfterLayout(
              callback: (BuildContext ctx) {
                _childContext = ctx;
              },
              child: ConstrainedBox(
                constraints:
                BoxConstraints(minWidth: 10.0, minHeight: 10.0),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
