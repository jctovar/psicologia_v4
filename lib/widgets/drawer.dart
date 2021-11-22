import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:suayed/routes/routes.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}
class _AppDrawerState extends State<AppDrawer> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem(
              icon: LineIcons.home, text: 'Inicio', onTap: () =>
              Navigator.pushReplacementNamed(context, Routes.home)),
          _createDrawerItem(
              icon: LineIcons.graduationCap, text: 'Profesores', onTap: () =>
              Navigator.pushReplacementNamed(context, Routes.teachers)),
          _createDrawerItem(
              icon: LineIcons.users, text: 'Coordinación', onTap: () =>
              Navigator.pushReplacementNamed(context, Routes.areas)),
          const Divider(),
          _createDrawerItem(
              icon: LineIcons.bookmark, text: 'Marcadores', onTap: () =>
              Navigator.pushReplacementNamed(context, Routes.bookmarks)),
          const Divider(),
          _createDrawerItem(
              icon: LineIcons.info, text: 'Acerca de', onTap: () =>
              Navigator.pushReplacementNamed(context, Routes.about)),
          ListTile(
            title: Text('Version: ' + _packageInfo.version + ' / Build: ' + _packageInfo.buildNumber),
          ),
        ],
      ),
    );
  }

  Widget _createHeader() {
    return const DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.pinkAccent,
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Image(image: AssetImage('assets/splash.png')),
        )
    );
  }

  Widget _createDrawerItem(
      {required IconData icon, required String text, required GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon, color: Colors.pink.shade800),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(text,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400, color: Colors.pink.shade800)),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}