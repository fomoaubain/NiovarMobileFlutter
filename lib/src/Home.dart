import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:background_app_bar/background_app_bar.dart';
import 'package:badges/badges.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:niovar/Constante.dart';
import 'package:niovar/model/QuarTravail.dart';
import 'package:niovar/model/Taches.dart';
import 'package:niovar/services/LocalNotificationService.dart';
import 'package:niovar/src/LoginPage.dart';
import 'package:niovar/src/ProfilePage.dart';
import 'package:niovar/widget/navigation_drawer_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:niovar/Global.dart' as session;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:expandable_group/expandable_group.dart';
import 'package:http/http.dart' as http;

import 'VerifyEmailPage.dart';


class Home extends StatefulWidget {

  @override
  _Home createState() => _Home();
  late List<List<String>> data;
}

class _Home extends  State<Home> with SingleTickerProviderStateMixin{
  late FToast fToast;
  late TabController _controller;
  Future<void>? _launched;
  int _selectedIndex = 0;
  late final FirebaseMessaging _messaging;

  bool showSectionCompagnie= true;
  String linkloadcalender= "", selectWeek="";

  var currentPage = DrawerSections.home;
  int _currentMax=4;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ScrollController _scrollController = new ScrollController();
  ScrollController _scrollController2 = new ScrollController();
  ScrollController _scrollController3 = new ScrollController();
  late TextEditingController description = new TextEditingController();

  late List<String> listWeek= [];
  late List<Jour>  listJour=[];
  late List<Taches>  listTaches=[];
  bool _showLoading = true;
  bool _notInternet = false;
  String begin_week ="", end_week="", heures_proposees="", heures_validees="", total_salaire_brut="",total_salaire_net="";
//  late List<QuarTravail>  listDimanche=[], listLundi=[],listMardi=[], listMercredi=[], listJeudi=[], listVendredi=[], listSamedi=[];
  late WeekCalendar weekCalendar;

