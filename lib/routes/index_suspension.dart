import 'dart:convert';

import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';

class CityBean extends BaseIndexBean {
  String name;

  CityBean({
    this.name,
    baseIndexTag,
    baseIndexPinyin,
    isShowSuspension,
  }) : super(
            baseIndexName: name,
            baseIndexTag: baseIndexTag,
            baseIndexPinyin: baseIndexPinyin,
            isShowSuspension: isShowSuspension);

  CityBean.fromJson(Map<String, dynamic> json)
      : name = json['name'] == null ? "" : json['name'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'baseIndexName': baseIndexName,
        'baseIndexTag': baseIndexTag,
        'baseIndexPinyin': baseIndexPinyin,
        'isShowSuspension': isShowSuspension
      };

  @override
  String toString() {
    return "CityBean {" + " \"name\":\"" + name + "\"" + '}';
  }
}

class PinYinUtils {
  ///获取拼音并排序
  static void sortListByLetter(List<BaseIndexBean> list) {
    if (list == null || list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin = PinyinHelper.convertToPinyinStringWithoutException(
          list[i].baseIndexName);
      list[i].baseIndexPinyin = pinyin;
      String tag = pinyin.substring(0, 1).toUpperCase();
      if (new RegExp("[A-Z]").hasMatch(tag)) {
        list[i].baseIndexTag = tag;
      } else {
        list[i].baseIndexTag = "#";
      }
    }
    SuspensionUtil.sortSuspensionList(list);
  }
}

class IndexSuspensionRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _IndexSuspensionRouteState();
  }
}

class _IndexSuspensionRouteState extends State<IndexSuspensionRoute> {
  List<CityBean> _cityList = new List();
  List<CityBean> _hotCityList = new List();
  List<String> _indexTagList = new List();

  Map<String, int> _suspensionSectionMap = new Map();

  ScrollController _scrollController;
  int _suspensionHeight = 40;
  int _itemHeight = 50;
  String _suspensionTag = "";

  bool _isShowIndexBarHint = false;
  String _indexBarHint = "";

  @override
  void initState() {
    super.initState();

    _scrollController = new ScrollController();

    _hotCityList.add(new CityBean(name: "北京市", baseIndexTag: "★ 热门城市"));
    _hotCityList.add(new CityBean(name: "广州市", baseIndexTag: "★ 热门城市"));
    _hotCityList.add(new CityBean(name: "成都市", baseIndexTag: "★ 热门城市"));
    _hotCityList.add(new CityBean(name: "深圳市", baseIndexTag: "★ 热门城市"));
    _hotCityList.add(new CityBean(name: "杭州市", baseIndexTag: "★ 热门城市"));
    _hotCityList.add(new CityBean(name: "武汉市", baseIndexTag: "★ 热门城市"));

    loadData();
//    new Future.delayed(new Duration(milliseconds: 500), () {
//      loadData();
//    });
  }

  void loadData() async {
    rootBundle.loadString('assets/data/china.json').then((value) {
      List<CityBean> cityList = new List();
      Map countyMap = json.decode(value);
      List list = countyMap['china'];
      list.forEach((value) {
        cityList.add(new CityBean(name: value['name']));
      });

      showData(cityList);
    });
  }

  void showData(List<CityBean> cityList) {
    PinYinUtils.sortListByLetter(cityList);

    setState(() {
      _cityList.addAll(_hotCityList);
      _cityList.addAll(cityList);

      _indexTagList.clear();
      _indexTagList.add("★");
      _indexTagList.addAll(SuspensionUtil.getRealIndexDataList(cityList));

      SuspensionUtil.buildShowSuspensionTag(_cityList);
      _suspensionTag = _cityList.isEmpty ? "" : _cityList[0].baseIndexTag;
    });
  }

  void _onIBarTouchCallback(IndexModel model) {
    setState(() {
      _indexBarHint = model.currentTag;
      _isShowIndexBarHint = model.isTouchDown;

      String current = model.currentTag;
      if (current == "★") {
        current = "★ 热门城市";
      }
      int offset = _suspensionSectionMap[current];
      if (offset != null) {
        _scrollController.jumpTo(offset.toDouble());
      }
    });
  }

  void _onSusTagChangeCallBack(String tag) {
    setState(() {
      _suspensionTag = tag;
    });
  }

  void _onSusSectionCallBack(Map<String, int> map) {
    _suspensionSectionMap = map;
  }

