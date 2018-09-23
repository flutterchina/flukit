import 'package:flutter/material.dart';
import 'utils.dart';


///ISuspension Bean.
abstract class ISuspensionBean {
  String getSuspensionTag(); //Suspension Tag
}


///on all sus section callback(map: Used to scroll the list to the specified tag location).
typedef void OnSusSectionCallBack(Map<String, int> map);

///Suspension Widget.Currently only supports fixed height items!
class SuspensionListView extends StatefulWidget {

  ///with  ISuspensionBean Data
  final List<ISuspensionBean> data;

  ///content widget(must contain ListView).
  final Widget contentWidget;

  ///suspension widget.
  final Widget suspensionWidget;

  ///ListView ScrollController.
  final ScrollController controller;

  ///suspension widget Height.
  final int suspensionHeight;

  ///item Height.
  final int itemHeight;

  ///on sus tag change callback.
  final ValueChanged<String> onSusTagChanged;

  ///on sus section callback.
  final OnSusSectionCallBack onSusSectionInited;

  SuspensionListView({
    Key key,
    @required this.data,
    @required this.contentWidget,
    @required this.suspensionWidget,
    @required this.controller,
    this.suspensionHeight: 40,
    this.itemHeight: 50,
    this.onSusTagChanged,
    this.onSusSectionInited
  })
      :assert(contentWidget != null),
        assert(suspensionWidget != null),
        assert(controller != null),
        super(key: key);

  @override
  _SuspensionWidgetState createState() => new _SuspensionWidgetState();
}

class _SuspensionWidgetState extends State<SuspensionListView> {

  // double _widgetWidth = 0.0;
  int _suspensionTop = 0;

  int _lastIndex;
  int _suSectionListLength;

  List<int> _suspensionSectionList = new List();
  Map<String, int> _suspensionSectionMap = new Map();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      int offset = widget.controller.offset.toInt();
      int _index = _getIndex(offset);
      if (_index != -1 && _lastIndex != _index) {
        _lastIndex = _index;
        if (widget.onSusTagChanged != null) {
          widget.onSusTagChanged(
              _suspensionSectionMap.keys.toList()[_index]);
        }
      }
    });
  }

  int _getIndex(int offset) {
    for (int i = 0; i < _suSectionListLength - 1; i++) {
      int space = _suspensionSectionList[i + 1] - offset;
      if (space > 0 && space < widget.suspensionHeight) {
        space = space - widget.suspensionHeight;
      } else {
        space = 0;
      }
      if (_suspensionTop != space) {
        setState(() {
          _suspensionTop = space;
        });
      }
      int a = _suspensionSectionList[i];
      int b = _suspensionSectionList[i + 1];
      if (offset >= a && offset < b) {
        return i;
      }
      if (offset >= _suspensionSectionList[_suSectionListLength - 1]) {
        return _suSectionListLength - 1;
      }
    }
    return -1;
  }


  @override
  void didUpdateWidget(SuspensionListView oldWidget) {
    if (isListEqual(oldWidget.data, widget.data)) {
      _suspensionSectionMap.clear();
      int offset = 0;
      String tag;
      widget.data?.forEach((v) {
        if (tag != v.getSuspensionTag()) {
          tag = v.getSuspensionTag();
          _suspensionSectionMap.putIfAbsent(tag, () => offset);
          offset = offset + widget.suspensionHeight + widget.itemHeight;
        } else {
          offset = offset + widget.itemHeight;
        }
      });
      _suspensionSectionList
        ..clear()
        ..addAll(_suspensionSectionMap.values);
      _suSectionListLength = _suspensionSectionList.length;
      if (widget.onSusSectionInited != null) {
        widget.onSusSectionInited(_suspensionSectionMap);
      }
    }
  }

  int getOffset(int index) {
    index = index.clamp(0, widget.data.length - 1);
    var item = widget.data[index];
    int offset = _suspensionSectionMap[item.getSuspensionTag()];
    return offset + (_getIndex(offset) - index) * widget.itemHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          widget.contentWidget,
          Positioned(
            top: _suspensionTop.toDouble(),
            left: 0.0,
            right: 0.0,
            child: widget.suspensionWidget,
          )
        ]
    );
  }
}

///Suspension Util.
class SuspensionUtil {
  ///sort list  by suspension tag.
  static void sortListBySuspensionTag(List<ISuspensionBean> list) {
    if (list == null || list.isEmpty) return;
    list.sort((a, b) {
      if (a.getSuspensionTag() == "@" || b.getSuspensionTag() == "#") {
        return -1;
      } else if (a.getSuspensionTag() == "#" || b.getSuspensionTag() == "@") {
        return 1;
      } else {
        return a.getSuspensionTag().compareTo(b.getSuspensionTag());
      }
    });
  }

  ///get  index data list by suspension tag.
  static List<String> getTagIndexList(List<ISuspensionBean> list) {
    List<String> indexData = new List();
    if (list != null && list.isNotEmpty) {
      String tempTag;
      for (int i = 0, length = list.length; i < length; i++) {
        String tag = list[i].getSuspensionTag()[0];
        if (tempTag != tag) {
          indexData.add(tag);
          tempTag = tag;
        }
      }
    }
    return indexData;
  }

}
