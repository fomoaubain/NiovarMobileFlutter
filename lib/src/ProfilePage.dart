import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niovar/widget/button_widget.dart';
import 'package:niovar/widget/profile/ChangePassword.dart';
import 'package:niovar/widget/profile/InfosPersonnel.dart';
import 'package:niovar/widget/profile/appbar_widget.dart';
import 'package:niovar/widget/profile/localisation.dart';
import 'package:niovar/widget/profile/numbers_widget.dart';
import 'package:niovar/widget/profile/profile_widget.dart';

import '../Constante.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String user ="fomo" ;
  int _selectedIndex = 0;
  static  List<Widget> _pages = <Widget>[
    InfosPersonnel(),
    Localisation(),
    ChangePassword(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: buildAppBar(context),
      body: _pages.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        selectedIconTheme: IconThemeData(color: Constante.primaryColor, size: 30),
        selectedItemColor: Constante.primaryColor,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _selectedIndex, //New
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Personnel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Localisation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Mot de passe',
          ),
        ],
      ),

    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

}