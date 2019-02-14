import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:azlistview/azlistview.dart';
import 'package:lpinyin/lpinyin.dart';
import 'contact_model.dart';

class ContactListRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ContactListRouteState();
  }
}

class _ContactListRouteState extends State<ContactListRoute> {
  List<ContactInfo> _contacts = List();

  int _suspensionHeight = 40;
  int _itemHeight = 60;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    //加载联系人列表
    rootBundle.loadString('assets/data/contacts.json').then((value) {
      List list = json.decode(value);
      list.forEach((value) {
        _contacts.add(ContactInfo(name: value['name']));
      });
      _handleList(_contacts);
      setState(() {

      });
    });
  }


  void _handleList(List<ContactInfo> list) {
    if (list == null || list.isEmpty) return;
    for (int i = 0, length = list.length; i < length; i++) {
      String pinyin =
      PinyinHelper.getPinyinE(list[i].name);
      String tag = pinyin.substring(0, 1).toUpperCase();
      list[i].namePinyin = pinyin;
      if (RegExp("[A-Z]").hasMatch(tag)) {
        list[i].tagIndex = tag;
      } else {
        list[i].tagIndex = "#";
      }
    }
  }


  Widget _buildHeader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipOval(child: Image.asset("./images/avatar.png", width: 80.0,)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("远行", textScaleFactor: 1.2,),
          ),
          Text("+86 182-286-44678"),
        ],
      ),
    );
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: _suspensionHeight.toDouble(),
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Text('$susTag',
            textScaleFactor: 1.2,
          ),
          Expanded(child: Divider(height: .0, indent: 10.0,))
        ],
      ),
    );
  }

  Widget _buildListItem(ContactInfo model) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        SizedBox(
          height: _itemHeight.toDouble(),
          child: ListTile(
            leading: CircleAvatar(child: Text(model.name[0]),),
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
    return AzListView(
      data: _contacts,
      itemBuilder: (context, model) => _buildListItem(model),
      isUseRealIndex: true,
      itemHeight: _itemHeight,
      suspensionHeight: _suspensionHeight,
      header: AzListViewHeader(
          height: 180,
          builder: (context) {
            return _buildHeader();
          }
      ),

      indexBarBuilder: (BuildContext context, List<String> tags,
          IndexBarTouchCallback onTouch) {
        return Container(
          margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.grey[300], width: .5)
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: IndexBar(
              data: tags,
              itemHeight: 20,
              onTouch: (details) {
                onTouch(details);
              },
            ),
          ),
        );
      },
      indexHintBuilder: (context, hint) {
        return Container(
          alignment: Alignment.center,
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            color: Colors.blue[700].withAlpha(200),
            shape: BoxShape.circle,
          ),
          child: Text(
              hint, style: TextStyle(color: Colors.white, fontSize: 30.0)),
        );
      },
    );
  }
}