import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';

class QuickScrollbarRoute extends StatelessWidget {
  const QuickScrollbarRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuickScrollbar(
      child: ListView.builder(
        itemCount: 1000,
        // Specifying an [itemExtent] or [prototypeItem]  is more efficient
        // than letting the children determine their own extent when use QuickScrollbar.
        //itemExtent: 56,
        prototypeItem: const ListTile(title: Text("1")),
        itemBuilder: (ctx, index) => ListTile(
          title: Text("$index"),
          onTap: () => debugPrint('$index'),
        ),
      ),
    );
  }
}
