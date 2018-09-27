import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';


class AnimatedRotationBoxRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(
              color: Theme
                  .of(context)
                  .accentColor,
             size: 30.0
          ),
        ),
        child: Wrap(
          spacing: 16.0,
          alignment: WrapAlignment.center,
          runSpacing: 16.0,
          children: <Widget>[
            AnimatedRotationBox(
              child: GradientCircularProgressIndicator(
                radius: 15.0,
                colors: [Colors.red[300], Colors.orange, Colors.grey[50]],
                value: .8,
                backgroundColor: Colors.transparent,
              ),
            ),
            AnimatedRotationBox(
              child: GradientCircularProgressIndicator(
                radius: 15.0,
                colors: [Colors.red, Colors.red],
                value: .7,
                backgroundColor: Colors.transparent,
              ),
            ),
            AnimatedRotationBox(
              duration: Duration(milliseconds: 800),
              child: GradientCircularProgressIndicator(
                radius: 15.0,
                colors: [Colors.blue, Colors.lightBlue[50]],
                value: .8,
                backgroundColor: Colors.transparent,
                strokeCapRound: true,
              ),
            ),
            // Icon
            AnimatedRotationBox(
              duration: Duration(milliseconds: 800),
              child: Icon(Icons.loop),
            ),
            AnimatedRotationBox(
              duration: Duration(milliseconds: 800),
              child: Icon(MyIcons.loading0),
            ),
            AnimatedRotationBox(
              duration: Duration(milliseconds: 800),
              child: Icon(MyIcons.loading1),
            ),
            AnimatedRotationBox(
              duration: Duration(milliseconds: 800),
              child: Icon(MyIcons.loading2),
            ),
            AnimatedRotationBox(
              duration: Duration(milliseconds: 1200),
              child: Icon(MyIcons.loading3,),
            ),
            AnimatedRotationBox(
              child: GradientCircularProgressIndicator(
                colors: [
                  Colors.red,
                  Colors.amber,
                  Colors.cyan,
                  Colors.green[200],
                  Colors.blue,
                  Colors.red
                ],
                radius: 60.0,
                stokeWidth: 5.0,
                strokeCapRound: true,
                backgroundColor: Colors.transparent,
                value: 1.0,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class MyIcons {

  static const IconData loading0 = const IconData(
      0xe65e,
      fontFamily: 'myIcon',
      matchTextDirection: true
  );

  static const IconData loading1 = const IconData(
      0xe61c,
      fontFamily: 'myIcon',
      matchTextDirection: true
  );

  static const IconData loading2 = const IconData(
      0xe61f,
      fontFamily: 'myIcon',
      matchTextDirection: true
  );
  static const IconData loading3 = const IconData(
      0xe68f,
      fontFamily: 'myIcon',
      matchTextDirection: true
  );
}