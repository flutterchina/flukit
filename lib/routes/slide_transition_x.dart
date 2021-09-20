import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class SlideTransitionXRoute extends StatefulWidget {
  @override
  _SlideTransitionXRouteState createState() => _SlideTransitionXRouteState();
}

class _SlideTransitionXRouteState extends State<SlideTransitionXRoute> {
  int _score1 = 0;
  int _score2 = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Score(<100)'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRect(child: wSwitcher(_score1)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10,0,10,5),
              child: Text(':', textScaleFactor: 2),
            ),
            ClipRect(child: wSwitcher(_score2)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            wButton(() => ++_score1),
            wButton(() => ++_score2),
          ],
        ),
      ],
    );
  }

  Widget wButton(VoidCallback fun) {
    return TextButton(
      child: Text('+1'),
      onPressed: () {
        setState(fun);
      },
    );
  }

  Widget wSwitcher(int score) {
    return SizedBox(
      width: 60,
      child: Center(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransitionX(
              child: FadeTransition(child: child, opacity: animation),
              direction: AxisDirection.down,
              position: animation,
            );
          },
          child: Text(
            "$score",
            key: ValueKey<int>(score),
            textScaleFactor: 3,
          ),
        ),
      ),
    );
  }
}

