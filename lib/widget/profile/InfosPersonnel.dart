import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:niovar/Constante.dart';
import 'package:niovar/model/Utilisateur.dart';
import 'package:niovar/src/ProfilePage.dart';
import 'package:niovar/widget/profile/profile_widget.dart';
import 'package:niovar/Global.dart' as session;
import 'package:http/http.dart' as http;


class InfosPersonnel extends StatefulWidget {
  @override
  _InfosPersonnel createState() => _InfosPersonnel();
}

class _InfosPersonnel extends  State<InfosPersonnel>{
  late FToast fToast;
  String initialCountry = 'CA';
  PhoneNumber number = PhoneNumber(isoCode: 'CA');
  PhoneNumber number2 = PhoneNumber(isoCode: 'CA');
  bool validateNumber=false;
  bool validateAutreTelephone=false;
  late String name,  telephone="", autreTelephone="";
  final TextEditingController controller = TextEditingController();
  final TextEditingController controller2 = TextEditingController();
  DateTime selectedDateNaissance= DateTime.now();
  late   TextEditingController nom;
  late  TextEditingController email;
  late TextEditingController dateNaissance;
  List<String> listSexe=['Aucun choix', 'Feminin', 'Masculin'];
  String selectSexe = 'Aucun choix';
  String sexe="", departement="", poste="", typeSalaire="", prix="";
  bool _showLoading = true;
  bool _notInternet = false;


  late String _fileName="";

  int indicator = 0;

  late String _path="";
  late Map<String, String> _paths;
  late String _extension;
  late FileType _pickingType;
  late bool imageCheck = false;

