import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Alias for TextAlignVertical.
typedef VerticalAlign = TextAlignVertical;

/// A widget which supports left-right layout algorithm.
class LeftRightBox extends MultiChildRenderObjectWidget {
  LeftRightBox({
    Key? key,
    required Widget left,
    Widget? right,
    this.verticalAlign = VerticalAlign.top,
  }) : super(key: key, children: [left, if (right != null) right]);

  final VerticalAlign verticalAlign;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLeftRight(verticalAlign);
  }

  @override
  void updateRenderObject(_, _RenderLeftRight renderObject) {
    renderObject.verticalAlign = verticalAlign;
  }
}

class _LeftRightParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderLeftRight extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _LeftRightParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _LeftRightParentData> {
  _RenderLeftRight(this.verticalAlign);

  VerticalAlign verticalAlign;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _LeftRightParentData)
      child.parentData = _LeftRightParentData();
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    RenderBox leftChild = firstChild!;
    _LeftRightParentData childParentData =
        leftChild.parentData! as _LeftRightParentData;
    RenderBox? rightChild = childParentData.nextSibling;

    double rightChildWidth = .0;
    double rightChildHeight = .0;

    if (rightChild != null) {
      //我们限制右孩子宽度不超过总宽度一半
      rightChild.layout(
        constraints.copyWith(minWidth: 0, maxWidth: constraints.maxWidth / 2),
        parentUsesSize: true,
      );
      rightChildWidth = rightChild.size.width;
      rightChildHeight = rightChild.size.height;

      //调整右子节点的offset
      childParentData = rightChild.parentData! as _LeftRightParentData;
      childParentData.offset = Offset(
        constraints.maxWidth - rightChildWidth,
        0,
      );
    }
    // layout left child
    // 左子节点的offset默认为（0，0），为了确保左子节点始终能显示，我们不修改它
    leftChild.layout(
      //左侧剩余的最大宽度
      constraints.copyWith(
        minWidth: 0,
        maxWidth: constraints.maxWidth - rightChildWidth,
      ),
      parentUsesSize: true,
    );

    //设置容器的size
    size = Size(
      constraints.maxWidth,
      max(leftChild.size.height, rightChildHeight),
    );

    if (verticalAlign.y != -1) {
      RenderBox? needAlignChild;
      if (leftChild.size.height < size.height) {
        needAlignChild = leftChild;
      } else if (rightChild != null && rightChildHeight < size.height) {
        needAlignChild = rightChild;
      }
      if (needAlignChild != null) {
        childParentData = needAlignChild.parentData as _LeftRightParentData;
        if (verticalAlign.y == 0) {
          childParentData.offset = Offset(
            childParentData.offset.dx,
            (size.height - needAlignChild.size.height) / 2,
          );
        } else {
          childParentData.offset = Offset(
            childParentData.offset.dx,
            (size.height - needAlignChild.size.height),
          );
        }
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
