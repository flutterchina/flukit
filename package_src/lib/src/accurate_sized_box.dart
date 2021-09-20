import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A box with a specified size for its child. It is similar to [SizedBox],
/// but the difference is SizedBox pass the constraints received from its
/// parent to its child, but [AccurateSizedBox] not. for example:
///```dart
///  final child = Container(width: 300, height: 300, color: Colors.red);
///  Row(
///       children: [
///         ConstrainedBox(
///           constraints: BoxConstraints.tight(Size(100, 100)),
///           // Actually, the child size will be 100×100.
///           child: SizedBox(width: 50, height: 50,child: child),
///         ),
///         ConstrainedBox(
///            constraints: BoxConstraints.tight(Size(100, 100)),
///            // The child size will be 50×50.
///            child: AccurateSizedBox( width: 50, height: 50, child: child),
///          ),
///       ],
///    );
/// ```
class AccurateSizedBox extends SingleChildRenderObjectWidget {
  const AccurateSizedBox({
    Key? key,
    this.width = 0,
    this.height = 0,
    required Widget child,
  }) : super(key: key, child: child);

  final double width;
  final double height;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAccurateSizedBox(width, height);
  }

  @override
  void updateRenderObject(context, RenderAccurateSizedBox renderObject) {
    renderObject
      ..width = width
      ..height = height;
  }
}

class RenderAccurateSizedBox extends RenderProxyBoxWithHitTestBehavior {
  RenderAccurateSizedBox(this.width, this.height);

  double width;
  double height;

  // 当前组件的大小只取决于父组件传递的约束
  @override
  bool get sizedByParent => true;

  // performResize 中会调用
  @override
  Size computeDryLayout(BoxConstraints constraints) {
    //设置当前元素宽高，遵守父组件的约束
    return constraints.constrain(Size(width, height));
  }

  @override
  void performLayout() {
    child!.layout(
      BoxConstraints.tight(
          Size(min(size.width, width), min(size.height, height))),
      // 父容器是固定大小，子元素大小改变时不影响父元素
      // parentUseSize为false时，子组件的布局边界会是它自身，子组件布局发生变化后不会影响当前组件
      parentUsesSize: false,
    );
  }
}
