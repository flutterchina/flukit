import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';

class AnimatedRotationBoxRoute extends StatelessWidget {
  const AnimatedRotationBoxRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.secondary, size: 30.0),
        ),
        child: Wrap(
          spacing: 16.0,
          alignment: WrapAlignment.center,
          runSpacing: 16.0,
          children: <Widget>[
            AnimatedRotationBox(
              child: GradientCircularProgressIndicator(
                radius: 15.0,
                colors: [
                  Colors.red.shade300,
                  Colors.orange,
                  Colors.grey.shade50
                ],
                value: .8,
                backgroundColor: Colors.transparent,
              ),
            ),
            const AnimatedRotationBox(
              child: GradientCircularProgressIndicator(
                radius: 15.0,
                colors: [Colors.red, Colors.red],
                value: .7,
                backgroundColor: Colors.transparent,
              ),
            ),
            AnimatedRotationBox(
              duration: const Duration(milliseconds: 800),
              child: GradientCircularProgressIndicator(
                radius: 15.0,
                colors: [Colors.blue, Colors.lightBlue.shade50],
                value: .8,
                backgroundColor: Colors.transparent,
                strokeCapRound: true,
              ),
            ),
            // Icon
            const AnimatedRotationBox(
              duration: Duration(milliseconds: 800),
              child: Icon(Icons.loop),
            ),
            AnimatedRotationBox(
              child: GradientCircularProgressIndicator(
                colors: [
                  Colors.red,
                  Colors.amber,
                  Colors.cyan,
                  Colors.green.shade200,
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
  static const IconData loading0 =
      IconData(0xe65e, fontFamily: 'myIcon', matchTextDirection: true);

  static const IconData loading1 =
      IconData(0xe61c, fontFamily: 'myIcon', matchTextDirection: true);

  static const IconData loading2 =
      IconData(0xe61f, fontFamily: 'myIcon', matchTextDirection: true);
  static const IconData loading3 =
      IconData(0xe68f, fontFamily: 'myIcon', matchTextDirection: true);
}
