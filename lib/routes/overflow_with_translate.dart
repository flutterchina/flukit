import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class OverflowWithTranslateRoute extends StatelessWidget {
  const OverflowWithTranslateRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Container(height: 10, width: 40, color: Colors.green),
        Expanded(
          child: Container(
            height: 10,
            color: Colors.red,
          ),
        ),
      ],
    );
    const offset = const Offset(-20, 0);
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Transform.translate：向左平移20像素后，右边会出现20像素空白'),
          ),
          Transform.translate(
            offset: offset,
            child: row,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('OverflowWithTranslateBox 向左平移20像素后，右边不会出现空白'),
          ),
          SizedBox(
            // Column子元素的maxHeight约束为无限大，但OverflowWithTranslateBox的最大宽高
            // 必须有限，因此我们显式指定高度
            height: 10,
            child: OverflowWithTranslateBox(offset: offset, child: row),
          )
        ],
      );
    });
  }
}
