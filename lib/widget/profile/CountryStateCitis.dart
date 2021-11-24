import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:niovar/model/Pays.dart';
import 'package:niovar/model/Utilisateur.dart';

import '../../Constante.dart';
import '../Constante.dart';
import 'package:niovar/Global.dart' as session;
import 'package:http/http.dart' as http;

class CountryStateCitis extends StatefulWidget {
  @override
  _CountryStateCitis createState() => _CountryStateCitis();

}

class _CountryStateCitis extends State<CountryStateCitis> {

  late String selectPays="Aucun choix", selectProvince="Aucun choix", selectVille="Aucun choix";
  bool _showLoading = true;
  List<Pays> listPays=[];   List<Province> listProvince=[];  List<Ville> listVille=[];
  List<String> listPaysLibelle=[], listProvinceLibelle =[],  listVilleLibelle =[];
  List<String> listPaysLibelleNotDuplicate=[], listProvinceLibelleNotDuplicate=[], listVilleLibelleNotDuplicate=[];

  late String pays="", province="", ville="", idPays="", idVille="", idProvince="", _selectedValue="1";

  Future _fetchData() async {
    Utilisateur user;
    final results = await Future.wait([
      http.post(Uri.parse(Constante.serveurAdress+"auth/register/pays")),
    ]);
    setState(() {
      final responseListPays = jsonDecode(results[0].body)['pays'];
      if(responseListPays!=null){
        List<Pays> listModelPays = [];
        responseListPays.forEach((element) {
          listModelPays.add(Pays.fromJson(element));
          listPaysLibelle.add(Pays.fromJson(element).pays_nom);
        });
        listPays = listModelPays.toList();
        listPaysLibelleNotDuplicate = listPaysLibelle.toSet().toList();
       // selectPays=listPaysLibelleNotDuplicate.first.toString();
      }
      _showLoading = false;

    });
  }

