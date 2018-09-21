import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';
import 'package:flutter_test/flutter_test.dart';

class PullRefreshRoute extends StatefulWidget {

  @override
  _PullRefreshRouteState createState() => new _PullRefreshRouteState();
}

class _PullRefreshRouteState extends State<PullRefreshRoute> {
  var  _pullRefreshKey = GlobalKey<PullRefreshBoxState>();
  bool _init=false;

  @override
  Widget build(BuildContext context) {
    return AfterLayout(
      callback: (ctx) {
        //every time call `setState`, this call back will be called.
        if(!_init) {
          _init=true;
          _pullRefreshKey.currentState.show();
        }
      },
      child: PullRefreshBox(
        key: _pullRefreshKey,
        onRefresh: ()async =>Future.delayed(Duration(seconds: 2)),
        child: ListView.builder(
          itemCount: 100,
          itemBuilder: (ctx, index) => ListTile(title: Text("$index")),
        ),
      ),
    );
  }
}