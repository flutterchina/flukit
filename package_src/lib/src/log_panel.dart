import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'after_layout.dart';
import 'safe_value_notifier.dart';

ValueNotifier<LogInfo?>? _logEmitter;

ValueNotifier<LogInfo?> getGlobalLogEmitter() {
  _logEmitter ??= ValueNotifier<LogInfo?>(null);
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

typedef VerticalLogPanelBuilder = Widget Function(LogValueNotifier? listenable,
    BoxConstraints constraints, bool mergeDuplicateLogs);

class LogNotifier extends ValueNotifier<LogInfo> {
  LogNotifier(LogInfo value) : super(value);
}

class LogListener extends LogValueNotifier {
  LogListener(this.emitter, [List<LogInfo>? value])
      : super(value ?? <LogInfo>[]);

  static const logEvent = '_log';

  bool _listen = false;
  final ValueNotifier<LogInfo?> emitter;

  void callback() {
    if (emitter.value != null) {
      value.add(emitter.value!);
      notifyListeners();
    }
  }

  void on() {
    if (_listen) return;
    _listen = true;
    emitter.addListener(callback);
  }

  void off() {
    if (_listen) {
      emitter.removeListener(callback);
      _listen = false;
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
  int times = 1;

  // we shouldn't override operator '==', since if the logs triggered before and
  // after are the same , the ValueNotifier<LogInfo?> can **not** notify again,
  // because the value doesn't change.
  // @override
  // bool operator ==(Object other) {
  //   if (identical(this, other)) return true;
  //   return (other is LogInfo) && error == other.error && text == other.text;
  // }
  // @override
  // int get hashCode => hashValues(error, text);

  bool isEqual(LogInfo? other) {
    if (other == null) return false;
    if (identical(this, other)) return true;
    return error == other.error && text == other.text;
  }
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
    this.logPanelBuilder = VerticalLogPanel.defaultLogBuilder,
    this.minHeight,
    this.child,
    this.mergeDuplicateLogs = true,
  }) : super(key: key);
  final Widget? child;

  /// Min height for log panel.
  final double? minHeight;

  /// Whether show log panel.
  final bool showLogPanel;

  /// Defaults to [defaultLogPanelBuilder], which use [LogPanel] directly.
  final VerticalLogPanelBuilder? logPanelBuilder;

  /// Merge adjacent duplicate logs
  final bool mergeDuplicateLogs;

  static Widget defaultLogBuilder(LogValueNotifier? listenable,
      BoxConstraints constraints, bool mergeDuplicateLogs) {
    return LogPanel(
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight,
      mergeDuplicateLogs: mergeDuplicateLogs,
    );
  }

  @override
  State<VerticalLogPanel> createState() => _VerticalLogPanelState();
}

class _VerticalLogPanelState extends State<VerticalLogPanel>
    with LogPanelMixin {
  @override
  LogPanelBuilder get logPanelBuilder {
    if (widget.logPanelBuilder != null) {
      return (a, b) {
        return widget.logPanelBuilder!(a, b, widget.mergeDuplicateLogs);
      };
    }
    return super.logPanelBuilder;
  }

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

  @override
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

  static LogListenerScopeState? of(BuildContext context) {
    return context.findAncestorStateOfType<LogListenerScopeState>();
  }

  @override
  LogListenerScopeState createState() => LogListenerScopeState();
}

class LogListenerScopeState extends LogState<LogListenerScope> {
  late LogListener _logListener;

  // 日志面板（位于子树中，默认是LogPanel）会缓存自身的高度
  double? storage;

  @override
  void initState() {
    _logListener = LogListener(widget.logEmitter);
    super.initState();
  }

  @override
  void didUpdateWidget(LogListenerScope oldWidget) {
    if (oldWidget.logEmitter != widget.logEmitter) {
      _logListener = LogListener(widget.logEmitter);
      _logListener.on();
    }
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
    this.mergeDuplicateLogs = true,
    this.itemBuilder = LogPanel.defaultItemBuilder,
  }) : super(key: key);

  final double minHeight;
  final double maxHeight;
  final LogValueNotifier? listenable;
  final LogItemBuilder itemBuilder;

  /// Merge adjacent duplicate logs
  final bool mergeDuplicateLogs;

  static Widget defaultItemBuilder(
      BuildContext context, LogInfo logInfo, bool isFullScreen) {
    Widget? times;

    if (logInfo.times > 1) {
      times = DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: Text('${logInfo.times}', textScaleFactor: 0.9),
        ),
      );
    }

    return ListTile(
      title: Text(
        logInfo.text,
        style: TextStyle(color: logInfo.error ? Colors.red : null),
      ),
      trailing: times,
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
  late LogValueNotifier _originalListenable;
  LogInfo? _last;

  //每一次都从该位置开始处理
  late int _lastLength;

  bool get _canExpanded => widget.maxHeight - _height > .0001;

  bool get _draggable => widget.maxHeight - widget.minHeight > 0.0001;

  set height(double v) {
    _height = v.clamp(widget.minHeight, widget.maxHeight);
    final scope = LogListenerScope.of(context);
    if (scope != null) {
      scope.storage = _height;
    }
  }

  void _jumpToListEnd() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
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

  //合并相邻重复日志
  void _mergeLog() {
    final list = _originalListenable.value;
    if (list.isEmpty) {
      _last = null;
      _lastLength = 0;
      _listenable.value.clear();
    } else {
      /**
       * 对新接收的日志进行批量处理。因为并不是每捕获一次日志就能执行到这里，比如在 build 过程捕获到
       * 日志时会等到 frame 快结束时才通知，所以这段时间可能会捕获多条日志，关于通知时机可以参考
       * [SafeValueNotifier]。
       **/

      // 先判断是否所有的日志都已经处理过了，如果时则直接返回，避免通知ValueListenableBuilder
      // 进行不必要的build.
      if (_lastLength == list.length) {
        return;
      }
      // 对重复日志进行合并
      final newLogs = list.sublist(_lastLength, list.length).fold(
        <LogInfo>[],
        (List<LogInfo> previousValue, element) {
          if (_last == null) {
            _last = element..times = 1;
            return previousValue..add(_last!);
          } else {
            if (_last!.isEqual(element)) {
              //如果日志和上一条相同，则更新上一条日志的times
              _last!.times++;
              return previousValue;
            }
            //和上一条不同
            _last = element..times = 1;
            return previousValue..add(_last!);
          }
        },
      );
      _lastLength = list.length;
      _listenable.value.addAll(newLogs);
    }
    // 因为通知者已经保证在能安全更新UI的时机触发通知，此函数作为通知回调所以被执行时是可以安全
    // 更新UI的，因此，我们直接通知ValueListenableBuilder更新。
    _listenable.notifyListenersUnsafe();
  }

  _init(LogValueNotifier? listenable) {
    assert(
      listenable != null,
      '[listenable] required! Consider [LogListenerScope] as an ancestor widget.',
    );
    _originalListenable = listenable!;
    _lastLength = 0;
    _last = null;
    if (widget.mergeDuplicateLogs) {
      _listenable = LogValueNotifier();
      _originalListenable.addListener(_mergeLog);
      // 可能_originalListenable已经有日志了，先触发一次合并
      _originalListenable.notifyListeners();
    } else {
      _listenable = _originalListenable;
    }
    _listenable.addListener(_jumpToListEnd);
  }

  @override
  void initState() {
    final scope = LogListenerScope.of(context);
    height = scope?.storage ?? widget.minHeight;
    _init(widget.listenable ?? scope?.logListener);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LogPanel oldWidget) {
    final listenable =
        widget.listenable ?? LogListenerScope.of(context)?.logListener;
    if (widget.mergeDuplicateLogs != oldWidget.mergeDuplicateLogs ||
        _originalListenable != listenable) {
      _originalListenable.removeListener(_mergeLog);
      _listenable.removeListener(_jumpToListEnd);
      _init(listenable);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _originalListenable.removeListener(_mergeLog);
    _listenable.removeListener(_jumpToListEnd);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //触发setter，setter中会根据最大最小高度调整日志面板高度。
    height = _height;
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
        const Text('  日志', style: TextStyle(fontWeight: FontWeight.bold)),
        if (_draggable)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                var newHeight = _height - details.delta.dy;
                if (newHeight != _height) {
                  setState(() {
                    height = newHeight;
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
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          )
        else
          const Spacer(),
        IconButton(
          onPressed: () {
            // 清空日志
            _originalListenable.value.clear();
            _listenable.value.clear();
            // 触发_mergeLog执行，最终会通知 ValueListenableBuilder 重新 build
            _originalListenable.notifyListenersUnsafe();
          },
          icon: const Icon(Icons.delete_outline),
        ),
        IconButton(
          onPressed: () => _openFullScreen(context),
          icon: const Icon(Icons.fullscreen_exit_sharp),
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
          separatorBuilder: (_, b) => const Divider(height: 0),
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
            appBar: AppBar(title: const Text('日志')),
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
