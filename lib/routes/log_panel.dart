import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class LogListenerScopeRoute extends StatelessWidget {
  const LogListenerScopeRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /* Use LogListenerScope as root widget for route */
    return LogListenerScope(
      logEmitter: getGlobalLogEmitter(),
      child: PageWithLogPanel(),
    );
  }
}

class PageWithLogPanel extends StatefulWidget {
  const PageWithLogPanel({Key? key}) : super(key: key);

  @override
  _PageWithLogPanelState createState() => _PageWithLogPanelState();
}

class _PageWithLogPanelState extends State<PageWithLogPanel> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      appBar: AppBar(title: const Text('Log Panel')),
      // vertical log panel
      body: VerticalLogPanel(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$_counter',textScaleFactor: 1.3),
                  GradientButton(
                    onPressed: () {
                      setState(() {
                        ++_counter;
                        // print log
                        print(_counter);
                      });
                    },
                    child: Text('+1'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
