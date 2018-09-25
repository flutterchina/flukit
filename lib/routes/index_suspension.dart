import 'dart:convert';

import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';

class CityInfo extends ISuspensionBean {
  String name;
  String tagIndex;
  String namePinyin;

  CityInfo({
    this.name,
    this.tagIndex,
    this.namePinyin,
  });

  CityInfo.fromJson(Map<String, dynamic> json)
      : name = json['name'] == null ? "" : json['name'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'tagIndex': tagIndex,
        'namePinyin': namePinyin,
        'isShowSuspension': isShowSuspension
      };

  @override
  String getSuspensionTag() => tagIndex;

  @override
  String toString() => "CityBean {" + " \"name\":\"" + name + "\"" + '}';
}

class IndexSuspensionRoute extends StatefulWidget {
  @override
  _IndexSuspensionRouteState createState() => _IndexSuspensionRouteState();
}

class _IndexSuspensionRouteState extends State<IndexSuspensionRoute> {
  List<CityInfo> _cityList = List();
  List<String> _indexTagList = List();
  Map<String, int> _suspensionSectionMap = Map();
  ScrollController _scrollController;
  int _suspensionHeight = 40;
  int _itemHeight = 50;
  String _suspensionTag = "";

  bool _isShowIndexBarHint = false;
  String _indexBarHint = "";

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleList(List<CityInfo> list) {
    if (list == null || list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin =
          PinyinHelper.convertToPinyinStringWithoutException(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
    SuspensionUtil.sortListBySuspensionTag(list);
  }

  void _addHotCityList() {
    List<CityInfo> hotCityList = List();
    hotCityList.add(CityInfo(name: "北京市", tagIndex: "★"));
    hotCityList.add(CityInfo(name: "广州市", tagIndex: "★"));
    hotCityList.add(CityInfo(name: "成都市", tagIndex: "★"));
    _cityList.insertAll(0, hotCityList);
  }

  void loadData() async {
    //加载城市列表
    rootBundle.loadString('assets/data/china.json').then((value) {
      Map countyMap = json.decode(value);
      List list = countyMap['china'];
      list.forEach((value) {
        _cityList.add(CityInfo(name: value['name']));
      });
      _handleList(_cityList);

      //将热门城市置顶
      _addHotCityList();
      _indexTagList.addAll(SuspensionUtil.getTagIndexList(_cityList));

      SuspensionUtil.setShowSuspensionStatus(_cityList);

      setState(() {
        _suspensionTag = _cityList.isEmpty ? "" : _cityList[0].tagIndex;
      });
    });
  }

  void _onIndexBarTouch(IndexBarDetails model) {
    setState(() {
      _indexBarHint = model.tag;
      _isShowIndexBarHint = model.isTouchDown;
      int offset = _suspensionSectionMap[model.tag];
      if (offset != null) {
        _scrollController.jumpTo(offset.toDouble());
      }
    });
  }

  void _onSusTagChanged(String tag) {
    setState(() {
      _suspensionTag = tag;
    });
  }

  void _onSusSectionInited(Map<String, int> map) => _suspensionSectionMap = map;

  Widget _buildListItem(int index) {
    CityInfo model = _cityList[index];
    return Column(
      children: <Widget>[
        Offstage(
          offstage: !(model.isShowSuspension == true),
          child: Container(
            alignment: Alignment.centerLeft,
            height: _suspensionHeight.toDouble(),
            color: Color(0xfff3f4f5),
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              model.tagIndex,
              style: TextStyle(
                fontSize: 14.0,
                color: Color(0xff999999),
              ),
            ),
          ),
        ),
        SizedBox(
          height: _itemHeight.toDouble(),
          child: ListTile(
            title: Text(model.name),
            onTap: () {
              print("OnItemClick: $model");
              Navigator.pop(context, model);
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 15.0),
          height: 50.0,
          child: Text("当前城市: 成都市"),
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              SuspensionListView(
                data: _cityList,
                contentWidget: ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _cityList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildListItem(index);
                  },
                ),
                suspensionWidget: Container(
                  height: 40.0,
                  padding: const EdgeInsets.only(left: 15.0),
                  color: Color(0xfff3f4f5),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$_suspensionTag',
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Color(0xff999999),
                    ),
                  ),
                ),
                controller: _scrollController,
                suspensionHeight: _suspensionHeight,
                itemHeight: _itemHeight,
                onSusTagChanged: _onSusTagChanged,
                onSusSectionInited: _onSusSectionInited,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IndexBar(
                  data: _indexTagList,
                  onTouch: _onIndexBarTouch,
                ),
              ),
              Offstage(
                offstage: !_isShowIndexBarHint,
                child: Center(
                  child: Card(
                    color: Colors.black87,
                    child: Container(
                      alignment: Alignment.center,
                      width: 72.0,
                      height: 72.0,
                      child: Text(
                        '$_indexBarHint',
                        style: TextStyle(
                          fontSize: 32.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class CitySelectRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _CitySelectRouteState();
  }
}

class _CitySelectRouteState extends State<CitySelectRoute> {
  List<CityInfo> _cityList = List();
  List<CityInfo> _hotCityList = List();

  int _suspensionHeight = 40;
  int _itemHeight = 50;
  String _suspensionTag = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    _hotCityList.add(CityInfo(name: "深圳市", tagIndex: "热门"));
    _hotCityList.add(CityInfo(name: "杭州市", tagIndex: "热门"));
    _hotCityList.add(CityInfo(name: "武汉市", tagIndex: "热门"));

    _hotCityList.add(CityInfo(name: "北京市", tagIndex: "★"));
    _hotCityList.add(CityInfo(name: "广州市", tagIndex: "★"));
    _hotCityList.add(CityInfo(name: "成都市", tagIndex: "★"));

    //加载城市列表
    rootBundle.loadString('assets/data/china.json').then((value) {
      Map countyMap = json.decode(value);
      List list = countyMap['china'];
      list.forEach((value) {
        _cityList.add(CityInfo(name: value['name']));
      });
      _handleList(_cityList);

      setState(() {
        _suspensionTag = _hotCityList[0].getSuspensionTag();
      });
    });
  }

  void _handleList(List<CityInfo> list) {
    if (list == null || list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin =
          PinyinHelper.convertToPinyinStringWithoutException(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
  }

  void _onSusTagChanged(String tag) {
    setState(() {
      _suspensionTag = tag;
    });
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      height: _suspensionHeight.toDouble(),
      padding: const EdgeInsets.only(left: 15.0),
      color: Color(0xfff3f4f5),
      alignment: Alignment.centerLeft,
      child: Text(
        '$susTag',
        softWrap: false,
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xff999999),
        ),
      ),
    );
  }

  Widget _buildListItem(CityInfo model) {
    return Column(
      children: <Widget>[
        Offstage(
          offstage: !(model.isShowSuspension == true),
          child: _buildSusWidget(model.getSuspensionTag()),
        ),
        SizedBox(
          height: _itemHeight.toDouble(),
          child: ListTile(
            title: Text(model.name),
            onTap: () {
              print("OnItemClick: $model");
              Navigator.pop(context, model);
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 15.0),
          height: 50.0,
          child: Text("当前城市: 成都市"),
        ),
        Expanded(
            flex: 1,
            child: CitySelectListView(
              data: _cityList,
              topData: _hotCityList,
              itemBuilder: (context, model) => _buildListItem(model),
              suspensionWidget: _buildSusWidget(_suspensionTag),
              isUseRealIndex: true,
              itemHeight: _itemHeight,
              suspensionHeight: _suspensionHeight,
              onSusTagChanged: _onSusTagChanged,
            ))
      ],
    );
  }
}
