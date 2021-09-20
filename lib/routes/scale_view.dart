import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';

class ScaleViewRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Swiper(
      autoStart: false,
      circular: false,
      indicator: CircleSwiperIndicator(
        padding: EdgeInsets.only(bottom: 30.0),
        itemColor: Colors.black26,
      ),
      children: <Widget>[
        Image.asset("imgs/sea.png", fit: BoxFit.fill),
        Image.asset("imgs/avatar.png", fit: BoxFit.fill),
        Image.asset("imgs/star.jpg", fit: BoxFit.fill),
        Image.asset("imgs/cat.jpg", fit: BoxFit.fill),
      ].map((v) {
        // 支持双击、缩放手势
        return ScaleView(
          child: v,
          minScale: .5,
          maxScale: 3,
        );
      }).toList(),
    );
  }
}
