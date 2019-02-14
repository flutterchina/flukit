import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MyPullRefreshIndicator extends PullRefreshIndicator {
  MyPullRefreshIndicator({
    this.decoration,
    this.style,
    this.dragIndicator,
    this.refreshIndicator
  });
  final Decoration decoration;
  final TextStyle style;
  final Widget dragIndicator;
  final Widget refreshIndicator;

  @override
  Widget build(BuildContext context, PullRefreshIndicatorMode mode,
      double offset, ScrollDirection direction) {
    Widget child;
    if (mode == PullRefreshIndicatorMode.refresh) {
      child= Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: refreshIndicator??CircularProgressIndicator(strokeWidth: 2.0,),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Text("正在刷新...", style: style,),
          )
        ],
      );
    }else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TurnBox(
            turns: offset / 150.0,
            child: dragIndicator??Icon(Icons.refresh),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(offset > 80 ? "松开刷新" : "继续下拉", style: style,),
          )
        ],
      );
    }
    return Container(
      alignment: Alignment.bottomCenter,
      decoration: decoration,
      padding: EdgeInsets.only(bottom: 20.0),
      height: 500.0,
      child:child,
    );
  }

  @override
  double get displacement => 80.0;

  @override
  double get height => 500.0;

}