import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/viewport_offset.dart';
import 'package:flutter/src/widgets/framework.dart';

class MyPullRefreshIndicator extends PullRefreshIndicator {
  @override
  Widget build(BuildContext context, PullRefreshIndicatorMode mode,
      double offset, ScrollDirection direction) {
    if (mode == PullRefreshIndicatorMode.refresh) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(strokeWidth: 2.0,),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Text("正在刷新..."),
          )
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TurnBox(
          turns: offset / 150.0,
          child: Icon(Icons.refresh, color: Colors.grey[700],),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(offset > 80 ? "松开刷新" : "继续下拉"),
        )
      ],
    );
  }

  @override
  double get height => 80.0;

}