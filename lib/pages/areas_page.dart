import 'package:flutter/material.dart';
import 'package:suayed/widgets/avatar.dart';
import 'package:suayed/widgets/drawer.dart';
import 'package:suayed/models/area_model.dart';
import 'package:suayed/services/local_service.dart';

import 'area_detail.dart';

class AreasPage extends StatefulWidget {
  static const String routeName = 'areas';
  const AreasPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  State<AreasPage> createState() => _AreasPageState();
}

class _AreasPageState extends State<AreasPage> {

  List<AreaModel> _items = List.empty();
  List<AreaModel> _filteredItems = List.empty();
  final TextEditingController _filter = TextEditingController();
  Icon _searchIcon = const Icon(Icons.search);
  Widget _appBarTitle = const Text('Coordinación');
  late String _searchText = "";

  _AreasPageState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          _filteredItems = _items;
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  void _searchPressed() {
    setState(() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = const Icon(Icons.close);
        _appBarTitle = TextField(
          autocorrect: true,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          controller: _filter,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.white,),
            enabledBorder: InputBorder.none,
            hintText: 'Buscar por nombre...',
            hintStyle: TextStyle(color: Colors.white),
          ),
        );
      } else {
        _searchIcon = const Icon(Icons.search);
        _appBarTitle = Text(widget.title!);
        _filteredItems = _items;
        _filter.clear();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            onPressed: _searchPressed,
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    if (_searchText.isNotEmpty) {
      _filteredItems = _items
          .where((u) => (u.agent
          .toLowerCase()
          .contains(_searchText.toLowerCase()) ||
          u.department_name.toLowerCase().contains(_searchText.toLowerCase())))
          .toList();
    }
    return RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.separated(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return ListTile(
                  //leading: Avatar(picturePath: item.picture, sizeAvatar: 48),
                  title: Text('${item.agent}\n${item.department_name}',
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text('${item.department_email}',
                      overflow: TextOverflow.ellipsis),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                      return AreaDetail(item: item);
                    },
                    )).then((value) {
                      setState(() {});
                    });
                  }
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                color: Colors.black12,
              );
            })
    );
  }

  Future _refreshData() async {
    await Future.delayed(const Duration(seconds: 3));
    _loadData();

    setState(() {});
  }

  _loadData() {
    Services.readJsonAreas().then((itemsFromServer) {
      setState(() {
        _items = itemsFromServer;
        _filteredItems = _items;
      });
    });
  }

}