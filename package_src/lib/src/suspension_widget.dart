import 'package:flutter/material.dart';

///base index bean.
class BaseIndexBean implements ISuspensionBean {
  String baseIndexName;
  String baseIndexTag;
  String baseIndexPinyin;
  bool isShowSuspension;

  BaseIndexBean(
      {this.baseIndexTag,
      this.baseIndexPinyin,
      this.baseIndexName,
      this.isShowSuspension});

  @override
  String getSuspensionTag() {
    return baseIndexTag;
  }
}

///ISuspension Bean.
abstract class ISuspensionBean {
  String getSuspensionTag(); //Suspension Tag
}

///on sus tag change callback.
typedef void OnSusTagChangeCallBack(String tag);

///on all sus section callback(map: Used to scroll the list to the specified tag location).
typedef void OnSusSectionCallBack(Map<String, int> map);

///Suspension Widget.Currently only supports fixed height items!
class SuspensionWidget extends StatefulWidget {
  ///with  ISuspensionBean Data
  final List<ISuspensionBean> mData;

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
  final OnSusTagChangeCallBack onSusTagChangeCallBack;

  ///on sus section callback.
  final OnSusSectionCallBack onSusSectionCallBack;

  SuspensionWidget(this.mData,
      {Key key,
      @required this.contentWidget,
      @required this.suspensionWidget,
      @required this.controller,
      this.suspensionHeight: 40,
      this.itemHeight: 50,
      this.onSusTagChangeCallBack,
      this.onSusSectionCallBack})
      : assert(contentWidget != null),
        assert(suspensionWidget != null),
        assert(controller != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _SuspensionWidgetState();
  }
}

class _SuspensionWidgetState extends State<SuspensionWidget> {
  List<ISuspensionBean> _mData = new List();

  double _widgetWidth = 0.0;
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
      int _index = getIndex(offset);
      if (_index != -1 && _lastIndex != _index) {
        _lastIndex = _index;
        if (widget.onSusTagChangeCallBack != null) {
          widget.onSusTagChangeCallBack(
              _suspensionSectionMap.keys.toList()[_index]);
        }
      }
    });
  }

  int getIndex(int offset) {
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
    if (_widgetWidth == 0.0) {
      RenderBox box = context.findRenderObject();
      if (box != null && box.semanticBounds != null) {
        _widgetWidth = box.semanticBounds.width;
      }
    }

    if (!_twoListIsEqual(_mData, widget.mData)) {
      _mData.clear();
      if (widget.mData != null) _mData.addAll(widget.mData);
      _suspensionSectionMap.clear();

      int temp = 0;
      String tag;
      for (int i = 0, length = _mData.length; i < length; i++) {
        ISuspensionBean bean = _mData[i];
        if (tag != bean.getSuspensionTag()) {
          tag = bean.getSuspensionTag();
          _suspensionSectionMap.putIfAbsent(tag, () => temp);
          temp = temp + widget.suspensionHeight + widget.itemHeight;
        } else {
          temp = temp + widget.itemHeight;
        }
      }

      _suspensionSectionList.clear();
      _suspensionSectionList.addAll(_suspensionSectionMap.values);
      _suSectionListLength = _suspensionSectionList.length;

      if (widget.onSusSectionCallBack != null) {
        widget.onSusSectionCallBack(_suspensionSectionMap);
      }
    }

    return new Stack(children: <Widget>[
      widget.contentWidget,
      new Positioned(
          top: _suspensionTop.toDouble(),
          width: _widgetWidth,
          child: widget.suspensionWidget)
    ]);
  }
}

///Suspension Util.
class SuspensionUtil {
  ///sort list  by suspension tag.
  static void sortSuspensionList(List<ISuspensionBean> list) {
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

  ///get real index data list by suspension tag.
  static List<String> getRealIndexDataList(List<ISuspensionBean> list) {
    List<String> indexData = new List();
    if (list != null && list.isNotEmpty) {
      String tempTag;
      for (int i = 0, length = list.length; i < length; i++) {
        String tag = list[i].getSuspensionTag();
        if (tempTag != tag) {
          indexData.add(tag);
          tempTag = tag;
        }
      }
    }
    return indexData;
  }

  ///build is show suspension tag.
  static void buildShowSuspensionTag(List<BaseIndexBean> list) {
    if (list == null || list.isEmpty) return;
    String tempTag;
    for (int i = 0, length = list.length; i < length; i++) {
      String tag = list[i].baseIndexTag;
      if (tempTag != tag) {
        tempTag = tag;
        list[i].isShowSuspension = true;
      } else {
        list[i].isShowSuspension = false;
      }
    }
  }
}
