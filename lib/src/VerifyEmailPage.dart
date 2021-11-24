import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Constante.dart';
import 'Create_employe/CodeVerificationPage.dart';
import '../Global.dart' as  session;

class VerifyEmailPage extends StatefulWidget {
  @override
    _VerifyEmailPage createState() => _VerifyEmailPage();
}

class _VerifyEmailPage extends State<VerifyEmailPage> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();

  Future VerifyEmail(String email,) async{
    Dio dio = new Dio();
    final String pathUrl = Constante.serveurAdress+"auth/register/reset/password/code?email=${email}";
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
          "" + session.date_debut,
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
                Text(
                  'Mot de passe oublié ?',
                  style: Constante.style4.copyWith(fontSize: 25),
                ),
                SizedBox(height: 10,),
                Text(
                  "Entrez l'adresse courriel associée à votre compte Niovar ci-dessous. Vous recevrez un courriel avec un code de vérification pour réinitialiser votre mot de passe",
                  style: Constante.style4.copyWith(fontSize: 16),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text('Courriel',style: Constante.style4,),
                ),
                TextFormField(
                  controller: email,
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: "Saisir ici",
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
                    if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)){
                      return "Adresse courriel incorrect";
                    }
                    if(value.length>50){
                      return "maximum 50 caracteres";
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
              Constante.showAlert(context, "Veuillez patientez", "Vérification du courriel...", SizedBox(), 100);
              await VerifyEmail(email.text).then((value){
                if(value['status'].toString()=="1"){
                  Navigator.pop(context);
                  String codeValidation=value['code_validation'].toString() ;
                  String IdUser = value['user_id'].toString();
                  print("id user "+IdUser);
                  print("code validation "+codeValidation);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => CodeVerificationPage(true, codeValidation, IdUser, email.text)));
                }else{
                  Navigator.pop(context);
                  Constante.showSnackBarMessage(context, "Erreur durant la vérification du courriel. Veuillez réessayer !");
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