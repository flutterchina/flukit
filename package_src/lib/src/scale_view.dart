import 'package:flutter/material.dart';
import 'after_layout.dart';

/// Scale the child from [minScale] to  [maxScale].
///
/// ScaleView not only support scale and double click gesture,
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
///       child: Image.asset("imgs/xx.png"),
///       minScale: .5,
///       maxScale: 3,
///     )
///  )
/// ```
///
/// Gesture conflicts may occur when the scale view in a [Scrollable] widget
/// such as [ListView], in this scenario, you can specify the [parentScrollableAxis]
/// explicitly.
///
class ScaleView extends StatefulWidget {
  const ScaleView({
    Key? key,
    this.minScale = 1.0,
    this.maxScale = 10.0,
    this.doubleClickScale = 3.0,
    this.alignment = Alignment.center,
    this.parentScrollableAxis = Axis.horizontal,
    required this.child,
  }) : super(key: key);

  /// Minimum scale multiplier
  final double minScale;

  /// Maximum scale multiplier
  final double maxScale;

  /// Determine how many times to scale after double click.
  final double doubleClickScale;

  /// Child widget alignment in scale view.
  final Alignment alignment;

  /// If there is an ancestor scrollview, in order to resolve the gesture conflict
  /// between ScaleView and the ancestor scrollview , [parentScrollableAxis]
  /// must be same as the scroll direction of the ancestor scrollview.
  ///
  /// If there is **not** an ancestor scrollview, it should be null.
  final Axis? parentScrollableAxis;

  final Widget child;

  @override
  _ScaleViewState createState() => _ScaleViewState();
}

const double _kMinFlingVelocity = 800.0;

class _ScaleViewState extends State<ScaleView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<Offset>? _flingAnimation;
  late Animation<double> _scaleAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  late Offset _normalizedOffset;
  late double _previousScale;
  bool _doubleClick = true;
  late Size _childSize;

  // 缓存子Widget中心点
  late Offset _origin;
  late Offset _focalPoint;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )
      ..addListener(_handleFlingAnimation)
      ..addStatusListener(
        (status) {
          if (_doubleClick && status == AnimationStatus.completed) {
            _doubleClick = false;
          }
        },
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _clampOffset(Offset offset) {
    final Offset minOffset =
        Offset(_childSize.width, _childSize.height) * (1 - _scale);
    if (_scale >= 1.0) {
      return Offset(
        offset.dx.clamp(minOffset.dx, .0),
        offset.dy.clamp(minOffset.dy, .0),
      );
    } else {
      return Offset(
        offset.dx.clamp(0.0, _childSize.width * (1 - _scale)),
        offset.dy.clamp(0.0, _childSize.height * (1 - _scale)),
      );
    }
  }

  void _handleFlingAnimation() {
    //执行Fling动画，不停的去修改_offset和_scale值
    if (_flingAnimation == null) return;
    setState(() {
      if (_doubleClick) {
        _offset = _flingAnimation!.value;
        _scale = _scaleAnimation.value;
      } else {
        _offset = _flingAnimation!.value;
      }
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (_origin - _offset) / _scale;
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
        _offset = _origin - _normalizedOffset * _scale;
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
    //手指甩动的时候，移动的距离为当前ScaleView短边的一般
    final double distance = context.size!.shortestSide / 2;
    _flingAnimation = Tween<Offset>(
      begin: _offset,
      end: _clampOffset(_offset + direction * distance),
    ).animate(_controller);
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  late Offset _doubleClickPosition;
  late Rect _childRect;

  void _handleOnDoubleTab() {
    _flingAnimation = null;
    _controller.reset();
    _doubleClick = true;
    Size size = _childSize;
    // 已经处于缩放状态，则恢复原始大小
    if (_scale != 1.0) {
      _flingAnimation =
          Tween<Offset>(begin: _offset, end: Offset.zero).animate(_controller);
      _scaleAnimation =
          Tween<double>(begin: _scale, end: 1.0).animate(_controller);
      _controller.forward();
    } else {
      // 未处于缩放状态，则放大。

      // 先计算多出来的倍数
      final multiple = (widget.doubleClickScale - 1);
      //点击的位置（放大的锚点），如果点击位置不在子组件上，则默认将子组件的中心点作为锚点
      late Offset scaleAnchor;
      if (_childRect.contains(_doubleClickPosition)) {
        scaleAnchor = Offset(
          (_doubleClickPosition.dx - _childRect.left),
          (_doubleClickPosition.dy - _childRect.top),
        );
      } else {
        scaleAnchor = Offset(size.width, size.height) / 2.0;
      }

      _flingAnimation = Tween<Offset>(
        // 起始坐标为 0
        begin: Offset.zero,
        // 子组件的偏移（top,left） = -（锚点位置×多出来的倍数）
        end: scaleAnchor *= -multiple,
      ).animate(_controller);

      _scaleAnimation = Tween<double>(
        begin: _scale,
        end: widget.doubleClickScale,
      ).animate(_controller);

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
    // 如果已经缩放，且父可滚动组件可以沿水平方向滚动，则需要拦截水平拖拽手势，
    // 防止水平方向滑动而导致父可滚动组件滚动。
    bool hookHorizon =
        (_scale != 1.0 && widget.parentScrollableAxis == Axis.horizontal);
    // 垂直方向同理
    bool hookVertical =
        (_scale != 1.0 && widget.parentScrollableAxis == Axis.vertical);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: _handleOnScaleStart,
      onScaleUpdate: _handleOnScaleUpdate,
      onScaleEnd: _handleFling,
      onDoubleTap: _handleOnDoubleTab,
      onDoubleTapDown: (details) {
        _doubleClickPosition = details.localPosition;
      },
      onVerticalDragEnd: hookVertical ? _handleFling : null,
      onVerticalDragUpdate: hookVertical ? _handleOnDragUpdate : null,
      onHorizontalDragEnd: hookHorizon ? _handleFling : null,
      onHorizontalDragUpdate: hookHorizon ? _handleOnDragUpdate : null,
      child: Align(
        alignment: widget.alignment,
        child: Transform(
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          child: Builder(builder: (_context) {
            return AfterLayout(
              callback: (ral) {
                // fit 为 BoxFit.contain 时，FittedBox 的大小等于最终图片在屏幕上的显示大小。
                // 每次布局发生变化时都要更新
                _childSize = _context.size!;
                _origin = Offset(
                  _childSize.width / 2.0,
                  _childSize.height / 2.0,
                );
                final offset = ral.localToGlobal(
                  Offset.zero,
                  ancestor: context.findRenderObject(),
                );
                _childRect = offset & ral.size;
              },
              child: FittedBox(
                fit: BoxFit.contain,
                child: ConstrainedBox(
                  //至少size(1,1)，防止context.size为null
                  constraints: const BoxConstraints(minWidth: 1, minHeight: 1),
                  child: widget.child,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
