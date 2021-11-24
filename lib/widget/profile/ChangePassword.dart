import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:niovar/Constante.dart';
import 'package:niovar/src/LoginPage.dart';
import 'package:niovar/widget/profile/profile_widget.dart';
import 'package:niovar/Global.dart' as session;
import 'package:shared_preferences/shared_preferences.dart';




class ChangePassword extends StatefulWidget {
  @override
  _ChangePassword createState() => _ChangePassword();
}

class _ChangePassword extends  State<ChangePassword>{
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController t1Controller = TextEditingController();
  TextEditingController pwd = TextEditingController();
  TextEditingController confirm_pwd = TextEditingController();

  Future SaveProfil(String password, String user_id) async{
    Dio dio = new Dio();
    final String pathUrl = Constante.serveurAdress+"auth/register/reset/password?password1=${password}&password2=${password}&user_id=${user_id}";
    print(pathUrl);
    var response = await dio.post(pathUrl);
    return response.data;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      body:ListView(
        physics: BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: formKey,
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Nouveau mot de passe',style: Constante.style4,),
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: pwd,
                    decoration: InputDecoration(
                      hintText: "Nouveau mot de passe",
                      contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 15),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Constante.kBlack.withOpacity(0.2))
                      ),

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26)
                      ),
                    ),
                    validator: (String ? value){
                      if(value!.isEmpty){
                        return "Ce champ est obligatoire";
                      }
                      if(value.length>10){
                        return "maximum 10 caracteres";
                      }
                      if(!RegExp(r"^(?:(?=.*?[A-Z])(?:(?=.*?[0-9])(?=.*?[-!@#$%^&*()_])|(?=.*?[a-z])(?:(?=.*?[0-9])|(?=.*?[-!@#$%^&*()_])))|(?=.*?[a-z])(?=.*?[0-9])(?=.*?[-!@#$%^&*()_]))[A-Za-z0-9!@#$%^&*()_]{8,10}$").hasMatch(value)){
                        return "minimum 8 caracteres, 1 majuscule, 1 minuscule et 1 chiffre numerique";
                      }
                      return null;
                    },

                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Confirmer le nouveau mot de passe',style: Constante.style4,),
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: confirm_pwd,
                    decoration: InputDecoration(
                      hintText: "Confirmer mot de passe",
                      contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 15),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Constante.kBlack.withOpacity(0.2))
                      ),

                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black26)
                      ),
                    ),
                    validator: (String ? value){
                      if(value!.isEmpty){
                        return "Confirmer le mot de passe";
                      }
                      if(pwd.text != confirm_pwd.text){
                        return "Mot de passe de confirmation incorrect";
                      }
                      return null;
                    },
                  ),

                ],
              ),
            ),

          ),
        ],
      ) ,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constante.primaryColor,
        onPressed: () async {
          if(formKey.currentState!.validate()){
            Constante.showAlert(context, "Veuillez patientez", "Sauvegarde en cour...", SizedBox(), 100);
            await SaveProfil(pwd.text,session.id).then((value) async {
              print(value.toString());
              if(value['status'].toString()=="1"){
                Navigator.pop(context);
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                session.IsConnected=false;
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginPage()
                    ),
                    ModalRoute.withName("/Home")
                );
              }else{
                Navigator.pop(context);
                Constante.showSnackBarMessage(context, "Erreur durant la l'opération. Veuillez réessayer !");
              }
            }
            );
          }

        },
        child:  Icon(Icons.save),
      ),
    );

  }



}
