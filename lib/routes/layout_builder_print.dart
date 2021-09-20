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
              children: [LayoutLogPrint(child: Text('flukit@wendux'))],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            color: Colors.red,
            child: LayoutLogPrint(
              child: Text('A', style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
