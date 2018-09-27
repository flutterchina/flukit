import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';

class TurnBoxRoute extends StatefulWidget {
  @override
  _TurnBoxRouteState createState() => new _TurnBoxRouteState();
}

class _TurnBoxRouteState extends State<TurnBoxRoute> {
  double _turns = .0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          TurnBox(
            turns: _turns,
            speed: 600,
            child: Icon(Icons.refresh),
          ),
          TurnBox(
            turns: _turns,
            speed: 400,
            child: Icon(Icons.refresh, size: 50.0,),
          ),
          TurnBox(
            turns: _turns,
            speed: 200,
            child: TurnBox(
              turns: 1/8,
              child: GradientCircularProgressIndicator(
                radius: 60.0,
                value: 1.0,
                stokeWidth: 5.0,
                strokeCapRound: true,
                totalAngle: 1.5*pi,
                colors: [Colors.red, Colors.orange, Colors.red],
              ),
            ),
          ),
          RaisedButton(
            child: Text("Clockwise"),
            onPressed: () {
              setState(() {
                _turns += .25;
              });
            },
          ),
          RaisedButton(
            child: Text("Anti-clockwise"),
            onPressed: () {
              setState(() {
                _turns -= .25;
              });
            },
          )
        ],
      ),
    );
  }
}
