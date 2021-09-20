import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';


class SwiperRoute extends StatelessWidget {
  final _imgs=["sea.png","star.jpg","cat.jpg","horse.jpg"];
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
                controller: SwiperController(initialPage: 1),
                viewportFraction: .95,
                indicator: CircleSwiperIndicator(),
                onChanged: (index)=>print(index),
                children: <Widget>[
                  Image.asset("imgs/sea.png",fit: BoxFit.fill,),
                  Image.asset("imgs/star.jpg", fit: BoxFit.fill),
                  Image.asset("imgs/cat.jpg",fit: BoxFit.fill,),
                ].map((e) => Padding(child: e,padding: EdgeInsets.symmetric(horizontal: 1))).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: SizedBox(
                height: 200.0,
                child: Swiper(
                  circular: true,
                  //reverse: true, //反向
                  indicator: RectangleSwiperIndicator(),
                  children: <Widget>[
                    Image.asset("imgs/sea.png",fit: BoxFit.fill,),
                    Image.asset("imgs/star.jpg", fit: BoxFit.fill),
                    Image.asset("imgs/cat.jpg",fit: BoxFit.fill,),
                    Image.asset("imgs/horse.jpg", fit: BoxFit.fill),
                    Image.asset("imgs/road.jpg",fit: BoxFit.fill,),
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
                  Image.asset("imgs/sea.png",fit: BoxFit.fill),
                  Image.asset("imgs/star.jpg", fit: BoxFit.fill),
                  Image.asset("imgs/cat.jpg",fit: BoxFit.fill),
                  Image.asset("imgs/horse.jpg", fit: BoxFit.fill),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 16.0 / 9.0,
              child: Swiper.builder(
                indicatorAlignment: AlignmentDirectional.topEnd,
                circular: true,
                childCount: _imgs.length,
                indicator: NumberSwiperIndicator(),
                itemBuilder: (context, index){
                  return Image.asset("imgs/${_imgs[index]}",fit: BoxFit.fill);
                },
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
