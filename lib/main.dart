import 'package:flutter/material.dart';
import 'widgets/index.dart';
import 'routes/index.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flukit',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flukit demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: ListPage([
          //PageInfo("test", (ctx) => TestRoute()),
          PageInfo("Quick Scrollbar", (ctx) => QuickScrollbarRoute()),
          PageInfo("TurnBox", (ctx) => TurnBoxRoute()),
          PageInfo("AnimatedRotationBox", (ctx) => AnimatedRotationBoxRoute()),
          PageInfo("Pull Refresh", (ctx) => PullRefreshBoxRoute()),
          PageInfo("Swiper", (ctx) => SwiperRoute()),
          PageInfo("Swiper Style", (ctx) => SwiperStyleRoute()),
          PageInfo("Photo View", (ctx) => PhotoViewRoute()),
          PageInfo("GradientCircularProgressIndicator", (ctx) => GradientCircularProgressRoute()),
          PageInfo("AzListView", (ctx) => QuickSelectListViewRoute()),
        ]));
  }
}
