import 'package:flutter/widgets.dart';

/// A helper widget which can print constraints information in debug mode.
class LayoutLogPrint<T> extends StatelessWidget {
  const LayoutLogPrint({
    Key? key,
    this.show = true,
    this.tag,
    this.debugPrint = print,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final bool show;
  final Function(Object? object) debugPrint;
  final T? tag;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      assert(() {
        if (show) {
          debugPrint('${tag ?? key ?? child.runtimeType}: $constraints');
        }
        return true;
      }());
      return child;
    });
  }
}
