import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import '../common/index.dart';

class SliverFlexibleHeaderRoute extends StatefulWidget {
  const SliverFlexibleHeaderRoute({Key? key}) : super(key: key);

  @override
  State<SliverFlexibleHeaderRoute> createState() =>
      _SliverFlexibleHeaderRouteState();
}

class _SliverFlexibleHeaderRouteState extends State<SliverFlexibleHeaderRoute> {
  double _initHeight = 250;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverFlexibleHeader(
          visibleExtent: _initHeight,
          builder: (context, availableHeight, direction) {
            return GestureDetector(
              onTap: () => debugPrint('tap'),
              child: LayoutBuilder(builder: (context, cons) {
                return Image(
                  image: const AssetImage("imgs/avatar.png"),
                  width: 50.0,
                  height: availableHeight,
                  alignment: Alignment.bottomCenter,
                  fit: BoxFit.cover,
                );
              }),
            );
          },
        ),
        SliverToBoxAdapter(
          child: ListTile(
            onTap: () {
              setState(() {
                _initHeight = _initHeight == 250 ? 150 : 250;
              });
            },
            title: const Text('点击重置高度'),
            trailing: Text('当前高度 $_initHeight'),
          ),
        ),
        buildSliverList(30),
      ],
    );
  }
}
