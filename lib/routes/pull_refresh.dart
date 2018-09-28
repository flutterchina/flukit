import 'package:flutter/material.dart';
import '../widgets/index.dart';
import 'pull_refresh/pull_refresh.dart';
import 'pull_refresh/pull_refresh_with_custom_header.dart';
import 'pull_refresh/pull_refresh_with_scrollview.dart';

class PullRefreshBoxRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListPage([
      PageInfo("PullRefresh",(ctx)=>PullRefreshRoute()),
      PageInfo("PullRefresh(Custom header)",(ctx)=>PullRefreshWithCustomHeaderRoute()),
      PageInfo("PullRefreshWithScrollView(Custom header)",(ctx)=>PullRefreshWithScrollView(), false),
    ]);
  }
}


