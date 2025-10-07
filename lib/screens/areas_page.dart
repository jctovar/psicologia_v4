import 'package:flutter/material.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:suayed/widgets/avatar.dart';
import 'package:suayed/widgets/drawer.dart';
import 'package:suayed/models/area_model.dart';
import 'package:suayed/services/local_service.dart';

import 'area_detail.dart';

class AreasPage extends StatefulWidget {
  static const String routeName = 'areas';
  const AreasPage({super.key, required this.title});
  final String title;

  @override
  State<AreasPage> createState() => _AreasPageState();
}

class _AreasPageState extends State<AreasPage> {
  List<AreaModel> _items = List.empty();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Widget _buildList() {
    return ListView.separated(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return ListTile(
          leading: Avatar(
            picturePath: '',
            emailUser: item.personalEmail,
            sizeAvatar: 48,
          ),
          title: Text(item.agent, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            item.departmentName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: true,
          onTap: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return AreaDetail(item: item);
                    },
                  ),
                )
                .then((value) {
                  setState(() {});
                });
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(color: Colors.black12);
      },
    );
  }

  void _loadData() {
    Services.readJsonAreas().then((itemsFromServer) {
      setState(() {
        _items = itemsFromServer;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(title: Text(widget.title)),
      drawer: const AppDrawer(),
      body: _buildList(),
    );
  }
}
