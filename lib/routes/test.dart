import 'package:flutter/material.dart';

class TestRoute extends StatefulWidget {

  @override
  TestRouteState createState() {
    return new TestRouteState();
  }
}

class TestRouteState extends State<TestRoute> {
  var _t=true;
  @override
  Widget build(BuildContext context) {
    var t=List<Widget>(30)..fillRange(0, 30, Text("a"));
    var v=<Widget>[Text("c"),Text("d")];
    //FittedBox
    return Column(
      children: <Widget>[
        SizedBox(
          height: 100.0,
          child: ListView.builder(
            //children:_t?t:v,
            itemBuilder: (_,index){
              print(index);
              return Text("$index");
            },
          ),
        ),
        RaisedButton(
          child: Text("Switch"),
          onPressed: (){
            setState(() {
              _t=!_t;
            });
          },
        )
      ],
    );
  }
}
