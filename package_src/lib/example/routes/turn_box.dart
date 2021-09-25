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
            child: const Icon(Icons.refresh),
          ),
          TurnBox(
            turns: _turns,
            speed: 400,
            child: const Icon(Icons.refresh, size: 50.0,),
          ),
          TurnBox(
            turns: _turns,
            speed: 200,
            child: const TurnBox(
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
          ElevatedButton(
            child: const Text("Clockwise"),
            onPressed: () {
              setState(() {
                _turns += .25;
              });
            },
          ),
          ElevatedButton(
            child: const Text("Anti-clockwise"),
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
