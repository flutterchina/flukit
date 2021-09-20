import 'dart:async';
import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart' hide Page;
import 'common/index.dart';
import 'routes/index.dart';

void main() {
  final logEmitter = getGlobalLogEmitter();
  runZoned(
    () => runApp(MyApp()),
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        parent.print(zone, "$line");
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flukit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flukit demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListPage(
        children: [
          Page("AfterLayout", AfterLayoutRoute(), showLog: true),
          Page("AccurateSizedBox", AccurateSizedBoxRoute(), showLog: true),
          Page("AnimatedRotationBox", AnimatedRotationBoxRoute()),
          Page("DoneWidget", DoneWidgetRoute()),
          Page("GradientButton", GradientButtonRoute()),
          Page(
            "GradientCircularProgressIndicator",
            GradientCircularProgressRoute(),
          ),
          Page(
            "KeepAlive Test",
            KeepAliveTest(),
            padding: false,
            showLog: true,
          ),
          Page("LayoutLogPrint", LayoutLogPrintRoute(), showLog: true),
          Page("LeftRightBox", LeftRightBoxRoute()),
          Page("Log Panel", LogListenerScopeRoute(), withScaffold: false),
          Page("OverflowWithTranslateBox", OverflowWithTranslateRoute(), padding: false),
          Page("PullRefresh", PullRefreshRoute()),

          Page("Quick Scrollbar", QuickScrollbarRoute()),
          Page("Swiper", SwiperRoute()),
          Page("Swiper Style", SwiperStyleRoute()),
          Page("ScaleView", ScaleViewRoute(), padding: false),
          Page(
            "SliverFlexibleHeader",
            SliverFlexibleHeaderRoute(),
            padding: false,
          ),
          Page(
            "SliverHeaderDelegate",
            SliverHeaderDelegateRoute(),
            padding: false,
          ),
          Page(
            "SliverPersistentHeaderToBox",
            SliverPersistentHeaderToBoxRoute(),
            padding: false,
          ),
          Page("SlideTransitionX", SlideTransitionXRoute()),
          Page("TurnBox", TurnBoxRoute()),
          Page("WaterMark(水印)", WatermarkRoute(), padding: false),
          // Page("AzListView", (ctx) => QuickSelectListViewRoute()),
        ],
      ),
    );
  }
}
