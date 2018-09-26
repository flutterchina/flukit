import 'package:flukitdemo/widgets/index.dart';
import 'package:flutter/material.dart';
import 'quick_select_listview/city_select.dart';
import 'quick_select_listview/city_select_custom_header.dart';
import 'quick_select_listview/contact_list.dart';
import 'quick_select_listview/index_suspension.dart';

class QuickSelectListViewRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListPage([
      PageInfo("City Select", (ctx) => CitySelectRoute()),
      PageInfo("City Select(Custom header)", (ctx) => CitySelectCustomHeaderRoute()),
      PageInfo("Contacts List", (ctx) => ContactListRoute()),
      PageInfo("IndexBar & SuspensionListView", (ctx) => IndexSuspensionRoute()),
    ]);
  }
}
