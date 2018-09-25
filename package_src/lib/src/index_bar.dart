import 'package:flutter/material.dart';

///IndexBar touch callback IndexModel.
typedef void IndexBarTouchCallback(IndexBarDetails model);

///IndexModel.
class IndexBarDetails {
  String tag; //current touch tag.
  int position; //current touch position.
  bool isTouchDown; //is touch down.

  IndexBarDetails({this.tag, this.position, this.isTouchDown});
}

///Default Index data.
const List<String> INDEX_DATA_DEF = const [
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z",
  "#"
];

class IndexBar extends StatefulWidget {
  IndexBar({
    Key key,
    this.data: INDEX_DATA_DEF,
    @required this.onTouch,
    this.width: 30,
    this.itemHeight: 16,
    this.color = Colors.transparent,
    this.textStyle = const TextStyle(fontSize: 12.0, color: Color(0xFF666666)),
    this.touchDownColor = const Color(0xffeeeeee),
    this.touchDownTextStyle = const TextStyle(
        fontSize: 12.0, color: Colors.black)
  });

  ///index data.
  final List<String> data;

  ///IndexBar width(def:30).
  final int width;

  ///IndexBar item height(def:16).
  final int itemHeight;

  /// Background color
  final Color color;

  ///IndexBar touch down color.
  final Color touchDownColor;

  ///IndexBar text style.
  final TextStyle textStyle;

  final TextStyle touchDownTextStyle;

  ///Item touch callback.
  final IndexBarTouchCallback onTouch;

  @override
  _SuspensionListViewIndexBarState createState() =>
      _SuspensionListViewIndexBarState();

}

class _SuspensionListViewIndexBarState extends State<IndexBar> {
  bool _isTouchDown = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: _isTouchDown ? widget.touchDownColor : widget.color,
      width: widget.width.toDouble(),
      child: _IndexBar(
        data: widget.data,
        width: widget.width,
        itemHeight: widget.itemHeight,
        textStyle: widget.textStyle,
        touchDownTextStyle: widget.touchDownTextStyle,
        onTouch: (details) {
          if (widget.onTouch != null) {
            if (_isTouchDown != details.isTouchDown) {
              setState(() {
                _isTouchDown = details.isTouchDown;
              });
            }
            widget.onTouch(details);
          }
        },
      ),
    );
  }
}


/// Base IndexBar.
class _IndexBar extends StatefulWidget {
  ///index data.
  final List<String> data;

  ///IndexBar width(def:30).
  final int width;

  ///IndexBar item height(def:16).
  final int itemHeight;

  ///IndexBar text style.
  final TextStyle textStyle;

  final TextStyle touchDownTextStyle;

  ///Item touch callback.
  final IndexBarTouchCallback onTouch;

  _IndexBar({
    Key key,
    this.data: INDEX_DATA_DEF,
    @required this.onTouch,
    this.width: 30,
    this.itemHeight: 16,
    this.textStyle,
    this.touchDownTextStyle
  })
      : assert(onTouch != null),
        super(key: key);

  @override
  _IndexBarState createState() => _IndexBarState();

}

class _IndexBarState extends State<_IndexBar> {
  List<int> _indexSectionList = new List();
  int _widgetTop = -1;
  int _lastIndex = 0;
  bool _widgetTopChange = false;
  bool _isTouchDown = false;
  IndexBarDetails _indexModel = new IndexBarDetails();


  ///get index.
  int _getIndex(int offset) {
    for (int i = 0, length = _indexSectionList.length; i < length - 1; i++) {
      int a = _indexSectionList[i];
      int b = _indexSectionList[i + 1];
      if (offset >= a && offset < b) {
        return i;
      }
    }
    return -1;
  }


  void _init() {
    _widgetTopChange = true;
    _indexSectionList.clear();
    _indexSectionList.add(0);
    int tempHeight = 0;
    widget.data?.forEach((value) {
      tempHeight = tempHeight + widget.itemHeight;
      _indexSectionList.add(tempHeight);
    });
  }


  _triggerTouchEvent() {
    if (widget.onTouch != null) {
      widget.onTouch(_indexModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _style = widget.textStyle;
    if (_indexModel.isTouchDown == true) {
      _style = widget.touchDownTextStyle;
    }
    _init();

    List<Widget> children = new List();
    widget.data.forEach((v) {
      children.add(new SizedBox(
        width: widget.width.toDouble(),
        height: widget.itemHeight.toDouble(),
        child: new Text(
            v,
            textAlign: TextAlign.center,
            style: _style
        ),
      ));
    });

    return GestureDetector(
      onVerticalDragDown: (DragDownDetails details) {
        if (_widgetTop == -1 || _widgetTopChange) {
          _widgetTopChange = false;
          RenderBox box = context.findRenderObject();
          Offset topLeftPosition = box.localToGlobal(Offset.zero);
          _widgetTop = topLeftPosition.dy.toInt();
        }
        int offset = details.globalPosition.dy.toInt() - _widgetTop;
        int index = _getIndex(offset);
        if (index != -1) {
          _lastIndex = index;
          _indexModel.position = index;
          _indexModel.tag = widget.data[index];
          _indexModel.isTouchDown = true;
          _triggerTouchEvent();
        }
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        int offset = details.globalPosition.dy.toInt() - _widgetTop;
        int index = _getIndex(offset);
        if (index != -1 && _lastIndex != index) {
          _lastIndex = index;
          _indexModel.position = index;
          _indexModel.tag = widget.data[index];
          _indexModel.isTouchDown = true;
          _triggerTouchEvent();
        }
      },
      onVerticalDragEnd: (DragEndDetails details) {
        _indexModel.isTouchDown = false;
        _triggerTouchEvent();
      },
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
