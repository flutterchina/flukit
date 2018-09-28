import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';
import 'custom_pullrefresh_header.dart';

class PullRefreshWithCustomHeaderRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  PullRefreshBox(
      onRefresh: ()async =>Future.delayed(Duration(seconds: 2)),
      indicator: MyPullRefreshIndicator(),
      child: ListView.builder(
        /// Must set to `ClampingScrollPhysics()`
        physics:ClampingScrollPhysics(),
        itemCount: 100,
        itemBuilder: (ctx, index) => ListTile(title: Text("$index"), onTap: (){},),
      ),
    );
  }
}
