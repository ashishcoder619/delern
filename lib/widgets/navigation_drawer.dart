import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info/package_info.dart';

class NavigationDrawer extends StatefulWidget {
  final FirebaseUser user;
  final Function signOutCallback;
  NavigationDrawer(this.user, this.signOutCallback);

  @override
  _NavDrawerState createState() => new _NavDrawerState();
}

class _NavDrawerState extends State<NavigationDrawer> {
  String versionCode;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) => setState(() {
          versionCode = packageInfo.version;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
        child: new Column(
      children: <Widget>[
        new UserAccountsDrawerHeader(
          accountName: new Text(widget.user.displayName),
          accountEmail: new Text(widget.user.email),
          currentAccountPicture: new CircleAvatar(
            backgroundImage: new NetworkImage(widget.user.photoUrl),
          ),
        ),
        new ListTile(
          leading: new Icon(Icons.perm_identity),
          title: new Text('Sign Out'),
          onTap: () {
            widget.signOutCallback();
            Navigator.pop(context);
          },
        ),
        new Divider(height: 1.0),
        new ListTile(
          title: new Text(
            'Communicate',
            style: new TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        new ListTile(
          leading: new Icon(Icons.contact_mail),
          title: new Text('Invite Friends'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        new ListTile(
          leading: new Icon(Icons.live_help),
          title: new Text('Contact Us'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        new ListTile(
          leading: new Icon(Icons.attach_money),
          title: new Text('Support Development'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        new Divider(
          height: 1.0,
        ),
        new AboutListTile(
          icon: new Icon(Icons.perm_device_information),
          child: new Text('About'),
          applicationIcon: new Image.asset('images/ic_launcher.png'),
          applicationVersion: versionCode,
          applicationLegalese: 'GNU General Public License v3.0',
        ),
      ],
    ));
  }
}