  Future fetchItem( String link ) async {
    try {

      var url = Uri.parse(Constante.serveurAdress+"calendar/user/current/week/shifts"+link);
      print(url);
      int timeout = 15;
      final results = await Future.wait([
        http.post(url).timeout(Duration(seconds: timeout)),
        http.post(Uri.parse(Constante.serveurAdress+"calendar/year/weeks")).timeout(Duration(seconds: timeout)),
      ]);
      var response =  results[0];
      if (response.statusCode == 200) {
        linkloadcalender="?user_id="+session.id;
        session.date_debut="";
        final status = jsonDecode(Utf8Decoder().convert(response.bodyBytes))['status'];
        final data = jsonDecode(Utf8Decoder().convert(response.bodyBytes))['message'];
        if ( status==1 && data.toString().isNotEmpty) {
          weekCalendar=WeekCalendar.fromJson(data);
          if(weekCalendar!=null){
            listJour.add(weekCalendar.Dimanche);
            listJour.add(weekCalendar.Lundi);
            listJour.add(weekCalendar.Mardi);
            listJour.add(weekCalendar.Mercredi);
            listJour.add(weekCalendar.Jeudi);
            listJour.add(weekCalendar.Vendredi);
            listJour.add(weekCalendar.Samedi);
          }
          begin_week = weekCalendar.debut_semaine.toString();
          end_week=weekCalendar.fin_semaine.toString();
          heures_proposees=weekCalendar.heures_proposees.toString();
          heures_validees=weekCalendar.heures_validees.toString();
          total_salaire_brut=weekCalendar.total_salaire_brut.toString();
          total_salaire_net=weekCalendar.total_salaire_net.toString();

          selectWeek=begin_week+" / "+end_week;

          setState(() {
            _showLoading =false;
            _notInternet=false;
          });
        }
      }

      var responseListweek =  results[1];
      if (responseListweek.statusCode == 200) {
        final status = jsonDecode(responseListweek.body)['status'];
        final data =jsonDecode(responseListweek.body)['message'];
       if(status.toString()=="1"){
         listWeek.clear();
         data.forEach((element) {
           listWeek.add(element['dimanche']+" / "+element['samedi']);
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


  Future PointerHoraire(String userId, String horaireId, String rapport) async{
    Dio dio = new Dio();
    final String pathUrl = Constante.serveurAdress+"calendar/pointage?user_id=${userId}&horaire_id=${horaireId}&rapport=${rapport}";
    var response = await dio.post(pathUrl );
    print(response.data.toString());
    return response.data;

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      drawer:NavigationDrawerWidget(),
      body: new NestedScrollView(
          headerSliverBuilder:  (_, __) => <Widget>[
            new SliverAppBar(
              actions: [
                ShowBadge(),
                SizedBox(width: 10.0),
                ShowPupopMenu(),
                SizedBox(width: 5.0),
              ],
              floating: false,
              pinned: true,
              snap: false,
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              flexibleSpace: new BackgroundFlexibleSpaceBar(
                title: Center(child: Image.asset('assets/icon_og.png', fit: BoxFit.cover, height: 40, width: 100,),),
                titlePadding: const EdgeInsets.only(top: 30),
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
            decoration: BoxDecoration(
              color: Constante.kSilver
            ),
            child:SingleChildScrollView(
              child:_notInternet ? Center(child: Constante.layoutNotInternet(context, MaterialPageRoute(builder: (context) => Home()))):
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  Text("Calendrier de travail", style: GoogleFonts.questrial(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                    color: Constante.secondaryColor,
                    wordSpacing: 1.5,
                  ),),
                  const Divider(
                    color: Colors.grey,
                    height: 25,
                    thickness: 2,
                    indent: 5,
                    endIndent: 5,
                  ),
                   if (_showLoading) Center(child: Constante.circularLoader()),

                  if (!_showLoading) ...[
                  SizedBox(height: 10,),
                  InkWell(
                    onTap: (){
                      setState(() {
                        listJour.clear();
                        _showLoading=true;
                        _notInternet=false;
                      });
                      fetchItem(linkloadcalender);
                    },
                    child:  Text.rich(
                      TextSpan(
                        style:GoogleFonts.questrial(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                        children: [
                          TextSpan(
                            text:" Semaine en cours ",
                          ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Text.rich(
                    TextSpan(
                      style:GoogleFonts.questrial(
                        fontSize: 10.0,
                      ),
                      children: [
                        WidgetSpan(
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                  _showLoading=true;
                                  _notInternet=false;
                                  listJour.clear();
                                });
                                fetchItem("?user_id=${session.id}&date=${begin_week}&action=2");
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 5, bottom: 8),
                                child:Icon(Icons.chevron_left,color:Constante.secondaryColor, size: 35.0,)
                              ),
                            )
                        ),
                        WidgetSpan( child: Container(
                          width: 233,
                          child: SelectWeekWidget()
                        )
                        ),
                        WidgetSpan(
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                _showLoading=true;
                                _notInternet=false;
                                listJour.clear();
                              });
                              fetchItem("?user_id=${session.id}&date=${end_week}&action=1");
                            },
                            child: Padding(
                              padding: EdgeInsets.only( left: 5, bottom: 8),
                              child: Icon(Icons.chevron_right,color:Constante.secondaryColor, size: 35.0,),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 5,),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 0),
                      child:   Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Divider(),
                          Container(
                            child: Column(
                              children: listJour.map((e) {
                                int index = listJour.indexOf(e);
                                return ExpandableGroup(
                                  isExpanded: index == 0,
                                  header: _header(e,e.horaires.length.toString()),
                                  items: e.horaires.length>0 ? _buildItems(context, e.horaires) : _buildEmptyItem(context),
                                );
                              }).toList(),
                            ),
                          ),
                          Divider(),
                          SizedBox(height: 10,),
                          Container(
                            alignment: Alignment.topCenter,
                            child: Row(
                              children: [
                                Expanded(
                                    child:Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(child:
                                            chartTotal(heures_proposees, "Total heures proposées","Total de vos heures proposées de la semaine", Colors.blue.shade300, Icons.timelapse),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(child: chartTotal(total_salaire_brut, "Estimation total salaire brut à percevoir","Estimation basée sur le total de vos heures proposées de la semaine",Colors.orange.shade300, Icons.monetization_on_outlined),),
                                          ],
                                        ),
                                      ],
                                    )
                                ),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child:
                                              chartTotal(heures_validees, "Total heures validées","Total de vos heures validées de la semaine", Colors.red.shade300, Icons.access_time),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(child:
                                              chartTotal(total_salaire_net, "Estimation total salaire net à percevoir","Estimation basée sur le total de vos heures validées de la semaine", Colors.green.shade300, Icons.monetization_on_sharp),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),)

                              ],

                            ),
                          ),
                          SizedBox(height: 20,)
                        ],
                      ),
                  ),

                  ]
                ],
              ),
            ),
          ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constante.secondaryColor,
        onPressed: () async {
          setState(() {
            listJour.clear();
            _showLoading=true;
            _notInternet=false;
          });
          fetchItem(linkloadcalender);
        },
        child:  Icon(Icons.refresh),
      ),
    );
  }


