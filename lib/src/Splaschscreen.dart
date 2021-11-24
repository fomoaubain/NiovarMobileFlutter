import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:niovar/Constante.dart';
import 'package:niovar/services/LocalNotificationService.dart';
import 'package:niovar/src/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';



class Splaschscreen extends StatefulWidget {
  Splaschscreen({ Key? key,  required this.title}) : super(key: key);

  final String title;

  @override
  _Splaschscreen createState() => _Splaschscreen();

}

class _Splaschscreen extends  State<Splaschscreen>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LocalNotificationService.initialize(context);
    Timer(Duration(seconds: 4),
            () async {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              if(prefs.containsKey('id')){
                Navigator.pop(context);
                Navigator.push(context,MaterialPageRoute(builder: (context)=>Home()));
              }else{
                Navigator.pop(context);
                Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginPage()));
              }

            }
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        Image.asset(
          "assets/background.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          repeat: ImageRepeat.repeat,
        ),
    Scaffold(

    backgroundColor: Colors.transparent,
      body:Container(
        alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center ,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset('assets/icon_og.png', height: 70.0),
        SizedBox(height: 10.0,),
        SizedBox(height: 10.0,),
        SpinKitPulse(
          size: 30,
          color: Colors.white,
        )

      ],
    ),
    )



    )
      ],
    );


  }


}
