import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'after_layout.dart';
import 'safe_value_notifier.dart';

ValueNotifier<LogInfo?>? _logEmitter;

ValueNotifier<LogInfo?> getGlobalLogEmitter() {
  if (_logEmitter == null) {
    _logEmitter = ValueNotifier<LogInfo?>(null);
  }
  return _logEmitter!;
}

class LogValueNotifier extends SafeValueNotifier<List<LogInfo>> {
  LogValueNotifier([List<LogInfo>? value]) : super(value ?? <LogInfo>[]);

  void clear() {
    if (value.isNotEmpty) {
      value.clear();
      notifyListeners();
    }
  }
}

typedef LogPanelBuilder = Widget Function(
    LogValueNotifier? listenable, BoxConstraints constraints);

class LogNotifier extends ValueNotifier<LogInfo> {
  LogNotifier(LogInfo value) : super(value);
}

class LogListener extends LogValueNotifier {
  LogListener(this.emitter, [List<LogInfo>? value])
      : super(value ?? <LogInfo>[]);

  static const logEvent = '_log';

  bool listen = false;
  final ValueNotifier<LogInfo?> emitter;

  void callback() {
    if (emitter.value != null) {
      value.add(emitter.value!);
      notifyListeners();
    }
  }

  void on() {
    if (listen) return;
    listen = true;
    emitter.addListener(callback);
  }

  void off() {
    if (listen) {
      emitter.removeListener(callback);
      listen = false;
    }
  }

  void clear() {
    if (value.isNotEmpty) {
      value.clear();
      notifyListeners();
    }
  }

  void print(Object obj) {
    Zone.root.print(obj.toString());
  }
}

class LogInfo {
  LogInfo(this.error, this.text);

  bool error = false;
  String text;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return (other is LogInfo) && error == other.error && text == other.text;
  }

  @override
  int get hashCode => hashValues(error, text);
}

Widget defaultLogPanelBuilder(
    LogValueNotifier? listenable, BoxConstraints constraints) {
  return LogPanel(
    minHeight: constraints.minHeight,
    maxHeight: constraints.maxHeight,
    listenable: listenable,
  );
}

