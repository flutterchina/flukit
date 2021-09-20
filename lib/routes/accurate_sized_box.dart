import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class AccurateSizedBoxRoute extends StatelessWidget {
  const AccurateSizedBoxRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: () => print("tap"),
      child: Container(width: 300, height: 300, color: Colors.red),
    );
    return Row(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints.tight(Size(100, 100)),
          // Actually, the child size will be 100×100.
          child: SizedBox(
            width: 50,
            height: 50,
            child: child,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(Size(100, 100)),
            // The child size will be 50×50.
            child: AccurateSizedBox(
              width: 50,
              height: 50,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
