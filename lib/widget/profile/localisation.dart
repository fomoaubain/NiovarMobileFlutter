import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:csc_picker/csc_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:niovar/Constante.dart';
import 'package:niovar/Global.dart' as session;
import 'package:http/http.dart' as http;
import 'package:niovar/model/Pays.dart';
import 'package:niovar/model/Utilisateur.dart';
import 'package:niovar/src/ProfilePage.dart';
import 'package:niovar/widget/profile/CountryStateCitis.dart';


class Localisation extends StatefulWidget {
  @override
  _Localisation createState() => _Localisation();
}

class _Localisation extends  State<Localisation>{
  late FToast fToast;
  DateTime selectedDateEmbauche= DateTime.now();
  DateTime selectedDateDepart= DateTime.now();
  late TextEditingController dateDepart;
  late TextEditingController dateEmbauche;
  late  TextEditingController location;
  late TextEditingController jourTravail;

  late String countryValue="";
  late String stateValue="";
  late String cityValue="";

  late String pays="", province="", ville="", idPays, idVille, idProvince, jou="";

  List<String> listJour=['Dimanche','Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  List<String> listIdJour=['7','1', '2', '3', '4', '5', '6'];
  List<bool> itemCheckedState = [false,false,false,false,false,false,false];
  List<String> listcheckValue=[];
  String checkValue="";
  String checkValuelDay="";
  bool _showLoading = true;
  bool _notInternet = false;

  Future _fetchData() async {
    try {
      Utilisateur user;
      final results = await Future.wait([
        http.post(Uri.parse(Constante.serveurAdress+"auth/register/profile?user_id="+session.id)).timeout(Duration(seconds: 10)),
      ]);
      setState(() {
        final responseUtilisateur= jsonDecode(results[0].body)['profile'];
        if(responseUtilisateur!=null){
          user=Utilisateur.fromJson(responseUtilisateur);
          dateDepart = TextEditingController(text: user.date_depart);
          dateEmbauche = TextEditingController(text: user.date_embauche.toString().isNotEmpty ? dateEmbauche.toString() :"Information à completer par l'administrateur");

          if(user.jours.toString().isNotEmpty){
            checkValue=user.jours.toString();
            var val = user.jours.toString().split("*");
            String day="";
            for (var i = 0; i < val.length; i++) {
              if(val[i].toString()=="1")  day=day+"Lundi,";
              if(val[i].toString()=="2")  day=day+" Mardi,";
              if(val[i].toString()=="3")  day=day+"Mercredi,";
              if(val[i].toString()=="4")  day=day+"Jeudi,";
              if(val[i].toString()=="5")  day=day+" Vendredi,";
              if(val[i].toString()=="6")  day=day+"Samedi,";
              if(val[i].toString()=="7")  day=day+"Dimanche,";
            }
            jourTravail= TextEditingController(text: ""+day.toString());
          }else{
            checkValue="";
            jourTravail= TextEditingController(text: "");
          }
          session.pays=user.pays;
          session.province=user.province;
          session.ville=user.ville;

          location= TextEditingController(text: session.pays +", "+ session.province+", "+session.ville);
        }
        _showLoading = false;
      });
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');
      setState(() {
        _notInternet=true;
        _showLoading=false;
      });
    } on SocketException catch (e) {
      print('Socket Error: $e');
      _notInternet=true;
      _showLoading=false;
    } on Error catch (e) {
      print('General Error: $e');
      _notInternet=true;
      _showLoading=false;
    }

  }


  Future SaveProfil( String idPays, String idProvince,String idVille, String jours,String user_id) async{
    Dio dio = new Dio();
    final String pathUrl = Constante.serveurAdress+"auth/register?pays_id=${idPays}&province_id=${idProvince}&ville_id=${idVille}&days_id=${jours}&user_id=${user_id}";
    print(pathUrl);
    var response = await dio.post(pathUrl);
    return response.data;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast = FToast();
    fToast.init(context);
    session.idPays="";
    session.idProvince="";
    session.idVille="";
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      body:_notInternet ? Center(child: Constante.layoutNotInternet(context, MaterialPageRoute(builder: (context) => ProfilePage()))) :
      ListView(
        physics: BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showLoading)
                 Center(child: Constante.circularLoader()),
                 if (!_showLoading) ...[
                const SizedBox(height: 20),
                Text("Date de d'embauche", style: Constante.style4,),
                SizedBox(height:5),
                   TextFormField(
                     controller: dateEmbauche,
                     obscureText: false,
                     readOnly: true,
                     decoration: InputDecoration(
                       suffixIcon: IconButton(
                         onPressed: (){
                         },
                         icon: Icon(Icons.calendar_today_sharp),
                       ),
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
                       return null;
                     },
                   ),
                const SizedBox(height: 20),
                Text("Date de départ", style: Constante.style4,),
                SizedBox(height:5),
                TextFormField(
                  controller: dateDepart,
                  obscureText: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: (){
                      },
                      icon: Icon(Icons.calendar_today_sharp),
                    ),
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
                    return null;
                  },
                ),
                SizedBox(height:25),
                Row(
                  children: [
                    Expanded(child:
                    Text.rich(
                      TextSpan(
                        style:Constante.style4,
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.location_on,color:Colors.black45, size: 22.0,),
                          ),
                          TextSpan(
                            text: " Pays, province et ville",
                          )
                        ],
                      ),
                    ),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        child: InkWell(
                          onTap: () {
                            _awaitReturnValueFromSecondScreen(context);
                          },
                          child: Icon(Icons.edit_location_outlined,color: Constante.primaryColor,size: 24,),
                        )
                    ),
                  ],
                ),
                SizedBox(height:5),
                TextFormField(
                  controller: location,
                  cursorColor: Colors.black,
                  maxLines: 2,
                  readOnly: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      hintStyle: Constante.style5,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Constante.kBlack),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Constante.kBlack.withOpacity(0.3)),
                      )
                  ),
                  style: Constante.style4,
                ),
                SizedBox(height:25),
                Row(
                  children: [
                    Expanded(child:
                    Text.rich(
                      TextSpan(
                        style:Constante.style4,
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.date_range,color:Colors.black45, size: 22.0,),
                          ),
                          TextSpan(
                            text: "Disponibilité",
                          )
                        ],
                      ),
                    ),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        child: InkWell(
                          onTap: () {
                            showAlertSelectJour(context);
                          },
                          child: Icon(Icons.edit_road,color: Constante.primaryColor,size: 24,),
                        )
                    ),

                  ],
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: jourTravail,
                  cursorColor: Colors.black,
                  maxLines: 1,
                  readOnly: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      hintStyle: Constante.style5,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Constante.kBlack),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Constante.kBlack.withOpacity(0.3)),
                      )
                  ),
                  style: Constante.style4,
                ),
                 ]
              ],
            ),
          ),
        ],
      ) ,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constante.primaryColor,
        onPressed: () async {
          print(dateDepart.text.toString());
          print(session.idPays.toString());
          print(session.idProvince.toString());
          print(session.idVille.toString());
          print(checkValue);
          print(session.id);

          Constante.showAlert(context, "Veuillez patientez", "Sauvegarde en cour...", SizedBox(), 100);
          await SaveProfil(session.idPays,session.idProvince,session.idVille,checkValue,session.id).then((value){
            print(value.toString());
            if(value['status'].toString()=="1"){
              Navigator.pop(context);
              Constante.showToastSuccess("Sauvegarde effectué avec succès", fToast);
            }else{
              Navigator.pop(context);
              Constante.showSnackBarMessage(context, "Erreur durant la sauvegarde. Veuillez réessayer !");
            }
          }
          );
        },
        child:  Icon(Icons.save),
      ),
    );
  }

  _selectDateDepart(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDateDepart,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (selected != null && selected != selectedDateDepart)
      setState(() {
        selectedDateDepart = selected;
        dateDepart.text="${selectedDateDepart.day<=9 ? "0"+selectedDateDepart.day.toString(): selectedDateDepart.day}-${selectedDateDepart.month<=9 ? "0"+selectedDateDepart.month.toString(): selectedDateDepart.month}-${selectedDateDepart.year}";
      });
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
                                listcheckValue.clear();
                                checkValuelDay="";
                                checkValue="";
                                for(int i = 0; i < itemCheckedState.length; i++){
                                  if(itemCheckedState[i]==true){
                                    checkValue=checkValue + listIdJour[i]+"*";
                                    checkValuelDay=checkValuelDay + listJour[i]+",";
                                  }}
                                setState(() {
                                  jourTravail.text=checkValuelDay.toString();
                                });
                                Navigator.pop(context);
                              },
                              color: Constante.primaryColor,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)
                              ),
                              child: Text("Terminer", style: TextStyle(
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


  void _awaitReturnValueFromSecondScreen(BuildContext context) async {

    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CountryStateCitis(),
        ));
    // after the SecondScreen result comes back update the Text widget with it
    setState(() {
    location.text=session.pays +", "+ session.province+", "+session.ville;
    });
  }

}
