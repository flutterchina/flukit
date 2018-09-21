import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';


class SwiperRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Swiper(
                indicatorAlignment: AlignmentDirectional.bottomEnd,
                speed: 400,
                indicator: CircleSwiperIndicator(),
                children: <Widget>[
                  Image.asset("images/sea.png",fit: BoxFit.fill,),
                  Image.asset("images/star.jpg", fit: BoxFit.fill),
                  Image.asset("images/cat.jpg",fit: BoxFit.fill,),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: SizedBox(
                height: 200.0,
                child: Swiper(
                  circular: true,
                  reverse: true, //反向
                  indicator: RectangleSwiperIndicator(),
                  children: <Widget>[
                    Image.asset("images/sea.png",fit: BoxFit.fill,),
                    Image.asset("images/star.jpg", fit: BoxFit.fill),
                    Image.asset("images/cat.jpg",fit: BoxFit.fill,),
                    Image.asset("images/horse.jpg", fit: BoxFit.fill),
                    Image.asset("images/road.jpg",fit: BoxFit.fill,),
                  ],
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Swiper(
                indicatorAlignment: AlignmentDirectional.topEnd,
                circular: true,
                indicator: NumberSwiperIndicator(),
                children: <Widget>[
                  Image.asset("images/sea.png",fit: BoxFit.fill,),
                  Image.asset("images/star.jpg", fit: BoxFit.fill),
                  Image.asset("images/cat.jpg",fit: BoxFit.fill,),
                  Image.asset("images/horse.jpg", fit: BoxFit.fill),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberSwiperIndicator extends SwiperIndicator{
  @override
  Widget build(BuildContext context, int index, int itemCount) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20.0)
      ),
      margin: EdgeInsets.only(top: 10.0,right: 5.0),
      padding: EdgeInsets.symmetric(horizontal: 6.0,vertical: 2.0),
      child: Text("${++index}/$itemCount", style: TextStyle(color: Colors.white70, fontSize: 11.0)),
    );
  }
}
