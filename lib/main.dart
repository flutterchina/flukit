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
  const MyHomePage({
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
          Page("PullRefresh", const PullRefreshRoute()),

          Page("Quick Scrollbar", const QuickScrollbarRoute()),
          Page("Swiper", SwiperRoute()),
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
        ],
      ),
    );
  }
}
