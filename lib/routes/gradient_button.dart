import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class GradientButtonRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GradientButton(
          colors: [Colors.orange, Colors.red],
          child: Text("Submit"),
          onPressed: onTap,
        ),
        ElevatedGradientButton(
          colors: [Colors.orange, Colors.red],
          child: Text("Submit"),
          onPressed: onTap,
        ),
        GradientButton(
          child: Text("Submit"),
          onPressed: onTap,
          borderRadius: BorderRadius.circular(30),
        ),
        ElevatedGradientButton(
          child: Text("Submit"),
          onPressed: onTap,
          borderRadius: BorderRadius.circular(30),
        ),
        SizedBox(
          width: double.infinity,
          height: 48,
          child:  GradientButton(
            colors: [Colors.lightGreen, Colors.green.shade700],
            child: Text("Submit"),
            onPressed: onTap,
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 48,
          child:  ElevatedGradientButton(
            colors: [Colors.lightGreen, Colors.green.shade700],
            child: Text("Submit"),
            onPressed: onTap,
          ),
        ),
        ElevatedGradientButton(
          child: Text("Submit"),
          //onPressed: onTap,
        ),
      ].map((e) {
        return Padding(
          padding: EdgeInsets.all(8),
          child: e,
        );
      }).toList(),
    );
  }

  onTap() {
    print("button click");
  }
}