  Future FindProvince(String id ) async{
    final String pathUrl = Constante.serveurAdress+"auth/register/province?pays_id="+id;
    final response = await http.post(Uri.parse(pathUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['provinces'];
      return data;
    }else{
      return null;
    }
  }

  Future FindVille(String id ) async{
    final String pathUrl = Constante.serveurAdress+"auth/register/ville?province_id="+id;
    final response = await http.post(Uri.parse(pathUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['villes'];
      return data;
    }else{
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
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
          "Pays, province et ville",
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
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showLoading)
                  Center(child: Constante.circularLoader()),
                if (!_showLoading) ...[
                SizedBox(height: 20,),
                  Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: DropdownSearch<String>(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: "Choisir le pays",
                            labelText: "Choisir le pays*",
                            contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                            border: OutlineInputBorder(),
                          ),
                          mode: Mode.MENU,
                          items: listPaysLibelleNotDuplicate,
                          validator: (v) => v == null ? "required field" : null,
                          showSearchBox: true,
                          onChanged: (newValue){
                            listPays.forEach((element){
                              if(newValue.toString()== element.pays_nom.toString()){
                                idPays=element.pays_id.toString();
                              }
                            });

                            setState(() {
                              selectPays = newValue!;
                              if(selectPays=="Aucun choix"){
                                idPays="";
                                return;
                              }
                              Constante.showAlert(context, "Veuillez patientez", "Chargement des provinces...", SizedBox(), 100);
                              FindProvince(idPays).then((value){
                                print(value.toString());
                                if(value!=null){
                                  listProvince.clear();
                                  listProvinceLibelle.clear();
                                  value.forEach((element) {
                                    listProvince.add(Province.fromJson(element));
                                    listProvinceLibelle.add(Province.fromJson(element).province_nom);
                                  });
                                  setState(() {
                                    selectProvince="Aucun choix";
                                    idProvince="";
                                    listProvinceLibelleNotDuplicate = listProvinceLibelle.toSet().toList();
                                  });
                                  Navigator.pop(context);
                                }else{
                                  Navigator.pop(context);
                                }
                              });
                            });

                          },
                          selectedItem: selectPays),
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: DropdownSearch<String>(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: "Choisir la province",
                          labelText: "Choisir la province*",
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          border: OutlineInputBorder(),
                        ),
                        mode: Mode.MENU,
                        items: listProvinceLibelleNotDuplicate,
                        validator: (v) => v == null ? "required field" : null,
                        showSearchBox: true,
                        onChanged: (newValue){
                          listProvince.forEach((element){
                            if(newValue.toString()== element.province_nom.toString()){
                              idProvince=element.province_id.toString();
                            }
                          });

                          setState(() {
                            selectProvince = newValue!;
                            if(selectProvince=="Aucun choix"){
                              idProvince="";
                              selectVille="Aucun choix";
                              listVilleLibelleNotDuplicate.clear();
                              return;
                            }
                            Constante.showAlert(context, "Veuillez patientez", "Chargement des villes...", SizedBox(), 100);
                            FindVille(idProvince).then((value){
                              print(value);
                              if(value!=null){
                                listVille.clear();
                                listVilleLibelle.clear();
                                value.forEach((element) {
                                  listVille.add(Ville.fromJson(element));
                                  listVilleLibelle.add(Ville.fromJson(element).ville_nom);
                                });
                                setState(() {
                                  selectVille="Aucun choix";
                                  idVille= "";
                                  listVilleLibelleNotDuplicate = listVilleLibelle.toSet().toList();
                                });
                                Navigator.pop(context);
                              }else{
                                Navigator.pop(context);
                              }
                            });
                          });

                        },
                        selectedItem: selectProvince),
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: DropdownSearch<String>(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: "Choisir la ville",
                          labelText: "Choisir la ville*",
                          contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
                          border: OutlineInputBorder(),
                        ),
                        mode: Mode.MENU,
                        items: listVilleLibelleNotDuplicate,
                        validator: (v) => v == null ? "required field" : null,
                        showSearchBox: true,
                        onChanged: (newValue){
                          listVille.forEach((element){
                            if(newValue.toString()== element.ville_nom.toString()){
                              newValue = newValue.toString();
                              idVille=element.ville_id.toString();
                            }
                          });
                          setState(() {
                            selectVille = newValue!;
                          });
                        },
                        selectedItem: selectVille),
                  ),
                  SizedBox(height: 20,),
                customButton("Terminer"),

                ]
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
            if(idPays.isNotEmpty && idProvince.isNotEmpty && idVille.isNotEmpty){
              setState(() {
                session.ville=selectVille;
                session.province=selectProvince;
                session.pays=selectPays;
                session.idVille=idVille;
                session.idProvince=idProvince;
                session.idPays=idPays;

              });
              Navigator.pop(context, "1");
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

 /* SelectPays(){
    return  Container(
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
                hint: Text('Selectionnez le pays'),
                value: selectPays,
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
                  listPays.forEach((element){
                    if(newValue.toString()== element.pays_nom.toString()){
                      newValue = newValue.toString();
                      idPays=element.pays_id.toString();
                    }
                  });
                  setState(() {
                    selectPays = newValue!;
                    if(selectPays=="Aucun choix"){
                      idPays="";
                      return;
                    }
                    Constante.showAlert(context, "Veuillez patientez", "Chargement des provinces...", SizedBox(), 100);
                    FindProvince(idPays).then((value){
                      print(value.toString());
                      if(value!=null){
                        listProvince.clear();
                        listProvinceLibelle.clear();
                        listProvinceLibelle.add("Aucun choix");
                        value.forEach((element) {
                          listProvince.add(Province.fromJson(element));
                          listProvinceLibelle.add(Province.fromJson(element).province_nom);
                        });
                        setState(() {
                          selectProvince="Aucun choix";
                          idProvince="";
                          listProvinceLibelleNotDuplicate = listProvinceLibelle.toSet().toList();
                        });
                        Navigator.pop(context);
                      }else{
                        Navigator.pop(context);
                      }
                    });
                  });
                },
                isExpanded: true,
                items: listPaysLibelleNotDuplicate.map<DropdownMenuItem<String>>((String value) {
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
  }*/

 /* SelectProvince(){
    return  Container(
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
                hint: Text('Selectionnez la province'),
                value: selectProvince,
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
                  listProvince.forEach((element){
                    if(newValue.toString()== element.province_nom.toString()){
                      newValue = newValue.toString();
                      idProvince=element.province_id.toString();
                    }
                  });
                  setState(() {
                    selectProvince = newValue!;
                    if(selectProvince=="Aucun choix"){
                      idProvince="";
                      selectVille="Aucun choix";
                      listVilleLibelleNotDuplicate.clear();
                      return;
                    }
                    Constante.showAlert(context, "Veuillez patientez", "Chargement des villes...", SizedBox(), 100);
                    FindVille(idProvince).then((value){
                      if(value!=null){
                        listVille.clear();
                        listVilleLibelle.clear();
                        value.forEach((element) {
                          listVille.add(Ville.fromJson(element));
                          listVilleLibelle.add(Ville.fromJson(element).ville_nom);
                        });
                        setState(() {
                          selectVille=listVille.first.ville_nom;
                          idVille= listVille.first.ville_id.toString();
                          listVilleLibelleNotDuplicate = listVilleLibelle.toSet().toList();
                        });
                        Navigator.pop(context);
                      }else{
                        Navigator.pop(context);
                      }
                    });
                  });
                },
                isExpanded: true,
                items: listProvinceLibelleNotDuplicate.map<DropdownMenuItem<String>>((String value) {
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

  SelectVille(){
    return  Container(
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
                hint: Text('Selectionnez la ville'),
                value: selectVille,
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
                  listVille.forEach((element){
                    if(newValue.toString()== element.ville_nom.toString()){
                      newValue = newValue.toString();
                      idVille=element.ville_id.toString();
                    }
                  });
                  setState(() {
                    selectVille = newValue!;
                  });
                },
                isExpanded: true,
                items: listVilleLibelleNotDuplicate.map<DropdownMenuItem<String>>((String value) {
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
  }*/

}