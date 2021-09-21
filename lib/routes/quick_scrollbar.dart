import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';
class QuickScrollbarRoute extends StatelessWidget {
  const QuickScrollbarRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return  QuickScrollbar(
      child: ListView.builder(
        itemCount: 1000,
        itemBuilder: (ctx,index)=>ListTile(title: Text("$index")),
      ),
    );
  }
}
