
import 'dart:convert';
import 'dart:ui';

import 'package:background_app_bar/background_app_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_button/group_button.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:niovar/Global.dart';
import 'package:niovar/model/Departement.dart';
import 'package:niovar/src/Create_employe/CodeVerificationPage.dart';
import '../../Constante.dart';
import '../LoginPage.dart';
import 'package:http/http.dart' as http;
import 'package:niovar/Global.dart' as session;

class Etape3 extends StatefulWidget {

  @override
  _Etape3 createState() => _Etape3();
}

class _Etape3 extends State<Etape3>  {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validateNumber=false;
  bool validateAutreTelephone=false;
  String sexe="";
  List<String> jour=[];
  late String name, email, telephone, autreTelephone="";
  String selectSexe = 'Aucun choix';
  late String departement='Aucun choix';
  final TextEditingController pwd = TextEditingController();
  final TextEditingController confirm_pwd = TextEditingController();
  String idDep="";
  late Future<List<Departement>> listDepartement;
  late List<Departement> listDepartementData=[];
  List<String> listDepartementLibelle=["Aucun choix"];

  List<String> listSexe=['Aucun choix', 'Feminin', 'Masculin'];
  List<String> listJour=['Dimanche','Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  List<String> listIdJour=['7','1', '2', '3', '4', '5', '6'];
  List<bool> itemCheckedState = [false,false,false,false,false,false,false];

  final TextEditingController controller = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  String initialCountry = 'CA';
  PhoneNumber number = PhoneNumber(isoCode: 'CA');
  PhoneNumber number2 = PhoneNumber(isoCode: 'CA');

  bool _showLoading = true;
  late String checkValue="";

  Future fetchItem() async {
    List<Departement> listModel = [];

    var url = Uri.parse(Constante.serveurAdress+"auth/register/department?code="+session.codeEntreprise);
    var response = await http.post(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(Utf8Decoder().convert(response.bodyBytes))['dep'];
      if (data.toString().isNotEmpty) {
        data.forEach((element) {
          listModel.add(Departement.fromJson(element));
        });
        listModel.forEach((element) {
          listDepartementLibelle.add(element.nom);
        });
        listDepartementData=listModel.toList();

        setState(() {
          _showLoading = false;
        });
      }
    }
  }


  Future AddUser(String nom, String email, String tel,String autreTel, String sexe, String jour,String pwd,var code,String idDep ) async{
    Dio dio = new Dio();
    final String pathUrl = Constante.serveurAdress+"auth/register?name=${nom}&password=${pwd}&email=${email}&sex_id=${sexe}&phone01=${tel}&phone02=${autreTel}&days_id=${jour}&department_id=${idDep}&code=${code}";
    print(pathUrl);
    var response = await dio.post(pathUrl);
    return response.data;
  }

  @override
  void initState(){
    super.initState();
    fetchItem();
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
          body: Container(
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
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  child:SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 10,),
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
                        ),
                        SizedBox(height: 5,),
                        Text("Etape 3/4", style: TextStyle(color: Colors.grey),),
                        SizedBox(height: 5,),
                        Center(
                          child: Text("Vos informations",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        ),
                        if (_showLoading)
                          Center(child: Constante.circularLoader()),
                        if (!_showLoading) ...[
                          SizedBox(height: 15,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Constante.makelabel("Nom complet (*)"),
                              SizedBox(height: 5,),
                              TextFormField(
                                obscureText: false,
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
                                  if(value.length>50){
                                    return "maximum 50 caracteres";
                                  }
                                  name= value;
                                  return null;
                                },
                                onSaved: (String ?  value){
                                  name = value!;
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Constante.makelabel("Courriel (*)"),
                              SizedBox(height: 5,),
                              TextFormField(
                                obscureText: false,
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
                                  if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)){
                                    return "Adresse courriel incorrect";
                                  }
                                  if(value.length>50){
                                    return "maximum 50 caracteres";
                                  }
                                  email = value;
                                  return null;
                                },

                                onSaved: (String ? name){
                                  email = name!;
                                },
                              ),

                            ],
                          ),
                          SizedBox(height: 10,),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text("Sexe (*)", style: Constante.style4,),
                          ),
                          selectedSexe(),
                          SizedBox(height: 10,),
                          InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber number) {
                              print(number.phoneNumber);
                              telephone = number.phoneNumber!;
                            },
                            onInputValidated: (bool value) {
                              validateNumber=value;
                            },
                            selectorConfig: SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            ),
                            ignoreBlank: false,
                            autoValidateMode: AutovalidateMode.disabled,
                            selectorTextStyle: TextStyle(color: Colors.black),
                            initialValue: number,
                            textFieldController: controller,
                            inputDecoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black26)
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black26)
                              ),
                              hintText: 'Numéro de téléphone (*)',
                            ),
                            formatInput: false,
                            keyboardType:
                            TextInputType.numberWithOptions(signed: true, decimal: true),
                            inputBorder: OutlineInputBorder(),
                            validator: (String ? value){
                              if(value!.isEmpty){
                                return "Ce champ est obligatoire";
                              }
                              if(!validateNumber){
                                return "Numero de telephone incorrect";
                              }
                              return null;
                            },

                          ),
                          SizedBox(height: 10,),
                          InternationalPhoneNumberInput(
                            onInputChanged: (PhoneNumber number) {
                              autreTelephone = number.phoneNumber!;
                            },
                            onInputValidated: (bool value) {
                              validateAutreTelephone=value;
                            },
                            selectorConfig: SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            ),
                            ignoreBlank: false,
                            autoValidateMode: AutovalidateMode.disabled,
                            selectorTextStyle: TextStyle(color: Colors.black),
                            initialValue: number2,
                            textFieldController: controller2,
                            inputDecoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black26)
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black26)
                              ),
                              hintText: 'Autre numéro',
                            ),
                            formatInput: false,
                            keyboardType:
                            TextInputType.numberWithOptions(signed: true, decimal: true),
                            inputBorder: OutlineInputBorder(),
                          ),
                          SizedBox(height:10),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text("Département de travail (*)",style: Constante.style4,),
                          ),
                          SelectDepartement(),
                          SizedBox(height: 15,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Constante.makelabel("Mot de passe (*)"),
                              SizedBox(height: 5,),
                              TextFormField(
                                controller: pwd,
                                obscureText: true,
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
                                  if(value.length>10){
                                    return "maximum 10 caracteres";
                                  }
                                  if(!RegExp(r"^(?:(?=.*?[A-Z])(?:(?=.*?[0-9])(?=.*?[-!@#$%^&*()_])|(?=.*?[a-z])(?:(?=.*?[0-9])|(?=.*?[-!@#$%^&*()_])))|(?=.*?[a-z])(?=.*?[0-9])(?=.*?[-!@#$%^&*()_]))[A-Za-z0-9!@#$%^&*()_]{8,10}$").hasMatch(value)){
                                    return "minimum 8 caracteres, 1 majuscule, 1 minuscule et 1 chiffre numerique";
                                  }
                                  return null;
                                },

                              ),

                            ],
                          ),
                          SizedBox(height: 15,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Constante.makelabel("Confirmer le mot de passe (*)"),
                              SizedBox(height: 5,),
                              TextFormField(
                                controller: confirm_pwd,
                                obscureText: true,
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
                          SizedBox(height: 25,),
                        ]
                      ],
                    ),

                  )

                )
              )

          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Constante.primaryColor,
          onPressed: () async {
            if(formKey.currentState!.validate()){
              if( sexe.isEmpty || idDep.isEmpty){
                Constante.showSnackBarMessage(context, "Veuillez remplir tous les champs du obligatoire (*)");
                return;
              }
              showAlertSelectJour(context);


            }
          },
          child:  Icon(Icons.send),
        ),
      );


  }

  selectedSexe(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Constante.kBlack.withOpacity(0.2)),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 20, top: 5),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: selectSexe,
                icon: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.keyboard_arrow_down_outlined),
                ),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 0,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: ( newValue) {
                  if(newValue.toString().contains("Feminin")){
                    sexe="2";
                  }
                  if(newValue.toString().contains("Masculin")){
                    sexe="1";
                  }

                  if(newValue.toString().contains("Aucun choix")){
                    sexe="";
                  }

                  setState(() {
                    selectSexe = newValue!;
                  });
                },
                isExpanded: true,
                items: listSexe.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value,
                      child: ItemDropmenu(value)
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ItemDropmenu(String value) {
    return  Container(
      alignment: Alignment.centerLeft,
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.questrial(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
                children: [
                  WidgetSpan(
                    child: Icon(Icons.arrow_right,color:Colors.black54, size: 15.0,),
                  ),
                  TextSpan(
                    text: value,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }


  SelectDepartement(){

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Constante.kBlack.withOpacity(0.2)),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 20, top: 5),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                hint: Text('Selectionnez le departement'),
                value: departement,
                icon: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.keyboard_arrow_down_outlined),
                ),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 0,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: ( newValue) async{
                  listDepartementData.forEach((element){
                    if(newValue.toString()== element.nom.toString()){
                      newValue = newValue.toString();
                      idDep=element.id.toString();
                    }
                  });
                  setState(() {
                    departement = newValue!;
                    if(departement=="Aucun choix"){
                      idDep="";
                      return;
                    }
                  });


                },
                isExpanded: true,
                items: listDepartementLibelle.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value,
                      child: ItemDropmenu(value)

                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void showAlertSelectJour(BuildContext context) {

    showDialog(
      context: context,
      builder: (context){
        return StatefulBuilder(builder: (context, setState){
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(20.0)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container (
                height: 500,
                child: SingleChildScrollView(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text("Jour(s) de travail (*)", style: TextStyle( fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      Divider(),
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:  listJour.length,
                          itemBuilder: (context,i){
                            return CheckboxListTile(
                                value: itemCheckedState[i],
                                title: Text(listJour[i]),
                                onChanged: (newValue) {
                                  print(newValue);
                                  setState(() {
                                    itemCheckedState[i] = newValue!;
                                  });
                                });
                          }
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
                              checkValue="";
                              for(int i = 0; i < itemCheckedState.length; i++){
                                if(itemCheckedState[i]==true){
                                  checkValue=checkValue + listIdJour[i]+"*";
                                }
                              }

                              if(checkValue.isEmpty){
                                Constante.showSnackBarMessage(context, "Veuillez sélectionner au moins une catégorie");
                                return;
                              }

                              Constante.showAlert(context, "Veuillez patientez", "Création de votre compte en cour...", SizedBox(), 100);
                              await AddUser(name,email,telephone,autreTelephone,sexe,checkValue,pwd.text,codeEntreprise,idDep).then((value){
                                if(value['status'].toString()=="1"){
                                  Navigator.pop(context);
                                  String codeValidation=value['code_validation'].toString() ;
                                  String IdUser = value['user_id'].toString();
                                  print("id user "+IdUser);
                                  print("code validation "+codeValidation);
                                  Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => CodeVerificationPage(false, codeValidation, IdUser, email)));
                                }else{
                                  Navigator.pop(context);
                                  Constante.showSnackBarMessage(context, value['message'].toString());
                                }

                              }
                              );
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
              ),

            ),
          );
        });
      }


    );
  }

}