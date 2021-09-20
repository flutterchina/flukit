import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';

class KeepAliveTest extends StatefulWidget {
  const KeepAliveTest({Key? key}) : super(key: key);

  @override
  State<KeepAliveTest> createState() => _KeepAliveTestState();
}

class _KeepAliveTestState extends State<KeepAliveTest> {
  bool _keepAlive = false;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (_, index) {
      return KeepAliveWrapper(
        // 为 true 后会缓存所有的列表项，列表项将不会销毁。
        // 为 false 时，列表项滑出预加载区域后将会别销毁。
        // 使用时一定要注意是否必要，因为对所有列表项都缓存的会导致更多的内存消耗
        keepAlive: _keepAlive,
        child: wItem(index),
      );
    });
  }

  Widget wItem(index) {
    if (index == 0) {
      return CheckboxListTile(
        title: Text('缓存列表项'),
        subtitle: Text('勾选后将缓存每一个列表项'),
        value: _keepAlive,
        onChanged: (v) {
          setState(() {
            _keepAlive = v!;
          });
        },
      );
    } else {
      return ListItem(index: index);
    }
  }
}

class ListItem extends StatefulWidget {
  const ListItem({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(title: Text('${widget.index}'));
  }

  @override
  void dispose() {
    print('dispose ${widget.index}');
    super.dispose();
  }
}
