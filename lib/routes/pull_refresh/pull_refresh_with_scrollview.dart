import 'package:flutter/material.dart';
import 'package:flukit/flukit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'custom_pullrefresh_header.dart';

class PullRefreshWithScrollView extends StatefulWidget {
  @override
  PullRefreshWithScrollViewState createState() {
    return new PullRefreshWithScrollViewState();
  }
}

class PullRefreshWithScrollViewState extends State<PullRefreshWithScrollView> {
  ScrollController _controller=new ScrollController();
  int _navBgColorAlpha=0;
  @override
  void initState() {
    _controller.addListener((){
       setState(() {
         _navBgColorAlpha=(_controller.offset/100*255).toInt().clamp(0, 255);
       });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PullRefreshBox(
            onRefresh: () async => Future.delayed(Duration(seconds: 5)),
            indicator: MyPullRefreshIndicator(
                style: TextStyle(color: Colors.white70),
                dragIndicator:Icon(Icons.refresh, color: Colors.white70,),
                refreshIndicator: CircularProgressIndicator(
                     strokeWidth: 1.5,
                    valueColor:AlwaysStoppedAnimation<Color>(Colors.white70),
                ),
                //渐变效果
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.blue, Colors.blue[50]],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                    )
                ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    controller: _controller,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 190.0,
                          padding: EdgeInsets.only(top: 60.0),
                          color: Colors.blue,
                          alignment: Alignment.center,
                          child: ClipOval(
                            child: Image.asset("images/avatar.png",
                              width: 80.0,
                            ),
                          ),
                        ),
                      ]..addAll("ABCDEFGHIJKLMNOPQRST".split("").map((e)=>ListTile(title: Text(e),))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Navigation bar
          Positioned(
            left: .0,
            right: .0,
            child: Material(
              color: Colors.blue.withAlpha(_navBgColorAlpha),
              child: Padding(
                padding: const EdgeInsets.only(top: 26.0),
                child: SizedBox(
                  height: 56.0,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white,),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(" Profile", style: TextStyle(color: Colors.white, fontSize: 16.0),),
                      Spacer()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
