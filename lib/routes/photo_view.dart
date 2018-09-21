import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';

class PhotoViewRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Swiper(
      autoStart: false,
      circular: true,
      direction: Axis.vertical,
      indicator: CircleSwiperIndicator(
        padding: EdgeInsets.only(bottom: 30.0),
        itemColor: Colors.black26,
      ),
      children: <Widget>[
        Image.asset("images/sea.png", fit: BoxFit.fill,),
        Image.asset("images/avatar.png", fit: BoxFit.fill),
        Image.asset("images/star.jpg", fit: BoxFit.fill),
        Image.asset("images/cat.jpg", fit: BoxFit.fill,),
        Image.asset("images/horse.jpg", fit: BoxFit.fill),
        Image.asset("images/road.jpg", fit: BoxFit.fill)
      ].map((v) {
        return ScaleView(child: v, parentScrollableAxis: Axis.vertical);
      }).toList(),
    );
  }
}
