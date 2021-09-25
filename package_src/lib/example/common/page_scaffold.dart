import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class PageScaffold extends StatefulWidget {
  const PageScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.padding = false,
    this.showLog = false,
  }) : super(key: key);

  final String title;
  final Widget body;
  final bool padding;
  final bool showLog;

  @override
  State<PageScaffold> createState() => _PageScaffoldState();
}

class _PageScaffoldState extends State<PageScaffold> {
  late bool _showLog;

  @override
  void initState() {
    _showLog = widget.showLog;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PageScaffold oldWidget) {
    if (oldWidget.showLog != widget.showLog) {
      _showLog = widget.showLog;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showLog = !_showLog;
              });
            },
            icon: const Icon(Icons.print),
          )
        ],
      ),
      body: VerticalLogPanel(
        showLogPanel: _showLog,
        child: wBody(),
      ),
    );
  }

  wBody() {
    return widget.padding
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: widget.body,
          )
        : widget.body;
  }
}

class Page {
  Page(
    this.title,
    Widget child, {
    this.withScaffold = true,
    this.padding = true,
    this.showLog = false,
  }) : builder = ((_) => child);

  Page.builder(
    this.title,
    this.builder, {
    this.withScaffold = true,
    this.padding = true,
    this.showLog = false,
  });

  String title;
  WidgetBuilder builder;
  bool withScaffold;
  bool padding;
  bool showLog;

  Widget build(BuildContext context) {
    Widget widget = builder(context);
    if (withScaffold) {
      widget = PageScaffold(
        title: title,
        padding: padding,
        showLog: showLog,
        body: widget,
      );
      widget = LogListenerScope(
        child: widget,
        logEmitter: getGlobalLogEmitter(),
      );
    } else if (showLog) {
      widget = VerticalLogPanel(child: widget);
      widget = LogListenerScope(
        child: widget,
        logEmitter: getGlobalLogEmitter(),
      );
    }
    return widget;
  }

  Future<T?> openPage<T>(BuildContext context) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute<T>(builder: build),
    );
  }
}

class ListPage extends StatelessWidget {
  const ListPage({
    Key? key,
    required this.children,
  }) : super(key: key);

  final List<Page> children;

  @override
  Widget build(BuildContext context) {
    return ListView(children: _generateItem(context));
  }

  List<Widget> _generateItem(BuildContext context) {
    return children.map<Widget>((page) {
      return ListTile(
        title: Text(page.title),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () => page.openPage(context),
      );
    }).toList();
  }
}
