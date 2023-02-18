import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';

class QuickScrollbarRoute extends StatelessWidget {
  QuickScrollbarRoute({Key? key}) : super(key: key);

  ///If you are using a ListView, GridView,
  /// or any other scrollable widget, you need to create a ScrollController
  /// and pass it to the controller parameter of the QuickScrollbar widget:
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return QuickScrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
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
