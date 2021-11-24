import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:background_app_bar/background_app_bar.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:niovar/src/Create_employe/Etape4.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../Constante.dart';
import '../EditPwdForget.dart';



class CodeVerificationPage extends StatefulWidget {
  late  String codeValidation;
  late  String idUser;
  late  String email;
  bool fromPwdForget;

 // late bool ispasswordforget;
  CodeVerificationPage(this.fromPwdForget, this.codeValidation, this.idUser, this.email);
  @override
  _CodeVerificationPage createState() => _CodeVerificationPage();
}

class _CodeVerificationPage extends State<CodeVerificationPage> {
  late FToast fToast;

  TextEditingController textEditingController = TextEditingController();
  // ..text = "123456";

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  Future EnvoieNouveauCode(String idUser) async{
    Dio dio = new Dio();
    String pathUrl = Constante.serveurAdress+"auth/register/mailcode?user_id="+idUser;
    if(widget.fromPwdForget){
      pathUrl = Constante.serveurAdress+"auth/register/mailcode?user_id="+idUser+"&type_id=2";
    }
    var response = await dio.post(pathUrl);
    print(response.data.toString());
    return response.data;
  }

  Future ConfirmUser(String idUser) async{
    Dio dio = new Dio();
    final String pathUrl = Constante.serveurAdress+"auth/register/activation?user_id="+idUser;
    var response = await dio.post(pathUrl);
    print(response.data.toString());
    return response.data;
  }

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: Duration(seconds: 2),
      ),
    );
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
          body: GestureDetector(
            onTap: () {},
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: <Widget>[
                  SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Vérification de votre courriel',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                    child: RichText(
                      text: TextSpan(
                          text: "Entrer le code envoyer à cette adresse ",
                          children: [
                            TextSpan(
                                text: widget.email,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ],
                          style: TextStyle(color: Colors.black54, fontSize: 15)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: formKey,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 30),
                        child: PinCodeTextField(
                          appContext: context,
                          pastedTextStyle: TextStyle(
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                          length: 6,
                          obscureText: true,
                          obscuringCharacter: '*',
                          blinkWhenObscuring: true,
                          animationType: AnimationType.fade,
                          validator: (v) {
                            if (v!.length < 3) {
                              return "Veuillez saisir le code de confirmation";
                            } else {
                              return null;
                            }
                          },
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.underline,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 50,
                            fieldWidth: 40,
                            activeFillColor: Colors.white,
                            inactiveFillColor: Colors.white54,
                          ),
                          cursorColor: Colors.black,
                          animationDuration: Duration(milliseconds: 300),
                          enableActiveFill: true,
                          errorAnimationController: errorController,
                          controller: textEditingController,
                          keyboardType: TextInputType.number,
                          boxShadows: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              color: Colors.black12,
                              blurRadius: 10,
                            )
                          ],
                          onCompleted: (v) {

                          },
                          // onTap: () {
                          //   print("Pressed");
                          // },
                          onChanged: (value) {
                            print(value);
                            setState(() {
                              currentText = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            print("Allowing to paste $text");
                            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                            //but you can show anything you want here, like your pop up saying wrong paste format or etc
                            return true;
                          },
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Text(
                      hasError ? "* Code de confirmation invalide " : "",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Je n'ai pas reçus de mail ? ",
                        style: TextStyle(color: Colors.black54, fontSize: 15),
                      ),
                      TextButton(
                          onPressed: () async {
                            Constante.showAlert(context, "Veuillez patientez", "Envoie du courriel en cour..", SizedBox(), 100);
                            print(widget.idUser.toString());
                            await EnvoieNouveauCode(widget.idUser.toString()).then((value){
                              if(value['status'].toString().contains("1")){
                                Navigator.pop(context);
                                setState(() {
                                  this.widget.codeValidation=value['code_validation'].toString() ;
                                });
                                Constante.showToastSuccess("Un nouveau courriel de vérification vous à été envoyer ",fToast);
                              }else{
                                Navigator.pop(context);
                                Constante.showSnackBarMessage(context, "Erreur durant l'opération. Veuillez réessayer !");
                              }
                            }
                            );
                          },
                          child: Text(
                            "Envoyer de nouveau",
                            style: TextStyle(
                                color: Color(0xFF91D3B3),
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Container(
                    margin:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
                    child: ButtonTheme(
                      height: 50,
                      child: TextButton(
                        onPressed: () async {
                          formKey.currentState!.validate();
                          // conditions for validating
                          if (currentText.length != 6 || currentText != widget.codeValidation.toString()) {
                            errorController!.add(ErrorAnimationType
                                .shake); // Triggering error shake animation
                            setState(() => hasError = true);
                          } else {
                            if(widget.fromPwdForget){
                              Navigator.pop(context);
                              Navigator.push(
                                  context, MaterialPageRoute(builder: (context) => EditPwdForget(widget.idUser)));
                            }else{
                              Constante.showAlert(context, "Veuillez patientez", "Confirmation en cour...", SizedBox(), 100);
                              print(widget.idUser.toString());
                              print(widget.codeValidation.toString());
                              await ConfirmUser(widget.idUser.toString()).then((value){
                                if(value['status'].toString().contains("1")){
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context, MaterialPageRoute(builder: (context) => Etape4(widget.idUser)));
                                }else{
                                  Navigator.pop(context);
                                  Constante.showSnackBarMessage(context, "Erreur durant l'opération. Veuillez réessayer !");
                                }
                              });
                            }
                          }
                        },
                        child: Center(
                            child: Text(
                              "VERIFIER".toUpperCase(),
                              style: Constante.kTitleStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400
                              ),
                            )),
                      ),
                    ),
                    decoration: BoxDecoration(
                        color: Constante.primaryColor,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.white,
                              offset: Offset(1, -2),
                              blurRadius: 5),
                          BoxShadow(
                              color: Colors.white,
                              offset: Offset(-1, 2),
                              blurRadius: 5)
                        ]),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                          child: TextButton(
                            child: Text("Vider"),
                            onPressed: () {
                              textEditingController.clear();
                            },
                          )),

                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );


  }

}