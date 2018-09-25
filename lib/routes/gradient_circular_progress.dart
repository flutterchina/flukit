import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';

class GradientCircularProgressRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedRotationBox(
                  child: GradientCircularProgressIndicator(
                    radius: 15.0,
                    colors: [Colors.red[300],Colors.orange,Colors.grey[50]],
                    value: .8,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                AnimatedRotationBox(
                  child: GradientCircularProgressIndicator(
                    radius: 15.0,
                    colors: [Colors.red,Colors.red],
                    value: .8,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                AnimatedRotationBox(
                  duration: Duration(milliseconds: 800),
                  child: GradientCircularProgressIndicator(
                    radius: 15.0,
                    colors: [Colors.blue[400],Colors.lightBlue[200],Colors.grey[50]],
                    value: .9,
                    backgroundColor: Colors.transparent,
                    strokeCapRound: true,
                  ),
                ),
              ],
            ),
          ),
          AnimatedRotationBox(
            child: GradientCircularProgressIndicator(
              colors: [Colors.red,Colors.amber,Colors.cyan,Colors.green[200],Colors.blue,Colors.red ],
              radius: 60.0,
              stokeWidth: 5.0,
              strokeCapRound: true,
              backgroundColor: Colors.transparent,
              //value: .8,
            ),
          ),
          GradientCircularProgressIndicator(
            colors: [Colors.red,Colors.amber,Colors.cyan,Colors.green[200],Colors.blue,Colors.red ],
            radius: 60.0,
            stokeWidth: 5.0,
            strokeCapRound: true,
            backgroundColor: Colors.transparent,
            value: .8,
          ),

          GradientCircularProgressIndicator(
            colors: [Colors.blue[700],Colors.blue[200]],
            radius: 100.0,
            stokeWidth: 20.0,
            value: .3,
          ),

          GradientCircularProgressIndicator(
            colors: [Colors.blue[700],Colors.blue[200]],
            radius: 100.0,
            stokeWidth: 20.0,
            value: .6,
            strokeCapRound: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: SizedBox(
              height: 104.0,
              width: 200.0,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    height: 200.0,
                    top: .0,
                    child: TurnBox(
                      turns: .75,
                      child: GradientCircularProgressIndicator(
                        colors: [Colors.teal[700],Colors.cyan[500]],
                        radius: 100.0,
                        stokeWidth: 5.0,
                        value: .5,
                        totalAngle: pi,
                        strokeCapRound: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text("50%",
                      style: TextStyle(fontSize: 25.0, color: Colors.blueGrey),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}