mixin LogPanelMixin {
  LogValueNotifier? get logNotifier => null;

  double? _maxHeight;

  LogPanelBuilder get logPanelBuilder => defaultLogPanelBuilder;

  Widget buildLogPanel(
    Widget child, {
    bool showLogPanel = true,
    double? minHeight,
  }) {
    if (!showLogPanel) return child;
    return LayoutBuilder(builder: (context, constraints) {
      child = MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: child,
      );
      minHeight = minHeight ?? (constraints.maxHeight / 3);
      _maxHeight = _maxHeight ?? minHeight!;
      //Zone.root.print('LayoutBuilder');
      return StatefulBuilder(builder: (context, setState) {
        return Stack(
          children: [
            Positioned(
              top: 0,
              child: AfterLayout(
                callback: (RenderAfterLayout ral) {
                  final newMaxLogHeight =
                      constraints.maxHeight - ral.size.height;
                  // newMaxLogHeight:274.33333333333326, minHeight:274.3333333333333
                  // newMaxLogHeight may less than minHeight a bit.
                  if (newMaxLogHeight - minHeight! >= 0 &&
                      _maxHeight != newMaxLogHeight) {
                    setState(() => _maxHeight = newMaxLogHeight);
                  }
                },
                child: ConstrainedBox(
                  constraints: constraints.copyWith(
                    minHeight: 0,
                    maxHeight: constraints.maxHeight - minHeight!,
                  ),
                  // 防止绘制阶段调用print显示log而触发重绘导致死循环。
                  child: RepaintBoundary(child: child),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: Builder(
                  builder: (context) {
                    return MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: logPanelBuilder(
                        logNotifier,
                        constraints.copyWith(
                          minHeight: minHeight,
                          maxHeight: _maxHeight,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      });
    });
  }
}

/// A widget to show redirected logs from `print`, which will divide the available
/// display space vertically into two areas, and display the logs  below.
///
/// [VerticalLogPanel] must be used in combination with [LogListenerScope](as an ancestor).
///
/// The height of [LogPanel] can be adjusted by dragging between [minHeight] and [maxHeight].
///
/// [listenable]: LogValueNotifier which passed redirected logs from [print] to [LogPanel].
///               If there is an ancestor [LogListenerScope] widget, [listenable] will be
///               not required, [LogPanel] will use the listenable provided by [LogListenerScope].
/// [logPanelBuilder]: Building a widget to display logs( It's called the log panel), there is a
///                    default builder [_defaultLogBuilder], which create a [LogPanel] widget directly.
/// [minHeight]: Min height for log panel.
///
/// See also [LogPanel]
class VerticalLogPanel extends StatefulWidget {
  const VerticalLogPanel({
    Key? key,
    this.showLogPanel = true,
    this.logPanelBuilder,
    this.minHeight,
    this.child,
  }) : super(key: key);
  final Widget? child;

  /// Min height for log panel.
  final double? minHeight;

  /// Whether show log panel.
  final bool showLogPanel;

  /// Defaults to [defaultLogPanelBuilder], which use [LogPanel] directly.
  final LogPanelBuilder? logPanelBuilder;

  @override
  State<VerticalLogPanel> createState() => _VerticalLogPanelState();
}

class _VerticalLogPanelState extends State<VerticalLogPanel>
    with LogPanelMixin {
  @override
  LogPanelBuilder get logPanelBuilder =>
      widget.logPanelBuilder ?? super.logPanelBuilder;

  @override
  Widget build(BuildContext context) {
    return buildLogPanel(
      widget.child ?? Container(),
      showLogPanel: widget.showLogPanel,
      minHeight: widget.minHeight,
    );
  }
}

abstract class LogState<T extends StatefulWidget> extends State<T>
    with LogPanelMixin {
  LogListener get logListener;

  get logNotifier => logListener;

  @override
  void initState() {
    logListener.on();
    super.initState();
  }

  @override
  void activate() {
    logListener.on();
    super.activate();
  }

  @override
  void deactivate() {
    logListener.off();
    super.deactivate();
  }

  @override
  void reassemble() {
    logListener.clear();
    super.reassemble();
  }

  @override
  void dispose() {
    logListener.off();
    super.dispose();
  }
}

/// A stateful widget to listen redirected log events.
///
/// This widget will start listening log events when `initState` and `activate`
/// are called, and stop when `deactivate` is called.
///
/// [logEmitter]: Log event emitter。
///
/// example:
/// ```dart
///
/// final logEmitter = ValueNotifier<LogInfo?>(null);
///
/// void main() {
///   runZoned(
///     () => runApp(MyApp()),
///     zoneSpecification: ZoneSpecification(
///       print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
///         parent.print(zone, "$line");
///         // Intercept `print` function and redirect log.
///         logEmitter.value = LogInfo(false, line);
///       },
///      handleUncaughtError: (Zone self, ZoneDelegate parent, Zone zone,
///           Object error, StackTrace stackTrace) {
///         parent.print(zone, '${error.toString()} $stackTrace');
///         // Redirect error log event when error.
///         logEmitter.value = LogInfo(true, error.toString());
///       },
///     ),
///   );
///
///   var onError = FlutterError.onError;
///   FlutterError.onError = (FlutterErrorDetails details) {
///     onError?.call(details);
///     // Redirect error log event when error.
///     logEmitter.value = LogInfo(true, details.toString());
///   };
/// }
///
/// ...
class LogListenerScope extends StatefulWidget {
  const LogListenerScope({
    Key? key,
    this.showLogPanel = false,
    required this.logEmitter,
    required this.child,
    this.logPanelBuilder,
  }) : super(key: key);

  final Widget child;

  /// typically false
  final bool showLogPanel;

  final ValueNotifier<LogInfo?> logEmitter;

  final LogPanelBuilder? logPanelBuilder;

  static LogValueNotifier? of(BuildContext context) {
    return context
        .findAncestorStateOfType<_LogListenerScopeState>()
        ?.logNotifier;
  }

  @override
  _LogListenerScopeState createState() => _LogListenerScopeState();
}

class _LogListenerScopeState extends LogState<LogListenerScope> {
  late LogListener _logListener;

  @override
  void initState() {
    _logListener = LogListener(widget.logEmitter);
    super.initState();
  }

  @override
  void didUpdateWidget(LogListenerScope oldWidget) {
    _logListener = LogListener(widget.logEmitter);
    super.didUpdateWidget(oldWidget);
  }

  @override
  LogListener get logListener => _logListener;

  @override
  LogPanelBuilder get logPanelBuilder =>
      widget.logPanelBuilder ?? super.logPanelBuilder;

  @override
  Widget build(BuildContext context) {
    return super.buildLogPanel(
      widget.child,
      showLogPanel: widget.showLogPanel,
    );
  }
}

typedef LogItemBuilder = Widget Function(
    BuildContext context, LogInfo logInfo, bool isFullScreen);

/// A widget to show redirected logs from `print`.
///
/// Typically, [LogPanel] is used in combination with [LogListenerScope] or [VerticalLogPanel].
/// The height of [LogPanel] can be adjusted by dragging between [minHeight] and [maxHeight].
///
/// [listenable]: LogValueNotifier which passed redirected logs from `print` to [LogPanel].
///               If there is an ancestor [LogListenerScope] widget, [listenable] will be
///               not required, [LogPanel] will use the listenable provided by [LogListenerScope].
/// [itemBuilder]: Redirected Logs will be shown in ListView, so [itemBuilder] is used for customizing
///                item appearance. [_defaultItemBuilder] will be used by default.
///
/// See also [VerticalLogPanel].
class LogPanel extends StatefulWidget {
  const LogPanel({
    Key? key,
    required this.minHeight,
    this.maxHeight = double.infinity,
    this.listenable,
    this.itemBuilder = LogPanel.defaultItemBuilder,
  }) : super(key: key);

  final double minHeight;
  final double maxHeight;
  final LogValueNotifier? listenable;
  final LogItemBuilder itemBuilder;

  static Widget defaultItemBuilder(
      BuildContext context, LogInfo logInfo, bool isFullScreen) {
    return ListTile(
      title: Text(
        logInfo.text,
        style: TextStyle(color: logInfo.error ? Colors.red : null),
      ),
      dense: !isFullScreen,
    );
  }

  @override
  _LogPanelState createState() => _LogPanelState();
}

class _LogPanelState extends State<LogPanel> {
  final _controller = ScrollController();
  double _height = 0;
  bool _drag = false;
  late LogValueNotifier _listenable;

  bool get _canExpanded => widget.maxHeight - _height > .0001;

  bool get _draggable => widget.maxHeight - widget.minHeight > 0.0001;

  void _jumpToListEnd() {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        _controller.jumpTo(
          _controller.position.maxScrollExtent,
        );
      }
    });
    _controller.jumpTo(
      _controller.position.maxScrollExtent,
    );
  }

  @override
  void initState() {
    _height = widget.minHeight;
    final listenable = widget.listenable ?? LogListenerScope.of(context);
    assert(
      listenable != null,
      '[listenable] required! Consider [LogListenerScope] as an ancestor widget.',
    );
    _listenable = listenable!;
    _listenable.addListener(_jumpToListEnd);
    super.initState();
  }

  @override
  void dispose() {
    _listenable.removeListener(_jumpToListEnd);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _height = _height.clamp(widget.minHeight, widget.maxHeight);
    return Material(
      child: SizedBox(
        height: _height,
        child: Column(
          children: [wTools(context), Expanded(child: wLogList())],
        ),
      ),
    );
  }

  Widget wTools(BuildContext context) {
    dragEnd(details) {
      if (_drag) {
        setState(() {
          _drag = false;
        });
      }
    }

    return Material(
      color: _drag ? Colors.blue.shade100 : Colors.grey.shade100,
      elevation: 1,
      child: Row(children: [
        Text('  日志', style: TextStyle(fontWeight: FontWeight.bold)),
        if (_draggable)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                var newHeight = _height - details.delta.dy;
                if (newHeight != _height) {
                  setState(() {
                    _height = newHeight;
                  });
                }
              },
              onVerticalDragDown: (details) {
                if (_draggable) {
                  setState(() {
                    _drag = true;
                  });
                }
              },
              onVerticalDragEnd: dragEnd,
              onVerticalDragCancel: () => dragEnd(null),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Text(
                    _canExpanded ? '向上拖动可增大日志显示空间' : '向下拖动可缩小日志显示空间',
                    textScaleFactor: .9,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          )
        else
          Spacer(),
        IconButton(
          onPressed: () => _listenable.clear(),
          icon: Icon(Icons.delete_outline),
        ),
        IconButton(
          onPressed: () => _openFullScreen(context),
          icon: Icon(Icons.fullscreen_exit_sharp),
        ),
      ]),
    );
  }

  Widget wLogList([bool fullScreen = false]) {
    Widget child = ValueListenableBuilder<List<LogInfo>>(
      valueListenable: _listenable,
      builder: (BuildContext context, value, Widget? child) {
        return ListView.separated(
          controller: fullScreen ? null : _controller,
          itemCount: value.length,
          itemBuilder: (context, index) {
            return widget.itemBuilder(context, value[index], fullScreen);
          },
          separatorBuilder: (_, b) => Divider(height: 0),
        );
      },
    );
    return Scrollbar(
      controller: fullScreen ? null : _controller,
      child: child,
    );
  }

  _openFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: Text('日志')),
            body: wLogList(true),
          );
        },
      ),
    );
  }

  void print(Object obj) {
    Zone.root.print(obj.toString());
  }
}
