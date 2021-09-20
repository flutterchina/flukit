import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class PullRefreshRoute extends StatefulWidget {
  PullRefreshRoute({Key? key}) : super(key: key);

  @override
  State<PullRefreshRoute> createState() => _PullRefreshRouteState();
}

class _PullRefreshRouteState extends State<PullRefreshRoute> {
  int _itemCount = 5;

  @override
  Widget build(BuildContext context) {
    return PullRefreshScope(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: <Widget>[
          SliverPullRefreshIndicator(
            refreshTriggerPullDistance: 100.0,
            refreshIndicatorExtent: 60.0,
            onRefresh: () async {
              await Future<void>.delayed(const Duration(seconds: 2));
              setState(()=>_itemCount += 10);
            },
          ),
          SliverFixedExtentList(
            itemExtent: 50,
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return ListTile(title: Text('$index'), onTap: () => print(index));
              },
              childCount: _itemCount,
            ),
          ),
        ],
      ),
    );
  }
}