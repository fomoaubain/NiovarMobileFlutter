
import 'dart:io';
import 'dart:ui';

import 'package:background_app_bar/background_app_bar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';

import '../../Constante.dart';
import '../LoginPage.dart';


class Etape4 extends StatefulWidget {

  late  String idUser;
  // late bool ispasswordforget;
  Etape4( this.idUser);
  @override
  _Etape4 createState() => _Etape4();
}

class _Etape4 extends State<Etape4> {
  late FToast fToast;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController t1Controller = TextEditingController();

  late String _fileName="";

  int indicator = 0;

  late String _path;
  late Map<String, String> _paths;
  late String _extension;
  late FileType _pickingType;
  late bool imageCheck = false;

  late String nomFileFromServer;

  Future uploadProfile( String path, String fileName ) async{
    Dio dio = new Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    final String pathUrl =Constante.serveurAdressFile+"register/api/pic";
    FormData formData = new FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: fileName),
    });
    var response = await dio.post(pathUrl,
      data: formData
    );
    return response.data;
  }

  Future saveNameFile( String idUser, String nameFile ) async{
    Dio dio = new Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    final String pathUrl =Constante.serveurAdress+"auth/register/profilepic?pic_url=${nameFile}&user_id=${idUser}";

    var response = await dio.post(pathUrl);
    return response.data;
  }

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,
      allowedExtensions: ['jpg','png', 'jpeg'],);

    if(result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        imageCheck=true;
        _path= file.path.toString();
        _fileName= file.name;
      });

    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);

  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        body: new NestedScrollView(
          headerSliverBuilder:  (_, __) => <Widget>[
            new SliverAppBar(
              floating: false,
              pinned: true,
              snap: false,
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              flexibleSpace: new BackgroundFlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(top: 45),
                background: new ClipRect(
                  child: new Container(
                    child: new BackdropFilter(
                      filter: new ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                      child: new Container(
                        decoration: new BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    decoration: new BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                              "assets/background.png",
                            ),
                            fit: BoxFit.fitWidth
                        )
                    ),
                  ),
                ),
              ),
            )
          ],
          body:Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            // margin: EdgeInsets.only(top: 50.0),
            padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text("Création de compte", style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold
                          ),),
                          SizedBox(height: 20,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("J'ai déjà un compte"),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => LoginPage()));
                                },
                                child:    Text(" Se connecter", style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15, color: Constante.primaryColor
                                ),),
                              ),

                            ],
                          )
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.withOpacity(.5)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 10,),
                            Text("Etape 4/4", style: TextStyle(color: Colors.grey),),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 0),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 20,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Center(
                                        child: Constante.makelabel("Choisir votre image de profile"),
                                      ),
                                      SizedBox(height: 15,),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        margin: EdgeInsets.symmetric(horizontal: 30),
                                        child: InkWell( onTap: (){
                                          _openFileExplorer();
                                        },
                                          child: Container(
                                            height: 160,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Constante.kBlack.withOpacity(0.2),),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 12,bottom: 12,left: 12),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Center(
                                                      child:Icon(Icons.account_circle,size: 90,color: Constante.kBlack.withOpacity(0.2),)),
                                                  SizedBox(
                                                    width: 20,
                                                  ),

                                                  imageCheck ?
                                                  Constante.TextwithIcon(Icons.check_circle_outline, _fileName, Colors.green, 12) :
                                                  Text(
                                                    "Selectionner une image" ,
                                                    style: Constante.style6,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20,),
                                      customButton("Importer"),
                                      SizedBox(height: 10,),
                                    ],
                                  ),
                                ],
                              ),
                            ),


                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget customButton(text){
    return InkWell(
      child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Constante.primaryColor,
          child: InkWell( onTap: () async {
            if(_fileName.isEmpty ){
              _showToast("Veuillez sélectionner une image");
              return;
            }
            Constante.showAlert(context, "Veuillez patientez", "Sauvegarde du profil en cour...", SizedBox(), 100);
            await uploadProfile(_path, _fileName).then((value) async {
              if(value['status'].toString()=="1"){
                nomFileFromServer = value['message'].toString();
                await saveNameFile(widget.idUser, nomFileFromServer).then((value){
                  if(value['status'].toString()=="1"){
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginPage()
                        ),
                        ModalRoute.withName("/Home")
                    );
                  }else{
                    Navigator.pop(context);
                    Constante.showSnackBarMessage(context, value['message'].toString());
                  }
                });
              }else{
                Navigator.pop(context);
                Constante.showSnackBarMessage(context, value['message'].toString());
              }
            }
            );
          },
            child: Container(
              height: 55,
              width: double.infinity,
              child: Center(
                child: Text(text,style: Constante.kTitleStyle.copyWith(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400
                ),),
              ),
            ),
            borderRadius: BorderRadius.circular(10),
          )
      ),
    );
  }

  _showToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black87,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: Colors.white,),
          SizedBox(
            width: 12.0,
          ),
          Text(msg, style: TextStyle(color: Colors.white, fontSize: 12),),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );

  }


}