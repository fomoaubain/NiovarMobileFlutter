import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:niovar/Global.dart' as session;

import '../Constante.dart';
import 'Create_employe/CodeVerificationPage.dart';
import 'LoginPage.dart';

class EditPwdForget extends StatefulWidget {
  late String idUser;
  EditPwdForget(this.idUser);

  @override
  _EditPwdForget createState() => _EditPwdForget();
}

class _EditPwdForget extends State<EditPwdForget> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController pwd = TextEditingController();
  TextEditingController confirm_pwd = TextEditingController();

  Future EditPwd(String password, String user_id ) async{
    Dio dio = new Dio();
    final String pathUrl = Constante.serveurAdress+"auth/register/reset/password?password1=${password}&password2=${password}&user_id=${user_id}";
    print(pathUrl);
    var response = await dio.post(pathUrl);
    return response.data;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constante.kSilver,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Constante.primaryColor, //change your color here
        ),
        backgroundColor: Constante.kSilver,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Constante.kBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Réinitialiser mon mot de passe",
          style: GoogleFonts.questrial(
            fontSize: 16.0,
            color: Constante.primaryColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),

      body: Container( margin: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
        child: SingleChildScrollView(
          child:Form(
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

                SizedBox(height: 50,),
                customButton("Réinitialiser mon mot de passe"),

              ],
            ),
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
            if(formKey.currentState!.validate()){
              Constante.showAlert(context, "Veuillez patientez", "Sauvegarde en cour...", SizedBox(), 100);
              await EditPwd(pwd.text,widget.idUser).then((value) async {
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
}