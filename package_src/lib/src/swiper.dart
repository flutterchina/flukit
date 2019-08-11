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

  /// Current page index
  int get index => _state._getRealIndex();

  /// Current page index
  double get page => _state._pageController.page;

  /// Scroll offset
  double get offset => _state._pageController.offset;

  _SwiperState _swiperState;

  _SwiperState get _state {
    assert(_SwiperState != null,
        "SwiperController cannot be accessed before a Swiper is built with it");
    return _swiperState;
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
    @required Duration duration,
    @required Curve curve,
  }) {
    return _state.animateToPage(page, duration: duration, curve: curve);
  }

  /// Animates the controlled [Swiper] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> nextPage({@required Duration duration, @required Curve curve}) {
    return animateToPage(index + 1, duration: duration, curve: curve);
  }

  /// Animates the controlled [Swiper] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> previousPage(
      {@required Duration duration, @required Curve curve}) {
    return animateToPage(index - 1, duration: duration, curve: curve);
  }

  void notifyListeners() {
    super.notifyListeners();
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
///
abstract class SwiperIndicator {
  Widget build(BuildContext context, int index, int itemCount);
}

/// Rectangular style indicator
class RectangleSwiperIndicator extends _SwiperIndicator {
  RectangleSwiperIndicator({
    EdgeInsetsGeometry padding,
    double spacing = 4.0,
    double itemWidth = 16.0,
    double itemHeight = 2.0,
    Color itemColor = Colors.white70,
    Color itemActiveColor,
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
    EdgeInsetsGeometry padding,
    double spacing = 6.0,
    double radius = 3.5,
    Color itemColor = Colors.white70,
    Color itemActiveColor,
  }) : super(
            padding: padding,
            spacing: spacing,
            itemColor: itemColor,
            itemWidth: radius * 2,
            itemHeight: radius * 2,
            itemActiveColor: itemActiveColor,
            itemShape: BoxShape.circle);
}

class _SwiperIndicator implements SwiperIndicator {
  _SwiperIndicator({
    this.spacing,
    this.itemColor = Colors.white70,
    this.itemActiveColor,
    this.itemWidth,
    this.itemHeight,
    this.itemShape,
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
  final Color itemActiveColor;

  final double itemWidth;
  final double itemHeight;
  final BoxShape itemShape;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, int index, int itemCount) {
    if (itemCount == 1) return SizedBox(width: .0, height: .0);
    return Padding(
      padding: padding ?? const EdgeInsets.all(10.0),
      child: Wrap(
        runSpacing: spacing,
        spacing: spacing,
        children: List.generate(itemCount, (_index) {
          Color color = itemColor;
          if (_index == index) {
            color = itemActiveColor ?? Theme.of(context).accentColor;
          }
          return Container(
            width: itemWidth,
            height: itemHeight,
            decoration: BoxDecoration(color: color, shape: itemShape),
          );
        }),
      ),
    );
  }
}

// ignore: must_be_immutable
class Swiper extends StatefulWidget {
  Swiper({
    Key key,
    this.direction = Axis.horizontal,
    this.autoStart = true,
    this.controller,
    this.indicator,
    this.speed = 300,
    this.interval = const Duration(seconds: 3),
    this.circular = false,
    this.reverse = false,
    this.indicatorAlignment = AlignmentDirectional.bottomCenter,
    this.viewportFraction=1.0,
    @required this.children,

  })  : childCount = children.length,
        super(key: key) {
    assert(childCount > 0);
    if (circular && children.length > 1) {
      var _children = [children.last, children.first];
      _children.insertAll(1, children);
      children = _children;
    }
    _itemCount = children.length;
  }

  // PageView
  Swiper.builder({
    Key key,
    this.direction = Axis.horizontal,
    @required this.childCount,
    @required this.itemBuilder,
    this.autoStart = true,
    this.controller,
    this.indicator,
    this.speed = 300,
    this.interval = const Duration(seconds: 3),
    this.circular = false,
    this.reverse = false,
    this.indicatorAlignment = AlignmentDirectional.bottomCenter,
    this.viewportFraction=1.0,
  })  : children = null,
        _itemCount = childCount + ((circular && childCount > 1) ? 2 : 0),
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

  /// An object that can be used to control the position to which this
  /// swiper is scrolled.
  SwiperController controller;

  /// Called to build children for the swiper.
  ///
  /// Will be called only for indices greater than or equal to zero and less
  /// than [childCount] (if [childCount] is non-null).
  ///
  /// Should return null if asked to build a widget with a greater index than
  /// exists.
  IndexedWidgetBuilder itemBuilder;

  /// The real total number of children, at least 1 .
  final int childCount;

  /// Page switching speed
  final int speed;

  /// Whether the swiper start switching when it is built.
  final bool autoStart;

  /// Swiper page indicator
  SwiperIndicator indicator;

  /// The alignment of swiper indicator in swiper
  AlignmentDirectional indicatorAlignment;

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

  List<Widget> children;
  int _itemCount;

  @override
  _SwiperState createState() => new _SwiperState();
}

class _SwiperState extends State<Swiper>
    with SingleTickerProviderStateMixin<Swiper> {
  PageController _pageController;
  int _index = 0;
  int _current = 0;
  Timer _timer;
  bool _animating = false;
  bool _stopped = false;
  bool _circular;

  @override
  void initState() {
    super.initState();
    _init();
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(Swiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _stopped = !widget.autoStart;
    if (oldWidget.childCount != widget.childCount ||
        oldWidget.circular != widget.circular) {
      _init();
    }
  }

  start() {
    _stopped = false;
    _start();
  }

  stop() {
    _timer?.cancel();
    _stopped = true;
  }

  void _init() {
    //_pageController.
    _stopped = !widget.autoStart;
    _circular = widget._itemCount != widget.childCount;
    _pageController?.dispose();
    _index = 0;
    if (_circular) {
      _index =
          (widget.controller?.initialPage ?? 0).clamp(0, widget.childCount) + 1;
    }
    _current = _index;
    _pageController = PageController(initialPage: _index, viewportFraction: widget.viewportFraction);
    _pageController.addListener(() {
      widget.controller?.notifyListeners();
      int current = _pageController.page.ceil();
      if (current - _pageController.page > .001) {
        return;
      }
      if (_current != current) {
        //onPageChange
        if (!_animating) {
          //手动滑动时调整
          _current = current;
          if (_circular) {
            _index = _adjustPage(current);
          }
        }
      }
    });
    _start();
  }

  void _start() {
    if (_stopped || widget._itemCount < 2) return;
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval ?? Duration(seconds: 3), (timer) {
      //换页前更新_index
      _index = ++_index % widget._itemCount;
      animateToPage(
        _circular ? _index - 1 : _index,
        duration: Duration(milliseconds: widget.speed),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> animateToPage(
    int page, {
    @required Duration duration,
    @required Curve curve,
  }) {
    if (_circular) {
      page = page.clamp(-1, widget._itemCount - 1);
      page = page + 1 % widget._itemCount;
    } else {
      page = page.clamp(0, widget._itemCount - 1);
    }

    //先更新指示器,然后执行动画
    setState(() {
      _index = page;
    });
    var completer = Completer<Null>();
    _animating = true;
    _pageController
        .animateToPage(page, duration: duration, curve: curve)
        .then((e) {
      _animating = false;
      if (_circular) {
        _index = _adjustPage(_index);
      }
      completer.complete();
    });
    return completer.future;
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  int _adjustPage(int index) {
    if (index == widget._itemCount - 1) {
      index = 1;
      _pageController.jumpToPage(index);
    } else if (index == 0) {
      index = widget._itemCount - 2;
      _pageController.jumpToPage(index);
    }
    return index;
  }

  int _getRealIndex() {
    int indicatorIndex = _index;
    if (_circular) {
      if (_index == 0) {
        indicatorIndex = widget._itemCount - 3;
      } else if (_index == widget._itemCount - 1) {
        indicatorIndex = 0;
      } else {
        indicatorIndex = _index - 1;
      }
    }
    return indicatorIndex;
  }

  void _onPageChanged(int index) {
    if (!_animating) {
      setState(() {
        _index = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[];
    if (widget.itemBuilder == null) {
      children.add(PageView(
        key: ValueKey(_pageController.initialPage),
        scrollDirection: widget.direction,
        reverse: widget.reverse,
        onPageChanged: _onPageChanged,
        controller: _pageController,
        children: widget.children,
      ));
    } else {
      children.add(PageView.builder(
        key: ValueKey(_pageController.initialPage),
        scrollDirection: widget.direction,
        reverse: widget.reverse,
        onPageChanged: _onPageChanged,
        itemCount: widget._itemCount,
        controller: _pageController,
        itemBuilder: (context, index) {
          return widget.itemBuilder(
            context,
            widget._itemCount - 2 == widget.childCount
                ? (index - 1) % widget.childCount
                : index,
          );
        },
      ));
    }
    if (widget.indicator != null) {
      children.add(Positioned(
        child:
            widget.indicator.build(context, _getRealIndex(), widget.childCount),
      ));
    }

    return Listener(
      onPointerDown: (event) => _timer?.cancel(),
      onPointerCancel: (event) => _start(),
      onPointerUp: (event) => _start(),
      child: Stack(alignment: widget.indicatorAlignment, children: children),
    );
  }
}
