
import 'dart:ui';

import 'package:background_app_bar/background_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../Constante.dart';
import '../LoginPage.dart';
import 'Etape3.dart';

class Etape2 extends StatefulWidget {

  @override
  _Etape2 createState() => _Etape2();
}

class _Etape2 extends State<Etape2>  {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late String telephone;
  bool validateNumber=false;

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'CA';
  PhoneNumber number = PhoneNumber(isoCode: 'CA');

  @override
  void initState()  {
    super.initState();
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
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
                              )
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.withOpacity(.5)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 10,),
                                Text("Etape 2/4", style: TextStyle(color: Colors.grey),),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 0),
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(height: 20,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Constante.makelabel("Vérifier votre numéro de téléphone"),
                                          SizedBox(height: 5,),
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
                                              hintText: 'Numero de telephone',
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
                                        ],
                                      ),
                                    ],
                                  ),
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

                                        }else{
                                          print("unsuccefully");
                                        }
                                      },
                                      color: Constante.primaryColor,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.0)
                                      ),
                                      child: Text("Envoyer mon sms", style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                          color: Colors.white
                                      ),),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20,),
                                InkWell(
                                  onTap: (){
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => Etape3()));
                                  },
                                  child:Text("Ignorer cette étape", style: TextStyle(color: Constante.primaryColor),),
                                ),
                                SizedBox(height: 20,),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              )

          ),
        ),
      );

  }


}