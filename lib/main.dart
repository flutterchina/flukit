import 'dart:async';
import 'dart:math';
import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flukit/example/example.dart';

void main() {
  final logEmitter = getGlobalLogEmitter();
  runZoned(
    () => runApp(const MyApp()),
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        parent.print(zone, line);
        // Intercept `print` function and redirect log.
        logEmitter.value = LogInfo(false, line);
      },
      handleUncaughtError: (Zone self, ZoneDelegate parent, Zone zone,
          Object error, StackTrace stackTrace) {
        parent.print(zone, '${error.toString()} $stackTrace');
        // Redirect error log event when error.
        logEmitter.value = LogInfo(true, error.toString());
      },
    ),
  );

  var onError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    onError?.call(details);
    // Redirect error log event when error.
    logEmitter.value = LogInfo(true, details.toString());
  };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final routesMap= mapRoutes(getRoutes());
      final maxWidth = min(constraints.maxWidth, 500.0);
      return MaterialApp(
        title: 'Flukit',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: routesMap,
        onGenerateRoute: (RouteSettings settings) {
          String routeName = settings.name!.substring(1).toLowerCase();
          routeName = Uri.decodeComponent(routeName);
          return MaterialPageRoute(
            builder: routesMap[routeName] ??
                (context) => const MyHomePage(title: 'Flukit demo'),
          );
        },
        home: const MyHomePage(title: 'Flukit demo'),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//防止热更新失效，我们不定义为静态变量
List<Page> getRoutes(){
  return  [
    Page("AfterLayout", const AfterLayoutRoute(), showLog: true),
    Page(
      "AccurateSizedBox",
      const AccurateSizedBoxRoute(),
      showLog: true,
    ),
    Page("AnimatedRotationBox", const AnimatedRotationBoxRoute()),
    Page("DoneWidget", const DoneWidgetRoute()),
    Page("GradientButton", const GradientButtonRoute()),
    Page(
      "GradientCircularProgressIndicator",
      const GradientCircularProgressRoute(),
    ),
    Page(
      "KeepAlive Test",
      const KeepAliveTest(),
      padding: false,
      showLog: true,
    ),
    Page("LayoutLogPrint", const LayoutLogPrintRoute(), showLog: true),
    Page("LeftRightBox", const LeftRightBoxRoute()),
    Page("Log Panel", const LogListenerScopeRoute(), withScaffold: false),
    Page(
      "OverflowWithTranslateBox",
      const OverflowWithTranslateRoute(),
      padding: false,
    ),
    Page("PullRefresh", const PullRefreshRoute(), padding: false),

    Page("Quick Scrollbar", const QuickScrollbarRoute(),padding: false),
    Page("Swiper", const SwiperRoute()),
    Page("Swiper Style", const SwiperStyleRoute()),
    Page("ScaleView", const ScaleViewRoute(), padding: false),
    Page(
      "SliverFlexibleHeader",
      const SliverFlexibleHeaderRoute(),
      padding: false,
    ),
    Page(
      "SliverHeaderDelegate",
      const SliverHeaderDelegateRoute(),
      padding: false,
    ),
    Page(
      "SliverPersistentHeaderToBox",
      const SliverPersistentHeaderToBoxRoute(),
      padding: false,
    ),
    Page("SlideTransitionX", const SlideTransitionXRoute()),
    Page("TurnBox", TurnBoxRoute()),
    Page("WaterMark(水印)", const WatermarkRoute(), padding: false),
    // Page("AzListView", (ctx) => QuickSelectListViewRoute()),
  ];
}


class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListPage(
        children: getRoutes(),
      ),
    );
  }
}

Map<String, WidgetBuilder> mapRoutes(List<Page> pages) {
  return pages.fold(<String, WidgetBuilder>{}, (pre, page) {
    pre[page.title.toLowerCase()] = page.build;
    return pre;
  });
}
