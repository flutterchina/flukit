import 'package:flukit/src/index_bar.dart';
import 'package:flutter/material.dart';

///ISuspension Bean.
abstract class ISuspensionBean {
  bool isShowSuspension;

  String getSuspensionTag(); //Suspension Tag
}

class QuickSelectListViewHeader {
  QuickSelectListViewHeader({
    @required this.height,
    @required this.builder,
    this.tag = "↑",
  });

  final int height;
  final String tag;
  final WidgetBuilder builder;
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

  final QuickSelectListViewHeader header;

  SuspensionListView({
    Key key,
    @required this.data,
    @required this.contentWidget,
    @required this.suspensionWidget,
    @required this.controller,
    this.suspensionHeight: 40,
    this.itemHeight: 50,
    this.onSusTagChanged,
    this.onSusSectionInited,
    this.header,
  })
      : assert(contentWidget != null),
        assert(controller != null),
        super(key: key);

  @override
  _SuspensionWidgetState createState() => new _SuspensionWidgetState();
}

class _SuspensionWidgetState extends State<SuspensionListView> {
  int _suspensionTop = 0;
  int _lastIndex;
  int _suSectionListLength;

  List<int> _suspensionSectionList = new List();
  Map<String, int> _suspensionSectionMap = new Map();

  @override
  void initState() {
    super.initState();
    if (widget.header != null) {
      _suspensionTop = -widget.header.height;
    }
    widget.controller.addListener(() {
      int offset = widget.controller.offset.toInt();
      int _index = _getIndex(offset);
      if (_index != -1 && _lastIndex != _index) {
        _lastIndex = _index;
        if (widget.onSusTagChanged != null) {
          widget.onSusTagChanged(_suspensionSectionMap.keys.toList()[_index]);
        }
      }
    });
  }

