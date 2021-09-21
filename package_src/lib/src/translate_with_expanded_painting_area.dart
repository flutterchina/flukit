import 'package:flutter/widgets.dart';

/// A widget that:
///  - imposes different constraints on its child than it gets from
///    its parent, possibly allowing the child to overflow the parent.
///  - apply translate to its child (specified by [offset]).
class TranslateWithExpandedPaintingArea extends StatelessWidget {
  const TranslateWithExpandedPaintingArea({
    Key? key,
    required this.offset,
    this.clipBehavior = Clip.none,
    this.child,
  }) : super(key: key);
  final Widget? child;
  final Offset offset;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dx = offset.dx.abs();
        final dy = offset.dy.abs();
        Widget widget = OverflowBox(
          //平移多少，则子组件相应轴的长度增加多少
          minWidth: constraints.minWidth + dx,
          maxWidth: constraints.maxWidth + dx,
          minHeight: constraints.minHeight + dy,
          maxHeight: constraints.maxHeight + dy,
          alignment: Alignment(
            // 不同方向的平移，要指定不同的对齐方式
            offset.dx <= 0 ? 1 : -1,
            offset.dy <= 0 ? 1 : -1,
          ),
          child: child,
        );
        //超出组件布局空间的部分要剪裁掉
        if (clipBehavior != Clip.none) {
          widget = ClipRect(clipBehavior: clipBehavior, child: widget);
        }
        return widget;
      },
    );
  }
}
