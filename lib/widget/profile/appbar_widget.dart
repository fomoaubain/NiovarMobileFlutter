import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Constante.dart';

AppBar buildAppBar(BuildContext context) {
  final icon = CupertinoIcons.moon_stars;

  return AppBar(
    leading: BackButton(),
    iconTheme: IconThemeData(
      color: Constante.primaryColor, //change your color here
    ),
    title: Text(
      "Mon profil",
      style: GoogleFonts.questrial(
        fontSize: 16.0,
        color: Constante.primaryColor,
        fontWeight: FontWeight.w400,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
    ],
  );
}