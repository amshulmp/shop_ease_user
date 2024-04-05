
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_ease_user/config/configuration.dart';
import 'package:shop_ease_user/config/routes.dart';
import 'package:shop_ease_user/widgets/reuabletextfield.dart';



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  Future <void> addUser( )async {
    Map<String,dynamic> usermap={
      "email":emailcontroller.text.trim(),
       "username":companynamecontroller.text.trim(),
       "phone":phonecontroller.text.trim(),
       "housename":housenamecontroller.text.trim(),
       "state":statecontroller.text.trim(),
       "district":districtcontoller.text.trim(),
       "pincode":pincodecontroller.text.trim(),
       "Steetadress":adresscontroller.text.trim(),
       "wishlist":[],
       "cart":[],
    };
  if(
    usermap["email"]==""||
      usermap["companyname"]==""||
       usermap["phone"]==""||
        usermap["adress"]==""||
         usermap["description"]==""||
          usermap["url"]==""||
          cpasswordcontroller.text.trim() ==""||
           passwordcontroller.text.trim() ==""
  ){
     showDialog(context: context, builder: (BuildContext context) { 
        return AlertDialog(
          content: Container(
            color: Theme.of(context).colorScheme.secondary,
           child: const Column(
            mainAxisSize:MainAxisSize.min,
            children: [
              Text("fill all fields")
            ],
           ),
          ),
        );
       }, );
  }
  else
    {
    try{
        UserCredential userCredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailcontroller.text.trim(), password: passwordcontroller.text.trim());
        if (userCredential.user != null){
           Navigator.pushNamed(context, Routes.login);
        }     
      }
      on FirebaseAuthException catch (exception){
      showDialog(context: context, builder: (BuildContext context) { 
        return AlertDialog(
          content: Container(
            color: Theme.of(context).colorScheme.secondary,
           child:  Column(
            mainAxisSize:MainAxisSize.min,
            children: [
              Text(exception.code.toString())
            ],
           ),
          ),
        );
       }, );
      }
       await FirebaseFirestore.instance.collection("users").add(usermap);
  emailcontroller.clear();
  passwordcontroller.clear();
  cpasswordcontroller.clear();
  companynamecontroller.clear();
  phonecontroller.clear();
  housenamecontroller.clear();
  statecontroller.clear();
  districtcontoller.clear();
  adresscontroller.clear();
  passwordcontroller.clear();
  Navigator.pushNamed(context, Routes.login);
      
      }
  }
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController cpasswordcontroller = TextEditingController();
  TextEditingController companynamecontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController housenamecontroller = TextEditingController();
  TextEditingController statecontroller = TextEditingController();
  TextEditingController districtcontoller = TextEditingController();
   TextEditingController adresscontroller = TextEditingController();
    TextEditingController pincodecontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
    appBar: AppBar(
      title: const Text("R E G I S T E R",
      style: TextStyle(fontWeight: FontWeight.bold),),
      backgroundColor: Theme.of(context).colorScheme.primary,
    ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(MyConstants.screenHeight(context)*0.01),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Reusabletextfield(
                      controller: emailcontroller,
                      isobscure: false,
                      inputtype: TextInputType.emailAddress,
                      hint: "email"),
                  Reusabletextfield(
                      controller: companynamecontroller,
                      isobscure: false,
                      inputtype: TextInputType.text,
                      hint: "user name"),
                  Reusabletextfield(
                      controller: phonecontroller,
                      isobscure: false,
                      inputtype: TextInputType.number,
                      hint: "phone number"),
                  Reusabletextfield(
                      controller: housenamecontroller,
                      isobscure: false,
                      inputtype: TextInputType.visiblePassword,
                      hint: "housename"),
                   Reusabletextfield(
                      controller: statecontroller,
                      isobscure: false,
                      inputtype: TextInputType.text,
                      hint: "state"),
                  Reusabletextfield(
                      controller: districtcontoller,
                      isobscure: false,
                      inputtype: TextInputType.text,
                      hint: "district"),  
                       Reusabletextfield(
                      controller: pincodecontroller,
                      isobscure: false,
                      inputtype: TextInputType.number,
                      hint: "pincode"),  
                       Reusabletextfield(
                      controller: adresscontroller,
                      isobscure: false,
                      inputtype: TextInputType.text,
                      hint: "street adress"),  
                         
                  Reusabletextfield(
                      controller: passwordcontroller,
                      isobscure: true,
                      inputtype: TextInputType.visiblePassword,
                      hint: "password"),
                  Reusabletextfield(
                      controller: cpasswordcontroller,
                      isobscure: true,
                      inputtype: TextInputType.visiblePassword,
                      hint: "conform password"),
                  Padding(
                padding:
                    EdgeInsets.all(MyConstants.screenHeight(context) * 0.01),
                child: MaterialButton(
                    onPressed: addUser,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            MyConstants.screenHeight(context) * 0.01)),
                    color: Theme.of(context).colorScheme.primary,
                    elevation: 10,
                    child: Text(
                      "register",
                      style: TextStyle(
                          fontSize: MyConstants.screenHeight(context) * 0.025),
                    )),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}