import 'dart:async';
import 'package:flutter/material.dart';

/// A controller for [Swiper].
///
/// A page controller lets you manipulate which page is visible in a [Swiper].
/// In addition to being able to control the pixel offset of the content inside
/// the [Swiper], a [SwiperController] also lets you control the offset in terms
/// of pages, which are increments of the viewport size.

class SwiperController extends ChangeNotifier {
  SwiperController({this.initialPage = 0});

  /// The page to show when first creating the [Swiper].
  final int initialPage;

  /// Current page index; todo 调用时机检查
  int get index => _state.getIndex();

  /// Scroll offset
  double? get offset => _state._pageController?.offset;

  _SwiperState? _swiperState;

  _SwiperState get _state {
    assert(_swiperState != null,
        "SwiperController cannot be accessed before a Swiper is built with it");
    return _swiperState!;
  }

  /// Start switching
  void start() => _state.start();

  /// Stop switching
  void stop() => _state.stop();

  /// Animates the controlled [Swiper] to the given page
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) {
    return _state.animateToPage(
      page < 0 ? 0 : page,
      duration: duration,
      curve: curve,
    );
  }

  /// Animates the controlled [Swiper] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> nextPage({
    required Duration duration,
    required Curve curve,
  }) {
    return animateToPage(_state._index + 1, duration: duration, curve: curve);
  }

  /// Animates the controlled [Swiper] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> previousPage({
    required Duration duration,
    required Curve curve,
  }) {
    return animateToPage(
      _state._index == 0 ? _state.widget.childCount - 1 : _state._index - 1,
      duration: duration,
      curve: curve,
    );
  }

  void _attach(_SwiperState state) => _swiperState = state;

  void _detach() => _swiperState = null;
}

/// Swiper indicator builder interface. If you want to custom indicator,
/// implement this interface.
///
/// See also:
///
///  * [RectangleSwiperIndicator], a rectangular style indicator.
///  * [CircleSwiperIndicator], a circular style indicator.
abstract class SwiperIndicator {
  Widget build(BuildContext context, int index, int itemCount);
}

/// Rectangular style indicator
class RectangleSwiperIndicator extends _SwiperIndicator {
  RectangleSwiperIndicator({
    EdgeInsetsGeometry? padding,
    double spacing = 4.0,
    double itemWidth = 16.0,
    double itemHeight = 2.0,
    Color itemColor = Colors.white70,
    Color? itemActiveColor,
  }) : super(
          padding: padding,
          spacing: spacing,
          itemColor: itemColor,
          itemWidth: itemWidth,
          itemHeight: itemHeight,
          itemActiveColor: itemActiveColor,
          itemShape: BoxShape.rectangle,
        );
}

/// Circular style indicator
class CircleSwiperIndicator extends _SwiperIndicator {
  CircleSwiperIndicator({
    EdgeInsetsGeometry? padding,
    double spacing = 6.0,
    double radius = 3.5,
    Color itemColor = Colors.white70,
    Color? itemActiveColor,
  }) : super(
          padding: padding,
          spacing: spacing,
          itemColor: itemColor,
          itemWidth: radius * 2,
          itemHeight: radius * 2,
          itemActiveColor: itemActiveColor,
          itemShape: BoxShape.circle,
        );
}

class _SwiperIndicator implements SwiperIndicator {
  _SwiperIndicator({
    this.spacing = 0.0,
    this.itemColor = Colors.white70,
    this.itemActiveColor,
    required this.itemWidth,
    required this.itemHeight,
    required this.itemShape,
    this.padding,
  });

  /// How much space to place between children in a run in  horizontal direction.
  ///
  /// For example, if [spacing] is 10.0, the children will be spaced at least
  /// 10.0 logical pixels apart in horizontal direction.
  final double spacing;

  /// The indicator color of inactive state
  final Color itemColor;

  /// The indicator color of active state
  final Color? itemActiveColor;

