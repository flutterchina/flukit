import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class LayoutLogPrintRoute extends StatelessWidget {
  const LayoutLogPrintRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutLogPrint(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutLogPrint(
            child: Row(
              children: [
                LayoutLogPrint(child: const Text('flukit@wendux')),
                LayoutLogPrint(child: const Text('flukit@wendux')),
              ],
            ),
          ),
          GestureDetector(
            onTap: ()=>debugPrint('tap'),
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              color: Colors.red,
              child: LayoutLogPrint(
                child: const Text('A', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
