import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:suayed/pages/teacher_detail.dart';
import 'package:suayed/utils/app_constants.dart';
import 'package:suayed/widgets/avatar.dart';
import 'package:suayed/widgets/drawer.dart';
import 'package:suayed/models/teacher_model.dart';
import 'package:suayed/services/local_service.dart';

class TeachersPage extends StatefulWidget {
  static const String routeName = 'teachers';
  const TeachersPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  State createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  List<TeacherModel> _items = List.empty();
  List<TeacherModel> _filteredItems = List.empty();
  final TextEditingController _filter = TextEditingController();
  Icon _searchIcon = const Icon(LineIcons.search);
  Widget _appBarTitle = const Text('Profesores');
  late String _searchText = "";

  _TeachersPageState() {
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
      if (_searchIcon.icon == LineIcons.search) {
        _searchIcon = const Icon(LineIcons.times);
        _appBarTitle = TextField(
          autocorrect: true,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          controller: _filter,
          decoration: const InputDecoration(
            prefixIcon: Icon(
              LineIcons.search,
              color: Colors.white,
            ),
            enabledBorder: InputBorder.none,
            hintText: 'Buscar por nombre...',
            hintStyle: TextStyle(color: Colors.white),
          ),
        );
      } else {
        _searchIcon = const Icon(LineIcons.search);
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
      backgroundColor: Constants.backgroundColor,
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
          .where((u) =>
              (u.firstname.toLowerCase().contains(_searchText.toLowerCase()) ||
                  u.lastname.toLowerCase().contains(_searchText.toLowerCase())))
          .toList();
    }
    return RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.separated(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return ListTile(
                  leading: Avatar(
                      picturePath: item.picture,
                      emailUser: item.email,
                      sizeAvatar: 48),
                  title: Text(
                      '${item.grade} ${item.firstname} ${item.lastname}',
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(item.email, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return TeacherDetail(item: item);
                      },
                    )).then((value) {
                      setState(() {});
                    });
                  });
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                color: Colors.black12,
              );
            }));
  }

  Future _refreshData() async {
    await Future.delayed(const Duration(seconds: 3));
    _loadData();

    setState(() {});
  }

  void _loadData() {
    Services.readJsonTeachers().then((itemsFromServer) {
      setState(() {
        _items = itemsFromServer;
        _filteredItems = _items;
      });
    });
  }
}
