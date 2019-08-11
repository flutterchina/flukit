import 'dart:async';

import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class InfiniteListViewRoute extends StatefulWidget {
  @override
  _InfiniteListViewRouteState createState() => _InfiniteListViewRouteState();
}

class _InfiniteListViewRouteState extends State<InfiniteListViewRoute> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return InfiniteListView<int>(
      headerBuilder: (list,context){
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("功能介绍: 支持下拉刷新和上拉加载"),
        );
      },
      itemBuilder: (List list, int index, BuildContext ctx) {
        return ListTile(title: Text("${list[index]}"));
      },
      onRetrieveData: (int page, List items, bool refresh) {
        return Future.delayed(Duration(seconds: 2), () {
          int start = _current;
          if (refresh) {
            //如果是下拉数显
            _current = start = 0;
            items.clear();
          }
          if (_current == 50) return false; //最多加载50条
          while (start++ < _current + 10) {
            items.add(start);
          }
          _current += 10;
          return true;
        });
      },
      loadingBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedRotationBox(
                duration: Duration(milliseconds: 800),
                child: GradientCircularProgressIndicator(
                  radius: 10.0,
                  colors: [Colors.blue, Colors.lightBlue[50]],
                  value: .8,
                  backgroundColor: Colors.transparent,
                  strokeCapRound: true,
                ),
              ),
              Text("  加载更多...")
            ],
          ),
        );
      },
      noMoreViewBuilder: (list, context) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "共${list.length}条",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
