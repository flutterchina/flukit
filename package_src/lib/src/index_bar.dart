import 'package:flutter/material.dart';

///IndexBar touch callback IndexModel.
typedef void IndexBarTouchCallback(IndexModel model);

///IndexModel.
class IndexModel {
  String currentTag; //current touch tag.
  int position; //current touch position.
  bool isTouchDown; //is touch down.

  IndexModel({this.currentTag, this.position, this.isTouchDown});
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

/// a letter list IndexBar.
class IndexBar extends StatefulWidget {
  ///index data.
  final List<String> indexData;

  ///IndexBar width(def:30).
  final int iBarWidth;

  ///IndexBar item height(def:16).
  final int iBarItemHeight;

  ///IndexBar text style.
  final TextStyle textStyle;

  ///IndexBar touch down color.
  final Color touchDownColor;

  ///Item touch callback.
  final IndexBarTouchCallback onIBarTouchCallback;

  IndexBar(
      {Key key,
      this.indexData: INDEX_DATA_DEF,
      this.iBarWidth: 30,
      this.iBarItemHeight: 16,
      this.textStyle,
      this.touchDownColor: Colors.transparent,
      @required this.onIBarTouchCallback})
      : assert(onIBarTouchCallback != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new IndexBarState();
  }
}

class IndexBarState extends State<IndexBar> {
  bool _isTouchDown = false;

  void _onIBarTouchCallback(IndexModel model) {
    _isTouchDown = model.isTouchDown;
    if (widget.onIBarTouchCallback != null) widget.onIBarTouchCallback(model);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: Alignment.center,
      color: _isTouchDown ? widget.touchDownColor : Colors.transparent,
      width: widget.iBarWidth.toDouble(),
      height: double.infinity,
      child: new BaseIndexBar(
        indexData: widget.indexData,
        iBarWidth: widget.iBarWidth,
        iBarItemHeight: widget.iBarItemHeight,
        textStyle: widget.textStyle,
        onIBarTouchCallback: _onIBarTouchCallback,
      ),
    );
  }
}

/// Base IndexBar.
class BaseIndexBar extends StatefulWidget {
  ///index data.
  final List<String> indexData;

  ///IndexBar width(def:30).
  final int iBarWidth;

  ///IndexBar item height(def:16).
  final int iBarItemHeight;

  ///IndexBar text style.
  final TextStyle textStyle;

  ///Item touch callback.
  final IndexBarTouchCallback onIBarTouchCallback;

  BaseIndexBar(
      {Key key,
      this.indexData: INDEX_DATA_DEF,
      this.iBarWidth: 30,
      this.iBarItemHeight: 16,
      this.textStyle,
      @required this.onIBarTouchCallback})
      : assert(onIBarTouchCallback != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new BaseIndexBarState();
  }
}

class BaseIndexBarState extends State<BaseIndexBar> {
  List<String> _indexData = new List();
  List<Widget> _indexWidgetList = new List();
  List<int> _indexSectionList = new List();
  int _widgetTop = -1;
  int _lastIndex = 0;
  bool _widgetTopChange = false;

  IndexModel _indexModel = new IndexModel();

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

  ///two list is equal.
  bool _twoListIsEqual(List listA, List listB) {
    if (listA == listB) return true;
    if (listA == null || listB == null) return false;
    int length = listA.length;
    if (length != listB.length) return false;
    for (int i = 0; i < length; i++) {
      if (!listA.contains(listB[i])) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_twoListIsEqual(_indexData, widget.indexData)) {
      _widgetTopChange = true;

      _indexData.clear();
      if (widget.indexData != null) _indexData.addAll(widget.indexData);

      _indexSectionList.clear();
      _indexWidgetList.clear();

      _indexSectionList.add(0);
      int tempHeight = 0;
      _indexData.forEach((value) {
        tempHeight = tempHeight + widget.iBarItemHeight;
        _indexSectionList.add(tempHeight);
        _indexWidgetList.add(new SizedBox(
          width: widget.iBarWidth.toDouble(),
          height: widget.iBarItemHeight.toDouble(),
          child: new Text(
            value,
            textAlign: TextAlign.center,
            style: widget.textStyle == null
                ? new TextStyle(fontSize: 10.0, color: Color(0xFF666666))
                : widget.textStyle,
          ),
        ));
      });
    }

    return new GestureDetector(
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
          _indexModel.currentTag = _indexData[index];
          _indexModel.isTouchDown = true;
          if (widget.onIBarTouchCallback != null)
            widget.onIBarTouchCallback(_indexModel);
        }
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        int offset = details.globalPosition.dy.toInt() - _widgetTop;
        int index = _getIndex(offset);
        if (index != -1 && _lastIndex != index) {
          _lastIndex = index;
          _indexModel.position = index;
          _indexModel.currentTag = _indexData[index];
          _indexModel.isTouchDown = true;
          if (widget.onIBarTouchCallback != null)
            widget.onIBarTouchCallback(_indexModel);
        }
      },
      onVerticalDragEnd: (DragEndDetails details) {
        _indexModel.isTouchDown = false;
        if (widget.onIBarTouchCallback != null)
          widget.onIBarTouchCallback(_indexModel);
      },
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: _indexWidgetList,
      ),
    );
  }
}
