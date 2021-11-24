
import 'dart:ui';

import 'package:background_app_bar/background_app_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:niovar/src/Create_employe/Etape2.dart';
import '../../Constante.dart';
import '../LoginPage.dart';
import '../../Global.dart' as session;

class Etape1 extends StatefulWidget {

  @override
  _Etape1 createState() => _Etape1();
}

class _Etape1 extends State<Etape1>  {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController code = TextEditingController();

  @override
  void initState()  {
    super.initState();
  }

  Future VerificationCode(String code) async{
    print(code);
    Dio dio = new Dio();
    final String pathUrl = Constante.serveurAdress+"auth/register/company?code="+code;
    var response = await dio.post(pathUrl );
    print(response.data.toString());
    return response.data;

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
              child: Form(
                key: formKey,
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
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.withOpacity(.5)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 10,),
                                Text("Etape 1/4", style: TextStyle(color: Colors.grey),),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 0),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(height: 20,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Constante.makelabel("Saisir le code de l'entreprise"),
                                          SizedBox(height: 5,),
                                          TextFormField(
                                            controller: code,
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black26)
                                              ),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black26)
                                              ),
                                            ),
                                            validator: (String ? value){
                                              if(value!.isEmpty){
                                                return "Ce champ est obligatoire";
                                              }
                                              return null;
                                            },

                                          ),

                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.0),
                                        border: Border(
                                          bottom: BorderSide(color: Colors.white54),
                                          top: BorderSide(color: Colors.white54),
                                          left: BorderSide(color: Colors.white54),
                                          right: BorderSide(color: Colors.white54),
                                        )
                                    ),
                                    child: MaterialButton(
                                      minWidth: double.infinity,
                                      height: 60,
                                      onPressed: () async{
                                        if(formKey.currentState!.validate()){
                                          Constante.showAlert(context, "Veuillez patientez", "Vérification en cour...", SizedBox(), 100);
                                          await VerificationCode( code.text).then((value){
                                            if(value['status'].toString()=="1"){
                                              Navigator.pop(context);
                                              setState(() {
                                                session.codeEntreprise= code.text;
                                              });
                                              Navigator.push(
                                                  context, MaterialPageRoute(builder: (context) => Etape2()));

                                            }else{
                                              Navigator.pop(context);
                                              Constante.showSnackBarMessage(context, "Ce numéro ne correspond a aucune entreprise");
                                            }

                                          }
                                          );

                                        }else{
                                          print("unsuccefully");
                                        }

                                      },
                                      color: Constante.primaryColor,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.0)
                                      ),
                                      child: Text("Continuer", style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                          color: Colors.white
                                      ),),
                                    ),
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
              )

          ),
        ),
      );

  }


}