  Widget _buildListItem(int index) {
    CityBean model = _cityList[index];
    return new Column(
      children: <Widget>[
        new Offstage(
          offstage: !(model.isShowSuspension == true),
          child: new Container(
              alignment: Alignment.centerLeft,
              height: _suspensionHeight.toDouble(),
              color: Color(0xfff3f4f5),
              padding: const EdgeInsets.only(left: 15.0),
              child: new Text(
                model.baseIndexTag,
                style: new TextStyle(fontSize: 14.0, color: Color(0xff999999)),
              )),
        ),
        new InkWell(
          onTap: () {
            print("OnItemClick: " + model.toString());
          },
          child: new Container(
            height: _itemHeight.toDouble(),
            alignment: Alignment.centerLeft,
            child: new Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: new Text(
                model.name,
                style: new TextStyle(color: Color(0xff333333), fontSize: 14.0),
              ),
            ),
            decoration: new BoxDecoration(
                color: Colors.white,
                border: new Border(
                    bottom:
                        new BorderSide(color: Color(0xfff5f5f5), width: 0.33))),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
        color: Colors.transparent,
        child: new Column(
          children: <Widget>[
            new Container(
              color: Colors.white,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                      child: new Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new TextField(
                      autofocus: false,
                      style: new TextStyle(
                          fontSize: 14.0, color: Color(0XFF333333)),
                      decoration: new InputDecoration(
                          border: InputBorder.none,
                          hintText: '城市中文名或拼音',
                          hintStyle: new TextStyle(
                              fontSize: 14.0, color: Color(0XFFcccccc))),
                    ),
                  )),
                  new Container(
                    width: 0.33,
                    height: 14.0,
                    color: Color(0XFFEFEFEF),
                  ),
                  new InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text(
                        "取消",
                        style: new TextStyle(
                            color: Color(0xFF999999), fontSize: 14.0),
                      ),
                    ),
                  )
                ],
              ),
            ),
            new Expanded(
                child: new Card(
              color: Colors.white,
              margin: const EdgeInsets.only(
                  left: 10.0, top: 10.0, right: 10.0, bottom: 0.0),
              shape: const RoundedRectangleBorder(
                borderRadius:
                    const BorderRadius.all(const Radius.circular(2.0)),
              ),
              child: new Column(
                children: <Widget>[
                  new Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 15.0),
                    height: 50.0,
                    child: new Text(
                      "当前城市:成都市",
                      style: new TextStyle(
                          fontSize: 14.0, color: Color(0xff333333)),
                    ),
                  ),
                  new Expanded(
                      flex: 1,
                      child: new Container(
                        child: new Stack(
                          children: <Widget>[
                            new SuspensionWidget(_cityList,
                                contentWidget: new ListView.builder(
                                    controller: _scrollController,
                                    shrinkWrap: true,
                                    itemCount: _cityList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return _buildListItem(index);
                                    }),
                                suspensionWidget: new Container(
                                    height: 40.0,
                                    padding: const EdgeInsets.only(left: 15.0),
                                    color: Color(0xfff3f4f5),
                                    alignment: Alignment.centerLeft,
                                    child: new Text(
                                      '$_suspensionTag',
                                      softWrap: false,
                                      style: new TextStyle(
                                          fontSize: 14.0,
                                          color: Color(0xff999999)),
                                    )),
                                controller: _scrollController,
                                suspensionHeight: _suspensionHeight,
                                itemHeight: _itemHeight,
                                onSusTagChangeCallBack: _onSusTagChangeCallBack,
                                onSusSectionCallBack: _onSusSectionCallBack),
                            new Align(
                              alignment: Alignment.centerRight,
                              child: new IndexBar(
                                  indexData: _indexTagList,
                                  touchDownColor: Color(0x7DF7F7F7),
                                  onIBarTouchCallback: _onIBarTouchCallback),
                            ),
                            new Offstage(
                                offstage: !_isShowIndexBarHint,
                                child: new Center(
                                  child: new Card(
                                    color: Color(0xFF262626),
                                    child: new Container(
                                      alignment: Alignment.center,
                                      width: 72.0,
                                      height: 72.0,
                                      child: new Text(
                                        '$_indexBarHint',
                                        textAlign: TextAlign.center,
                                        style: new TextStyle(
                                            fontSize: 32.0,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ))
                ],
              ),
            )),
          ],
        ));
  }
}