  int _getIndex(int offset) {
    if (widget.header != null && offset < widget.header.height) {
      if (_suspensionTop != -widget.header.height &&
          widget.suspensionWidget != null) {
        setState(() {
          _suspensionTop = -widget.header.height;
        });
      }
      return 0;
    }
    for (int i = 0; i < _suSectionListLength - 1; i++) {
      int space = _suspensionSectionList[i + 1] - offset;
      if (space > 0 && space < widget.suspensionHeight) {
        space = space - widget.suspensionHeight;
      } else {
        space = 0;
      }
      if (_suspensionTop != space && widget.suspensionWidget != null) {
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

  void _init() {
    _suspensionSectionMap.clear();
    int offset = 0;
    String tag;
    if (widget.header != null) {
      _suspensionSectionMap[widget.header.tag] = 0;
      offset = widget.header.height;
    }
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

  @override
  Widget build(BuildContext context) {
    _init();
    var children = <Widget>[
      widget.contentWidget,
    ];
    if (widget.suspensionWidget != null) {
      children.add(Positioned(
        top: _suspensionTop.toDouble() - 0.1,

        ///-0.1修复部分手机丢失精度问题
        left: 0.0,
        right: 0.0,
        child: widget.suspensionWidget,
      ));
    }
    return Stack(children: children);
  }
}

///Called to build children for the listview.
typedef Widget ItemWidgetBuilder(BuildContext context, ISuspensionBean model);

typedef Widget IndexBarBuilder(BuildContext context, List<String> tags,
    IndexBarTouchCallback onTouch);
typedef Widget IndexHintBuilder(BuildContext context, String hint);

class QuickSelectListView extends StatefulWidget {
  QuickSelectListView({
    Key key,
    this.data,
    this.topData,
    this.itemBuilder,
    this.suspensionWidget,
    this.isUseRealIndex: true,
    this.itemHeight: 50,
    this.suspensionHeight: 40,
    this.onSusTagChanged,
    this.header,
    this.indexBarBuilder,
    this.indexHintBuilder,
    this.showIndexHint: true
  })
      : assert(itemBuilder != null),
        super(key: key);

  ///with ISuspensionBean Data
  final List<ISuspensionBean> data;

  ///with ISuspensionBean topData, Do not participate in [A-Z] sorting (such as hotList).
  final List<ISuspensionBean> topData;

  final ItemWidgetBuilder itemBuilder;

  ///suspension widget.
  final Widget suspensionWidget;

  ///is use real index data.(false: use INDEX_DATA_DEF)
  final bool isUseRealIndex;

  ///item Height.
  final int itemHeight;

  ///suspension widget Height.
  final int suspensionHeight;

  ///on sus tag change callback.
  final ValueChanged<String> onSusTagChanged;

  final QuickSelectListViewHeader header;

  final IndexBarBuilder indexBarBuilder;

  final IndexHintBuilder indexHintBuilder;

  final bool showIndexHint;


  @override
  State<StatefulWidget> createState() {
    return new _QuickSelectListViewState();
  }
}

class _Header extends ISuspensionBean {
  String tag;

  @override
  String getSuspensionTag() => tag;

  @override
  bool get isShowSuspension => false;

}

class _QuickSelectListViewState extends State<QuickSelectListView> {
  Map<String, int> _suspensionSectionMap = Map();
  List<ISuspensionBean> _cityList = List();
  List<String> _indexTagList = List();
  bool _isShowIndexBarHint = false;
  String _indexBarHint = "";

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onIndexBarTouch(IndexBarDetails model) {
    setState(() {
      _indexBarHint = model.tag;
      _isShowIndexBarHint = model.isTouchDown;
      int offset = _suspensionSectionMap[model.tag];
      if (offset != null) {
        _scrollController.jumpTo(offset.toDouble().clamp(
            .0, _scrollController.position.maxScrollExtent)
        );
      }
    });
  }

  void _init() {
    _cityList.clear();
    if (widget.topData != null && widget.topData.isNotEmpty) {
      _cityList.addAll(widget.topData);
    }
    List<ISuspensionBean> list = widget.data;
    if (list != null && list.isNotEmpty) {
      SuspensionUtil.sortListBySuspensionTag(list);
      _cityList.addAll(list);
    }

    SuspensionUtil.setShowSuspensionStatus(_cityList);

    if (widget.header != null) {
      _cityList.insert(0, _Header()
        ..tag = widget.header.tag);
    }
    _indexTagList.clear();
    if (widget.isUseRealIndex) {
      _indexTagList.addAll(SuspensionUtil.getTagIndexList(_cityList));
    } else {
      _indexTagList.addAll(INDEX_DATA_DEF);
    }
  }

  @override
  Widget build(BuildContext context) {
    _init();
    var children = <Widget>[
      SuspensionListView(
        data: widget.header == null ? _cityList : _cityList.sublist(1),
        contentWidget: ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: _cityList.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0 && _cityList[index] is _Header) {
                return SizedBox(
                    height: widget.header.height.toDouble(),
                    child: widget.header.builder(context)
                );
              }
              return widget.itemBuilder(context, _cityList[index]);
            }
        ),
        suspensionWidget: widget.suspensionWidget,
        controller: _scrollController,
        suspensionHeight: widget.suspensionHeight,
        itemHeight: widget.itemHeight,
        onSusTagChanged: widget.onSusTagChanged,
        header: widget.header,
        onSusSectionInited: (Map<String, int> map) =>
        _suspensionSectionMap = map,
      )
    ];

    Widget indexBar;
    if (widget.indexBarBuilder == null) {
      indexBar = IndexBar(
        data: _indexTagList,
        width: 36,
        onTouch: _onIndexBarTouch,
      );
    } else {
      indexBar = widget.indexBarBuilder(
        context,
        _indexTagList,
        _onIndexBarTouch,
      );
    }
    children.add(
        Align(
          alignment: Alignment.centerRight,
          child: indexBar,
        )
    );
    Widget indexHint;
    if (widget.indexHintBuilder != null) {
      indexHint = widget.indexHintBuilder(context, '$_indexBarHint');
    } else {
      indexHint = Card(
        color: Colors.black54,
        child: Container(
          alignment: Alignment.center,
          width: 80.0,
          height: 80.0,
          child: Text(
            '$_indexBarHint',
            style: TextStyle(
              fontSize: 32.0,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (_isShowIndexBarHint && widget.showIndexHint) {
      children.add(Center(
        child: indexHint,
      ));
    }

    return new Stack(children: children);
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
        String tag = list[i].getSuspensionTag();
        if (tag.length > 2) tag = tag.substring(0, 2);
        if (tempTag != tag) {
          indexData.add(tag);
          tempTag = tag;
        }
      }
    }
    return indexData;
  }

  ///set show suspension status.
  static void setShowSuspensionStatus(List<ISuspensionBean> list) {
    if (list == null || list.isEmpty) return;
    String tempTag;
    for (int i = 0, length = list.length; i < length; i++) {
      String tag = list[i].getSuspensionTag();
      if (tempTag != tag) {
        tempTag = tag;
        list[i].isShowSuspension = true;
      } else {
        list[i].isShowSuspension = false;
      }
    }
  }
}