  final double itemWidth;
  final double itemHeight;
  final BoxShape itemShape;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, int index, int itemCount) {
    if (itemCount == 1) return const SizedBox(width: .0, height: .0);

    var children = List.generate(itemCount, (_index) {
      Color color = itemColor;
      if (_index == index) {
        color = itemActiveColor ?? Theme.of(context).colorScheme.secondary;
      }
      return Container(
        width: itemWidth,
        height: itemHeight,
        decoration: BoxDecoration(color: color, shape: itemShape),
      );
    });
    return Padding(
      padding: padding ?? const EdgeInsets.all(10.0),
      child: Wrap(
        runSpacing: spacing,
        spacing: spacing,
        children: children,
      ),
    );
  }
}

class _Indicator extends StatefulWidget {
  const _Indicator({
    Key? key,
    required this.initPage,
    required this.itemCount,
    required this.indicator,
  }) : super(key: key);

  @override
  __IndicatorState createState() => __IndicatorState();

  final SwiperIndicator indicator;
  final int itemCount;
  final int initPage;
}

class __IndicatorState extends State<_Indicator> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initPage;
  }

  update(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.indicator.build(context, _index, widget.itemCount);
  }
}

/// A  scrollable list that works page by page automatically or manually,
/// and it also support loop playbacks.
///
/// See also:
///  * [RectangleSwiperIndicator], a rectangular style indicator.
///  * [CircleSwiperIndicator], a circular style indicator.
///  * [SwiperController], a controller for [Swiper].
class Swiper extends StatefulWidget {
  Swiper({
    Key? key,
    this.direction = Axis.horizontal,
    this.autoStart = true,
    this.controller,
    this.indicator,
    this.speed = 300,
    this.interval = const Duration(seconds: 3),
    this.circular = true,
    this.reverse = false,
    this.indicatorAlignment = AlignmentDirectional.bottomCenter,
    this.viewportFraction = 1.0,
    this.onChanged,
    required this.children,
  })  : childCount = children!.length,
        itemBuilder = ((context, index) => children[index]),
        super(key: key);

  const Swiper.builder({
    Key? key,
    this.direction = Axis.horizontal,
    required this.childCount,
    required this.itemBuilder,
    this.autoStart = true,
    this.controller,
    this.indicator,
    this.speed = 300,
    this.interval = const Duration(seconds: 3),
    this.circular = true,
    this.reverse = false,
    this.indicatorAlignment = AlignmentDirectional.bottomCenter,
    this.viewportFraction = 1.0,
    this.onChanged,
  })  : children = null,
        super(key: key);

  /// The axis along which the swiper scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis direction;

  /// Whether the swiper scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [direction] is [Axis.horizontal], then the swiper scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [direction] is [Axis.vertical], then the swiper
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  final ValueChanged<int>? onChanged;

  /// An object that can be used to control the position to which this
  /// swiper is scrolled.
  final SwiperController? controller;

  /// Called to build children for the swiper.
  ///
  /// Will be called only for indices greater than or equal to zero and less
  /// than [childCount] (if [childCount] is non-null).
  ///
  /// Should return null if asked to build a widget with a greater index than
  /// exists.
  final IndexedWidgetBuilder itemBuilder;

  /// The real total number of children, at least 1 .
  final int childCount;

  /// Page switching speed
  final int speed;

  /// Whether the swiper start switching when it is built.
  final bool autoStart;

  /// Swiper page indicator
  final SwiperIndicator? indicator;

  /// The alignment of swiper indicator in swiper
  final AlignmentDirectional indicatorAlignment;

  /// Determine whether the swiper can continue to switch along the [direction]
  /// When the swiper at start or end page.
  final bool circular;

  /// Switching interval between two pages.
  final Duration interval;

  /// The fraction of the viewport that each page should occupy.
  ///
  /// Defaults to 1.0, which means each page fills the viewport in the scrolling
  /// direction.
  final double viewportFraction;

  final List<Widget>? children;

  @override
  _SwiperState createState() => _SwiperState();
}