  Future fetchItem() async {
    try {
      Utilisateur user;
      var url = Uri.parse(Constante.serveurAdress+"auth/register/profile?user_id="+session.id);
      print(url);
      var response = await http.post(url).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        print(jsonDecode(response.body).toString());
        final status = jsonDecode(response.body)['status'];
        final data = jsonDecode(response.body)['profile'];
        if ( status==1 && data != null) {
          user=Utilisateur.fromJson(data);
          print(user.email);
          nom = TextEditingController(text: user.nom);
          email = TextEditingController(text: user.email);
          dateNaissance = TextEditingController(text: user.date_naissance);
          departement =user.departement;
          poste =user.poste;
          prix = user.salaire;
          typeSalaire = user.type_salaire;
          setState(() {
            if(user.telephon01.toString().isNotEmpty && user.telephon01.toString()!="null"){
              getPhoneNumber("+"+user.telephon01.toString());
            }
            if(user.telephon02.toString().isNotEmpty && user.telephon02.toString()!="null"){
              getPhoneNumber2("+"+user.telephon02.toString());
            }
            if(user.sexe.toString().isNotEmpty){
              sexe = user.sexe.toString();
              if(user.sexe.toString().contains("1")){
                selectSexe="Masculin";
              }
              if(user.sexe.toString().contains("2")){
                selectSexe="Feminin";
              }
            }else{
              sexe ="";
              selectSexe="Aucun choix";
            }
            _showLoading = false;
          });
        }
      }

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

  Future SaveProfil(String nom, String email, String tel,String autreTel, String sexe, String dateNaissance,String user_id ) async{
    Dio dio = new Dio();
    final String pathUrl = Constante.serveurAdress+"auth/register?name=${nom}&email=${email}&sex_id=${sexe}&phone01=${tel}&phone02=${autreTel}&user_id=${user_id}&date_naissance=${dateNaissance}";
    print(pathUrl);
    var response = await dio.post(pathUrl);
    return response.data;
  }


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
      _path= file.path.toString();
      _fileName= file.name;

      Constante.showAlert(context, "Veuillez patientez", "Sauvegarde du profil en cour...", SizedBox(), 100);
      await uploadProfile(_path, _fileName).then((value) async {
        if(value['status'].toString()=="1"){
         String nomFileFromServer = value['message'].toString();
          await saveNameFile(session.id, nomFileFromServer).then((value){
            if(value['status'].toString()=="1"){
              Navigator.pop(context);
              setState(() {
                _path=Constante.serveurAdressImage+nomFileFromServer;
                session.profil= nomFileFromServer;
              });
              Constante.showToastSuccess("Sauvegarde effectué avec succès", fToast);
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

    } else {
      // User canceled the picker
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fToast = FToast();
    fToast.init(context);
    fetchItem();
    setState(() {
      _path=Constante.serveurAdressImage+session.profil;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      body:_notInternet ? Center(child: Constante.layoutNotInternet(context, MaterialPageRoute(builder: (context) => ProfilePage()))) :
      ListView(
        physics: BouncingScrollPhysics(),
        children: [
          if (_showLoading)
         Center(child: Constante.circularLoader()),
          if (!_showLoading) ...[
          ProfileWidget(
            imagePath:_path,
            onClicked: () async {
              _openFileExplorer();
            },
          ),
          const SizedBox(height: 15),
          buildOtherInfos(),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nom complet", style: Constante.style4,),
                SizedBox(height:5),
                TextFormField(
                  obscureText: false,
                  controller: nom,
                  decoration: InputDecoration(
                    hintText: "Saisir ici",
                    contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 15),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Constante.kBlack.withOpacity(0.2))
                    ),

                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26)
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Constante.makelabel("Courriel (*)"),
                    SizedBox(height: 5,),
                    TextFormField(
                      readOnly: true,
                      controller: email,
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
                        return null;
                      },
                    ),

                  ],
                ),
                const SizedBox(height: 20),
                Text("Sexe (*)", style: Constante.style4,),
                selectedSexe(),
                const SizedBox(height: 20),
                Text("Date de naissance (*)", style: Constante.style4,),
                SizedBox(height:5),
                TextFormField(
                  controller: dateNaissance,
                  obscureText: false,
                  readOnly: true,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: (){
                        _selectDateDebut(context);
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
                SizedBox(height: 20,),
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
                    hintText: 'Numero de telephone (*)',
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
                SizedBox(height: 20,),
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    print(number.phoneNumber);
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
                    hintText: 'Autre numéro (*)',
                  ),
                  formatInput: false,
                  keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputBorder: OutlineInputBorder(),
                  validator: (String ? value){
                    if(!validateNumber){
                      return "Numéro de telephone incorrect";
                    }
                    return null;
                  },

                ),
                SizedBox(height:10),
              ],
            ),
          ),
        ]
        ],
      ) ,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constante.primaryColor,
        onPressed: () async {
          print(nom.text);
          print(email.text);
          print(sexe);
          print(dateNaissance.text);
          print(telephone);
          print(autreTelephone);
          print(session.id);
          Constante.showAlert(context, "Veuillez patientez", "Sauvegarde en cour...", SizedBox(), 100);
          await SaveProfil(nom.text,email.text,telephone,autreTelephone,sexe,dateNaissance.text,session.id).then((value){
           print(value.toString());
            if(value['status'].toString()=="1"){
              Navigator.pop(context);
              setState(() {
                session.login=nom.text;
              });
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

  Widget buildOtherInfos() => Column(
    children: [
      Text(
        session.login,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      const SizedBox(height: 4),
      Text(
        "Département : ${departement}",
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      const SizedBox(height: 4),
      Text(
        "Poste : ${poste}",
        style: TextStyle(color: Colors.grey,fontSize: 12),
      ),
      const SizedBox(height: 4),
      Text(
        "Type salaire : ${typeSalaire} | Prix : ${prix} \$ ",
        style: TextStyle(color: Colors.grey,fontSize: 12),
      ),

    ],
  );

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

  _selectDateDebut(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDateNaissance,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (selected != null && selected != selectedDateNaissance)
      setState(() {
        selectedDateNaissance = selected;
        dateNaissance.text="${selectedDateNaissance.day<=9 ? "0"+selectedDateNaissance.day.toString(): selectedDateNaissance.day}-${selectedDateNaissance.month<=9 ? "0"+selectedDateNaissance.month.toString(): selectedDateNaissance.month}-${selectedDateNaissance.year}";
      });
  }

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number =
    await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber);
    setState(() {
      this.number = number;
    });
  }

  void getPhoneNumber2(String phoneNumber) async {
    PhoneNumber number =
    await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber);
    setState(() {
      this.number2 = number;
    });
  }

}
