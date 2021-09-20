import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';

class SwiperStyleRoute extends StatefulWidget {
  @override
  _SwiperStyleRouteState createState() => new _SwiperStyleRouteState();
}

class _SwiperStyleRouteState extends State<SwiperStyleRoute> {
  bool _circular = false;
  late SwiperController swiperController;

  @override
  void initState() {
    super.initState();
    swiperController= SwiperController();
    swiperController.addListener((){
//      print(swiperController.index);
//      print(swiperController.page);
    });
  }


  @override
  void dispose() {
    swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 16.0 / 9.0,
          child: Swiper(
            controller: swiperController,
            autoStart: false,
            circular: _circular,
            indicator: RectangleSwiperIndicator(),
            onChanged: (index)=>print(index),
            children: <Widget>[
              Image.asset("imgs/sea.png",fit: BoxFit.fill,),
              Image.asset("imgs/star.jpg", fit: BoxFit.fill),
              Image.asset("imgs/cat.jpg",fit: BoxFit.fill,),
              Image.asset("imgs/horse.jpg", fit: BoxFit.fill),
            ],
          ),
        ),
        ElevatedButton(
          child: Text("Circular($_circular)"),
          onPressed: () {
            setState(() {
              _circular = !_circular;
            });
          },
        ),
        ElevatedButton(
          child: Text("Prev"),
          onPressed: () {
            swiperController.previousPage(duration: Duration(milliseconds: 200), curve: Curves.easeOut);
          },
        ),
        ElevatedButton(
          child: Text("Next"),
          onPressed: () {
            swiperController.nextPage(duration: Duration(milliseconds: 200), curve: Curves.easeOut);
          },
        ),
        ElevatedButton(
          child: Text("start"),
          onPressed: () {
            swiperController.start();
          },
        ),
        ElevatedButton(
          child: Text("Stop"),
          onPressed: () {
            swiperController.stop();
          },
        )
      ],
    );
  }
}