class _SwiperState extends State<Swiper>
    with SingleTickerProviderStateMixin<Swiper> {
  PageController? _pageController;
  late int _index;
  Timer? _timer;
  bool _autoPlay = false;
  final _globalKey = GlobalKey<__IndicatorState>();
  bool _animateToPage = false;

  int getIndex() {
    return _index % widget.childCount;
  }

  @override
  void initState() {
    super.initState();
    _initController();
    if (widget.autoStart) start();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(Swiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller?.initialPage != widget.controller?.initialPage ||
        oldWidget.viewportFraction != widget.viewportFraction ||
        oldWidget.circular != widget.circular) {
      _initController(_index);
    }

    if (oldWidget.autoStart != widget.autoStart) {
      widget.autoStart ? start() : stop();
    }
  }

  start() {
    _autoPlay = true;
    _start();
  }

  stop() {
    _autoPlay = false;
    _timer?.cancel();
  }

  void _initController([int? index]) {
    _pageController?.dispose();
    _index = index ?? widget.controller?.initialPage ?? 0;

    if (widget.circular) {
      _index = widget.childCount + _index;
    } else {
      _index = getIndex();
    }

    _pageController = PageController(
      initialPage: _index,
      viewportFraction: widget.viewportFraction,
    );
  }

  void _start() {
    if (!_autoPlay || widget.childCount < 2) return;
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (timer) {
      animateToPage(
        widget.circular ? _index + 1 : (_index + 1) % widget.childCount,
        duration: Duration(milliseconds: widget.speed),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> animateToPage(
    int page, {
    required Duration duration,
    required Curve curve,
  }) async {
    if (widget.childCount < 2) return;

    int dest = page % widget.childCount;

    //不循环
    if (!widget.circular) {
      var cur = getIndex();
      page = dest;
      var last = widget.childCount - 1;
      if (page == cur ||
          (cur == 0 && page == last) ||
          //到最后一个page后，如果没有自动播放则什么也不做，否则需要回到第一个page
          (!_autoPlay && cur == last && page == 0)) {
        return;
      }
    } else {
      int distance = dest - getIndex();
      //检查是目标页是否当前页
      if (distance == 0) {
        return;
      }
    }

    _animateToPage = true;

    return _pageController
        ?.animateToPage(page, duration: duration, curve: curve)
        .then((e) {
      _globalKey.currentState?.update(getIndex());
      if (widget.onChanged != null) widget.onChanged!(dest);
      _animateToPage = false;
    });
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _pageController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (widget.circular && index < widget.childCount) {
      _index = widget.childCount + index;
      _pageController!.jumpToPage(_index);
      return;
    } else {
      _index = index;
    }
    _globalKey.currentState?.update(getIndex());
    if (!_animateToPage && widget.onChanged != null) {
      widget.onChanged!(getIndex());
    }
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    children.add(PageView.builder(
      //循环方式改变后要重新build，为了确保index的初始值正确
      key: ValueKey(widget.circular),
      scrollDirection: widget.direction,
      reverse: widget.reverse,
      itemCount:
          widget.circular && widget.childCount != 1 ? null : widget.childCount,
      onPageChanged: _onPageChanged,
      controller: _pageController,
      itemBuilder: (context, index) {
        return widget.itemBuilder(context, index % widget.childCount);
      },
    ));

    if (widget.indicator != null) {
      var indicator = _Indicator(
        key: _globalKey,
        initPage: getIndex(),
        itemCount: widget.childCount,
        indicator: widget.indicator!,
      );
      children.add(Positioned(
        child: indicator,
      ));
    }

    return Listener(
      onPointerDown: (event) => _timer?.cancel(),
      onPointerCancel: (event) => _start(),
      onPointerUp: (event) => _start(),
      child: MouseRegion(
        onEnter: (event) => _timer?.cancel(),
        onExit: (event) => _start(),
        child: Stack(alignment: widget.indicatorAlignment, children: children),
      ),
    );
  }
}
