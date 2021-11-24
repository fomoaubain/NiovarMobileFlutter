import 'dart:ffi';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:niovar/Constante.dart';
import 'package:niovar/src/Home.dart';
import 'package:niovar/src/ProfilePage.dart';
import 'package:niovar/Global.dart' as session;

class NavigationDrawerWidget extends StatelessWidget {
  final padding = EdgeInsets.symmetric(horizontal: 20);
  @override
  Widget build(BuildContext context) {
    final name = Constante.truncateWithEllipsis(10, session.login);
    final urlImage = Constante.serveurAdressImage+session.profil;
    return Drawer(
      child: Material(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            buildHeader(
              urlImage: urlImage,
              name: name,
              onClicked: (){
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ));
              }
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  buildMenuItem(
                    text: 'Mon calendrier de travail',
                    icon: Icons.calendar_today_sharp,
                    nbre: "0",
                    onClicked: () => selectedItem(context, 0),
                  ),
                  Divider(),
                  /*const SizedBox(height: 12),
                  buildMenuItem(
                    text: 'Messagerie',
                    icon: Icons.mail_outline,
                    nbre: "0",
                    onClicked: () => selectedItem(context, 1),
                  ),
                  Divider(),
                  const SizedBox(height: 12),
                  buildMenuItem(
                    text: 'Chat',
                    icon: Icons.message,
                    nbre: "0",
                    onClicked: () => selectedItem(context, 2),
                  ),
                  Divider(),
                  const SizedBox(height: 12),
                  buildMenuItem(
                    text: 'Publications',
                    icon: Icons.post_add,
                    nbre: "0",
                    onClicked: () => selectedItem(context, 3),
                  ),
                  Divider(),
                  const SizedBox(height: 12),
                  buildMenuItem(
                    text: 'Mes talons de paie',
                    icon: Icons.monetization_on_rounded,
                    nbre: "0",
                    onClicked: () => selectedItem(context, 4),
                  ),
                  Divider(),
                  const SizedBox(height: 12),
                  buildMenuItem(
                    text: 'Mes fiches impots',
                    icon: Icons.insert_drive_file,
                    nbre: "0",
                    onClicked: () => selectedItem(context, 5),
                  ),
                  Divider(),
                  const SizedBox(height: 12),
                  buildMenuItem(
                    text: "Mes relevés d'emploi",
                    icon: Icons.filter_frames,
                    nbre: "0",
                    onClicked: () => selectedItem(context, 5),
                  ),
                  Divider(),
                  const SizedBox(height: 12),
                  buildMenuItem(
                    text: 'Gestion des vacances',
                    icon: Icons.free_breakfast_outlined,
                    nbre: "0",
                    onClicked: () => selectedItem(context, 5),
                  ),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          padding: padding.add(EdgeInsets.symmetric(vertical: 40)),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 4),

                ],
              ),
              Spacer(),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(Icons.settings, color: Colors.black45),
              )
            ],
          ),
        ),
      );



  Widget buildMenuItem({
    required String text,
    required IconData icon,
    required var nbre,
    VoidCallback? onClicked,
  }) {
    final color = Colors.black45;
    final hoverColor = Colors.grey;

    return ListTile(
      leading:Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      trailing: Badge(
        badgeContent: Text(nbre, style: TextStyle(color: Colors.white),),
        badgeColor: Colors.green,
        child: null,
      ),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => Home()
            ),
            ModalRoute.withName("/Home")
        );
        break;
    }
  }
}