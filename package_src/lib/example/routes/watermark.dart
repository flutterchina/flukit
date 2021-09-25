import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart' hide Page;
import '../common/index.dart';

class WatermarkRoute extends StatelessWidget {
  const WatermarkRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListPage(
      children: [
        Page('文本水印', wTextWaterMark(), padding: false),
        Page('交错文本水印', wStaggerTextWaterMark(), padding: false),
        Page('水印指定偏移', wTextWaterMarkWithOverflowBox(), padding: false),
      ],
    );
  }

  Widget wTextWaterMark() {
    return Stack(
      children: [
        wPage(),
        IgnorePointer(
          child: WaterMark(
            painter: TextWaterMarkPainter(
              text: 'Flutter 中国 @wendux',
              padding: const EdgeInsets.all(18),
              textStyle: const TextStyle(
                color: Colors.black38,
              ),
              rotate: -10,
            ),
          ),
        ),
      ],
    );
  }

  Widget wStaggerTextWaterMark() {
    return Stack(
      children: [
        wPage(),
        IgnorePointer(
          child: WaterMark(
            painter: StaggerTextWaterMarkPainter(
              text: 'flukit@wendux',
              text2: 'flukit@wendux',
              padding1: const EdgeInsets.all(10),
              padding2: const EdgeInsets.only(
                left: 100,
                right: 10,
                top: 10,
                bottom: 10,
              ),
              rotate: -10,
            ),
          ),
        ),
      ],
    );
  }

  Widget wTextWaterMarkWithOverflowBox() {
    Future.delayed(const Duration(milliseconds: 200), () => debugPrint('dd'));
    return Stack(
      children: [
        wPage(),
        IgnorePointer(
          child: TranslateWithExpandedPaintingArea(
            offset: const Offset(-30, 0),
            clipBehavior: Clip.hardEdge,
            child: WaterMark(
              painter: TextWaterMarkPainter(
                text: 'Flutter 中国 @wendux',
                textStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.black38,
                ),
                rotate: -20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget wPage() {
    return Center(
      child: ElevatedButton(
        child: const Text('按钮'),
        onPressed: () => debugPrint('tab'),
      ),
    );
  }
}
