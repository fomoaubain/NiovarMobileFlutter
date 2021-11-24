
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:niovar/services/LocalNotificationService.dart';
import 'package:niovar/src/Create_employe/Etape1.dart';
import 'package:niovar/src/VerifyEmailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constante.dart';
import '../Global.dart' as  session;
import 'Home.dart';



class LoginPage extends StatefulWidget {

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage>  {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController pwd = TextEditingController();
  final TextEditingController email = TextEditingController();
  late final FirebaseMessaging _messaging;
  late String tokenDevice="";

  @override
 void initState()  {
    super.initState();
    loadFirebaseNotification();
  }

  Future login(String email, String pwd, String deviceToken) async{
    Dio dio = new Dio();
    final String pathUrl = Constante.serveurAdress+"auth/register/login?username=${email}&password=${pwd}&device_token=${deviceToken}";
    print("Token : "+ pathUrl);
    var response = await dio.post(pathUrl);
    print(response.data.toString());
    return response.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Constante.kSilver,
      body:Container(
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
              repeat: ImageRepeat.repeat,
              image: AssetImage("assets/background.png"),
            ),
           ),
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 100),
                child:  Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    "assets/icon_og.png",
                    height: 50,
                  ),
                ),
            ),
            Expanded(
              child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50))),
                  margin: const EdgeInsets.only(top: 60),
                  child: SingleChildScrollView(
                    child: Column(
                  children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(height: 20,),
                      Text("Se connecter", style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold, color: Constante.primaryColor
                      ),),
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Vous n'avez pas de compte ?"),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => Etape1()));
                            },
                            child:    Text(" Creer un compte", style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15, color: Constante.primaryColor
                            ),),
                          ),

                        ],
                      ),
                    ],
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Constante.makelabel("Courriel"),
                            SizedBox(height: 5,),
                            TextFormField(
                              enableInteractiveSelection: true,
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
                                return null;
                              },
                            ),

                          ],
                        ),
                        SizedBox(height: 20,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Constante.makelabel("Mot de passe"),
                            SizedBox(height: 5,),
                            TextFormField(
                              enableInteractiveSelection: true,
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
                                return null;
                              },

                            ),

                          ],
                        ),
                      ],
                    ),
                  ),

                ),
                InkWell(
                  onTap: (){
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => VerifyEmailPage()));
                  },
                  child:Text("Mot de passe oublié ?", style: TextStyle(color: Colors.grey),),

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
                          Constante.showAlert(context, "Veuillez patientez", "Connexion en cour...", SizedBox(), 100);
                          await login(email.text, pwd.text, tokenDevice).then((value) async {
                            print(value.toString());
                            if(value['status'].toString()=="1"){
                              Navigator.pop(context);
                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                                prefs.setString('nom', value['nom'].toString());
                                prefs.setString('id', value['id'].toString());
                                prefs.setString('email', value['email'].toString());
                                prefs.setString('typeAccount', value['admin'].toString());
                                prefs.setString('profil', value['photo'].toString());
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Home()
                                  ),
                                  ModalRoute.withName("/Home")
                              );
                            }else{
                              Navigator.pop(context);
                              Constante.showSnackBarMessage(context, "Login ou mot de passe incorrect.");
                            }

                          }
                          );
                        }
                      },
                      color: Constante.primaryColor,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)
                      ),
                      child: Text("Se connecter", style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white
                      ),),
                    ),
                  ),
                ),

                ],
              ),
                  )),
            )
          ],
        ),
      ),



    );
  }

  void loadFirebaseNotification() async {
    LocalNotificationService.initialize(context);
    FirebaseMessaging.instance.getInitialMessage();
    _messaging = FirebaseMessaging.instance;
    final String? token = await _messaging.getToken();
    if(token!.isNotEmpty){
      print("Token : "+ token.toString());
    tokenDevice=token;
    }
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
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      });

    } else {
      print('User declined or has not accepted permission');
    }
  }




}