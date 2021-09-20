import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';

class DoneWidgetRoute extends StatefulWidget {
  const DoneWidgetRoute({Key? key}) : super(key: key);

  @override
  State<DoneWidgetRoute> createState() => _DoneWidgetRouteState();
}

class _DoneWidgetRouteState extends State<DoneWidgetRoute> {
  bool show = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          show = !show;
        });
      },
      child: Center(
        child: Column(
          children: [
            Text('点击屏幕'),
            Visibility(
              visible: show,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DoneWidget(outline: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text("操作成功"),
                  ),
                  DoneWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