  Widget _header(Jour item, String nbre) {
    bool ferier=false;
    if(item.ferier.toString()!="0"){
      ferier =true;
    }
    return Text.rich(
      TextSpan(
        style:GoogleFonts.questrial(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: Colors.black45,
        ),
        children: [
          WidgetSpan(child: Icon(FontAwesome.calendar,color:Constante.secondaryColor, size: 15.0,),),
          TextSpan(text:"  "+item.jour),
          nbre.toString()!="0" ?
          WidgetSpan(child: Padding( padding: EdgeInsets.symmetric(horizontal: 5), child: Badge(
            badgeContent: Text(nbre, style: TextStyle(color: Colors.black, fontSize: 5),),
            badgeColor: Colors.orange.shade200,
            child: null,
            showBadge: true,
            animationDuration: Duration(seconds: 0),
          ),)
         ) : WidgetSpan(child:SizedBox()),
          ferier ? WidgetSpan(
            child: InkWell(
              onTap: (){
               showAlertJourFerier(context,item);
               },
              child: Container(
                height: 16,
                margin: EdgeInsets.symmetric(horizontal: 2),
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.green.shade400
                ),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 8),
                    children: [
                      TextSpan(
                        text: "Journée fériée",
                      ),
                    ],
                  ),
                )

              ),
              ),
          ): WidgetSpan(child: SizedBox(height: 0,),),
          ferier ?  WidgetSpan(
              child: InkWell(
                onTap: (){
                  showAlertConger(context);
                },
                child: Container( margin: EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.announcement_outlined,color:Colors.orange, size: 15.0,),)

              )
          ) : WidgetSpan(child: SizedBox(height: 0,),),
        ],
      ),
    );
  }

  List<ListTile> _buildItems(BuildContext context, List<QuarTravail> items){
    return items.map((e){
      IconData iconData=Icons.circle;  Color color=Colors.blueGrey.shade300;
      IconData iconTypeQuarTravail=Icons.work_outline;
      if(e.poincon.toString()=="1"){
        iconData =Icons.circle;
        color = Colors.blueGrey.shade300;
      }else if(e.poincon.toString()=="2"){
        iconData =Icons.circle;
        color = Colors.orange;
      }else if(e.poincon.toString()=="3"){
        iconData =Icons.check_circle;
        color = Colors.green;
      }
      if(e.shift_type.toString().isNotEmpty){
        if(e.shift_type.toString()=="4") {
          iconTypeQuarTravail=Icons.call;
        }
      }
      int index = items.indexOf(e);

      return  ListTile(
        subtitle: Container(
          decoration: BoxDecoration(
            color: index % 2 == 0 ?  Colors.grey.shade300 : Colors.blueGrey.shade100,
            borderRadius: BorderRadius.circular(8)
          ),
          child: ListTile(
            subtitle: Row(
              children: <Widget>[
                Expanded(
                    flex: 12,
                    child: Container(
                      child : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2,),
                          Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black45,
                              ),
                              children: [
                                WidgetSpan(child: Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Icon(iconTypeQuarTravail,color:Colors.black54, size: 13.0,),
                                )
                                ),
                                TextSpan(
                                  text: e.titre.toString(),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 2,),
                        ],
                      ),
                    )),
              ],
            ),
            title: Row(
              children: [
                Text(
                  e.start_time.toString()+" - "+e.end_time.toString(),
                  style: TextStyle(color: Constante.secondaryColor, fontWeight: FontWeight.bold, fontSize: 13.0),
                ),
              ],
            ),

            trailing:InkWell(
                onTap: (){
                  if(e.is_pointable.toString().isNotEmpty && e.is_pointable.toString()!="1"){
                    showAlertDetailsChart(context, "Impossible de pointer cet horaire car la date et l’heure de pointage ne sont pas encore arrivées.");
                    return;
                  }
                  showAlert(context, e);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  color: Colors.transparent,
                  child:Icon(iconData, color: color, size: 15,)

                )
            ),
            onTap: () {
              showAlertDetails(context, e);
            },
          ),
        )
      );



    }).toList();
  }

  List<ListTile> _buildEmptyItem(BuildContext context){

    return ["Aucun horaire n’est disponible pour le moment !"].map((e){
      return  ListTile(
        subtitle: Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
            children: [
              TextSpan(
                text: e.toString(),
              )
            ],
          ),
        ),
      );



    }).toList();
  }


  Widget ShowPupopMenu(){
    return  PopupMenuButton(
      itemBuilder: (BuildContext bc) => [
        PopupMenuItem(child: Constante.TextwithIcon(Icons.dashboard_outlined, " Autres", Colors.black87, 15), value: 1),
        PopupMenuItem(
            child: Constante.TextwithIcon(Icons.lock_open_rounded, "Se deconnecter", Colors.black87, 15), value: 2),
      ],
      onSelected: (value) async {
        if(value==1){

        } else if(value==2){
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
        }
      },
    );
  }

  Widget ShowBadge(){
    return   Container(
        margin: EdgeInsets.only(top: 5),
        child: InkWell(
          onTap:  () {

          },
          child: Badge(
            badgeContent: Text("0", style: TextStyle(color: Colors.white),),
            badgeColor: Constante.secondaryColor,
            child: Icon(Icons.notifications, size: 20,),
          ),
        )
    );
  }

  Widget layoutPause(String pauseInfos){
    String duree_pause="", remunerer="", debut_pause="";
    IconData? iconPause= null, iconPauseRemunerer=null;
    if(pauseInfos.toString().isNotEmpty){
      iconPause = Icons.free_breakfast_outlined;
      List<String> val = pauseInfos.toString().split("*");
      duree_pause= val.elementAt(0);
      remunerer= val.elementAt(2);
      debut_pause=val.elementAt(1);
      if(remunerer=="1"){
        iconPauseRemunerer = Icons.attach_money_sharp;
      }else if(remunerer=="2"){
        iconPauseRemunerer = Icons.money_off;
      }
    }
    return Text.rich(
      TextSpan(
        style: TextStyle(
            fontSize: 13,
            color: Colors.black38,
            fontWeight: FontWeight.bold,
        ),
        children: [
          WidgetSpan(
            child: Icon(iconPause,color:Colors.grey, size: 16.0,),
          ),
          WidgetSpan(
            child: Icon(iconPauseRemunerer,color:Colors.grey, size: 16.0,),
          ),
          WidgetSpan(
            child: Icon(Icons.access_time,color:Colors.grey, size: 16.0,),
          ),
          TextSpan(
            text: "Durée : "+duree_pause+", ",
          ),
          WidgetSpan(
            child: Icon(Icons.timelapse,color:Colors.grey, size: 16.0,),
          ),
          TextSpan(
            text:"Début : "+debut_pause,
          )
        ],
      ),
    );

  }


  Widget ShowMessageBadge(){
    return   Container(
        margin: EdgeInsets.only(top: 5),
        child: InkWell(
          onTap:  () {
          },
          child: Badge(
            badgeContent: Text("0", style: TextStyle(color: Colors.white),),
            badgeColor: Constante.primaryColor,
            child: Icon(Icons.mail_outline, size: 20,),
          ),
        )


    );

  }

  Widget chartTotal(String qte, String titre,String description, Color color, IconData icon, ){
    return  Container(
      height: 95,
      margin: EdgeInsets.symmetric(horizontal: 2, vertical:5 ),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.0)),
      child: ListTile(
        leading: Container(
            decoration: new BoxDecoration(
                border: new Border(
                    right: new BorderSide(width: 1.0, color: Colors.white24))),
            child: Icon(icon, size: 30, color: Colors.white,)
        ),
        title:  Text(qte, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),textAlign: TextAlign.center,),
        subtitle: Column(
          children: [
            Text(titre, style: TextStyle(fontSize: 10, color: Colors.white),),
            SizedBox(height: 2,),
            Align(
              alignment: Alignment.topRight,
              child: Icon(Icons.add_circle_outline_outlined, color: Colors.white,size: 14,),
            )
          ],
        ),
        onTap: () {
          showAlertDetailsChart(context,description);
        },

      ),
    );

  }




  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    loadFirebaseNotification();
    checkUserConnect();

  }


  Widget profilLogin(){
    return  InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProfilePage()));
      },
      child:Container(
        height: 25,
        width: 35,
        child: CircleAvatar(
          radius: 30.0,
          backgroundImage:
          NetworkImage(Constante.serveurAdressImage+session.profil),
          backgroundColor: Colors.transparent,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Constante.kBlack.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
      ),
    );


  }

  void showAlert(BuildContext context, QuarTravail item) {
    description.text=item.rapport.toString();
    showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(builder: (context, setState){
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(10.0)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container (
                  height: 400,
                  child: SingleChildScrollView(
                    child:Form(
                      key: formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text("Pointer ce quart travail", style: TextStyle( fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          Divider(),
                          SizedBox(height: 20,),
                          Text("Laisser un rapport", style: Constante.style4,),
                          SizedBox(height: 5,),
                          TextFormField(
                            controller: description,
                            cursorColor: Colors.black,
                            maxLines: 10,
                            readOnly: false,
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
                            validator: (String ? value){
                              if(value!.isEmpty){
                                return "Ce champ est obligatoire";
                              }
                              if(value.length>200){
                                return "Le texte est trop long";
                              }
                              return null;
                            },
                            style: Constante.style4,
                          ),
                          item.poincon.toString()=="1" || item.poincon.toString()=="0" ?
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
                                  height: 45,
                                  onPressed: () async{

                                    if(formKey.currentState!.validate()){
                                      Constante.showAlert(context, "Veuillez patientez", "Pointage horaire en cour...", SizedBox(), 100);
                                      await PointerHoraire(session.id, item.horaireId.toString(), description.text ).then((value) async {
                                        print(value.toString());
                                        if(value['status'].toString()=="1"){
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext context) => super.widget));
                                        }else{
                                          Navigator.pop(context);
                                          Constante.showSnackBarMessage(context, "Une erreur est survenu. Veuillez réessayer");
                                        }

                                      }
                                      );
                                    }
                                  },
                                  color: Constante.secondaryColor,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0)
                                  ),
                                  child:Text("Enregistrer", style: TextStyle(color: Colors.white, fontSize: 16),)

                              ),
                            ),
                          )
                          : SizedBox(),
                        ],
                      ),
                    ),

                  ),
                ),
              ),
            );
          });
        }
    );
  }

  void showAlertDetails(BuildContext context,  QuarTravail item) {
    showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(builder: (context, setState){
            List<String> val = [];
            if(item.pause_str.toString().isNotEmpty){
              val = item.pause_str.toString().split("|");
            }
            IconData iconTypeQuarTravail = Icons.work_outline;
            if(item.shift_type.toString().isNotEmpty){
              if(item.shift_type.toString()=="4") {
                iconTypeQuarTravail=Icons.call;
              }

            }

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container (
                  height: 450,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Détails sur le quart de travail", style: TextStyle( fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                        ),
                        SizedBox(height: 20,),
                        _buildButtonColumn2( Icons.timelapse,item.start_time.toString()+" - "+item.end_time.toString(), "",  Colors.black45, 13 ),
                        Divider(),
                        SizedBox(height: 15,),
                        _buildButtonColumn2( iconTypeQuarTravail, item.titre.toString(), "Tâches", Colors.black45, 13 ),
                        Divider(),
                        SizedBox(height: 15,),
                        _buildButtonColumn2( iconTypeQuarTravail, item.description.toString(), "Description", Colors.black45, 13 ),
                        Divider(),
                        SizedBox(height: 15,),
                        for ( var i in val ) layoutPause(i.toString()),

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

  void showAlertJourFerier(BuildContext context,  Jour item) {
    showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(builder: (context, setState){
            List<String> val = [];
            if(item.ferier.toString().isNotEmpty){
              val = item.ferier.toString().split("*");
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(20.0)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container (
                  height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Jounée fériée", style: TextStyle( fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                        ),
                        SizedBox(height: 15,),
                        _buildButtonColumn2( Icons.help, val.elementAt(0).toString(), "Motif", Colors.black45, 13 ),
                        Divider(),
                        SizedBox(height: 15,),
                        _buildButtonColumn2( Icons.info_outline, val.elementAt(1).toString(), "Description", Colors.black45, 13 ),

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

  void showAlertConger(BuildContext context) {
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
                  height: 150,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Note légale ", style: TextStyle( fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16),
                        ),
                        Divider(),
                        Text("En travaillant une journée fériée obligatoire, renseignez-vous auprès de votre employeur si des avantages supplémentaires s’appliquent", style: TextStyle( color: Colors.grey, fontSize: 14),
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

  void showAlertDetailsChart(BuildContext context, String message) {
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
                  height: 50,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message, style: TextStyle( color: Colors.grey, fontSize: 14),
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

  Column _buildButtonColumn2(IconData icon, String label, String text, Color color, double size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Constante.TextwithIcon(icon, text, color, size),
        Container(
          margin: const EdgeInsets.only(top:0, left: 10, right: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black45,
            ),
          ),
        ),
      ],
    );
  }

  void checkUserConnect() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('id')){
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage()
          ),
          ModalRoute.withName("/Home")
      );
    return;
    }
    session.login = prefs.getString('nom')!;
    session.id  = prefs.getString('id')!;
    session.email  = prefs.getString('email')!;
    session.typeAccount  = prefs.getString('typeAccount')!;
    session.profil  = prefs.getString('profil')!;
    setState(() {
      if(!session.id.isEmpty){
        session.IsConnected=true;
      }
    });
    linkloadcalender="?user_id="+session.id;
    if(session.date_debut.isNotEmpty) linkloadcalender=linkloadcalender="?user_id="+session.id+"&date="+session.date_debut+"&action=0";
    fetchItem(linkloadcalender);

  }

  void loadFirebaseNotification() async {
    LocalNotificationService.initialize(context);
    FirebaseMessaging.instance.getInitialMessage().then((message){
      if(message!=null){
        session.date_debut=message.data['date_debut'].toString();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => Home()
            ),
            ModalRoute.withName("/Home")
        );
      }
    });
    _messaging = FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        if(message.notification!=null){
          print(message.notification!.body);
          print(message.notification!.title);
          print("background "+message.data['date_debut'].toString());
        }

        LocalNotificationService.display(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("onMessageOpenedApp 2");
        print("background "+message.data['date_debut'].toString());
        print("background "+message.data['date_fin'].toString());
        setState(() {
          listJour.clear();
          _showLoading=true;
          _notInternet=false;
        });
        linkloadcalender=linkloadcalender="?user_id="+session.id+"&date="+message.data['date_debut'].toString()+"&action=0";
        fetchItem(linkloadcalender);

      });

    } else {
      print('User declined or has not accepted permission');
    }
  }

  SelectWeekWidget(){
    return DropdownSearch<String>(
        dropdownSearchDecoration: InputDecoration(
          helperStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.fromLTRB(2, 0, 0, 0),
          border: OutlineInputBorder(),
          isCollapsed: true,
        ),
        mode: Mode.MENU,
        items: listWeek,
        validator: (v) => v == null ? "required field" : null,
        onChanged: (newValue){
          var val = newValue.toString().split("/");
          setState(() {
            selectWeek = newValue!;
            listJour.clear();
            _showLoading=true;
            _notInternet=false;
          });
          linkloadcalender=linkloadcalender="?user_id="+session.id+"&date="+val[0].toString()+"&action=0";
          fetchItem(linkloadcalender);
        },
        selectedItem: selectWeek);
  }





  @override
  void dispose() {
    super.dispose();
  }
}


enum DrawerSections{
  home,
  faqPage,
  contact,
  logIn,
  logOut,
  abonnements
}





