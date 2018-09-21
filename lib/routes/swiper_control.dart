import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';

class SwiperStyleRoute extends StatefulWidget {
  @override
  _SwiperStyleRouteState createState() => new _SwiperStyleRouteState();
}

class _SwiperStyleRouteState extends State<SwiperStyleRoute> {
  bool _circular = false;
  SwiperController swiperController;

  @override
  void initState() {
    swiperController=new SwiperController();
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
            children: <Widget>[
              Image.asset("images/sea.png",fit: BoxFit.fill,),
              Image.asset("images/star.jpg", fit: BoxFit.fill),
              Image.asset("images/cat.jpg",fit: BoxFit.fill,),
              Image.asset("images/horse.jpg", fit: BoxFit.fill),
            ],
          ),
        ),
        RaisedButton(
          child: Text("Circular($_circular)"),
          onPressed: () {
            setState(() {
              _circular = !_circular;
            });
          },
        ),
        RaisedButton(
          child: Text("Prev"),
          onPressed: () {
            swiperController.previousPage(duration: Duration(milliseconds: 200), curve: Curves.easeOut);
          },
        ),
        RaisedButton(
          child: Text("Next"),
          onPressed: () {
            swiperController.nextPage(duration: Duration(milliseconds: 200), curve: Curves.easeOut);
          },
        ),
        RaisedButton(
          child: Text("start"),
          onPressed: () {
            swiperController.start();
          },
        ),
        RaisedButton(
          child: Text("Stop"),
          onPressed: () {
            swiperController.stop();
          },
        )
      ],
    );
  }
}
