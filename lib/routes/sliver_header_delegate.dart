import 'package:flutter/material.dart' hide Page;
import 'package:flukit/flukit.dart';
import '../common/index.dart';

class SliverHeaderDelegateRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListPage(children: [
      Page('SliverPersistentHeader示例1', wSample1(), padding: false),
      Page('SliverPersistentHeader示例2', wSample2(context), withScaffold: false),
    ]);
  }

  Widget wSample1() {
    return CustomScrollView(
      slivers: [
        buildSliverList(),
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate(
            maxHeight: 80,
            minHeight: 50,
            child: buildHeader(1),
          ),
        ),
        buildSliverList(),
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate.fixedHeight(
            height: 50,
            child: buildHeader(2),
          ),
        ),
        buildSliverList(20),
      ],
    );
  }

  Widget wSample2(context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: ColoredBox(
          color: Colors.white,
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                floating: true,
                delegate: SliverHeaderDelegate.fixedHeight(
                  height: 48,
                  child: Material(
                    color: Colors.blue,
                    child: wSearch(),
                  ),
                ),
              ),
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: SliverAppBar(
                  title: const Text('示例二'),
                  pinned: true,
                  collapsedHeight: 56,
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverHeaderDelegate.fixedHeight(
                  height: 50,
                  child: buildHeader(2),
                ),
              ),
              buildSliverList(30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(int i) {
    return GestureDetector(
      key: ValueKey(i),
      onTap: () => print('header $i'),
      child: Container(
        color: Colors.lightBlue.shade200,
        alignment: Alignment.centerLeft,
        child: Text("PersistentHeader $i"),
      ),
    );
  }

  Widget wSearch() {
    const border =
        const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white));
    const textStyle = const TextStyle(color: Colors.white);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12,4,12,4),
      child: TextField(
        decoration: InputDecoration(
          focusedBorder: border,
          enabledBorder: border,
          contentPadding: EdgeInsets.fromLTRB(4, 8, 0, 8),
          hintText: 'Key words',
          hintStyle: textStyle,
          prefix: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              '搜索',
              style: TextStyle(color: Colors.white),
              textScaleFactor: 1.1,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ),
        style: textStyle,
        cursorColor: Colors.white,
        autofocus: true,
      ),
    );
  }
}
