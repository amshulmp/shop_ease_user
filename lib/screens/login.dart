// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shop_ease_user/config/configuration.dart';
import 'package:shop_ease_user/config/routes.dart';
import 'package:shop_ease_user/widgets/reuabletextfield.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  void login() async {
    String email = emailcontroller.text.trim();
    String password = passwordcontroller.text.trim();
    if (email == "" || password == "") {
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
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        if (userCredential.user != null) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacementNamed(context, Routes.roothome);
        }
      } on FirebaseAuthException catch (exception) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(MyConstants.screenHeight(context) * 0.01),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MyConstants.screenHeight(context) * 0.16,
              ),
              LottieBuilder.asset("assets/Animation - 1708494702546.json"),
              Reusabletextfield(
                  controller: emailcontroller,
                  isobscure: false,
                  inputtype: TextInputType.emailAddress,
                  hint: "email"),
              Reusabletextfield(
                  controller: passwordcontroller,
                  isobscure: true,
                  inputtype: TextInputType.visiblePassword,
                  hint: "password"),
              Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.forgot);
                      },
                      child: Text(
                        "forgot password",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ))),
              Padding(
                padding:
                    EdgeInsets.all(MyConstants.screenHeight(context) * 0.01),
                child: MaterialButton(
                    onPressed: login,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            MyConstants.screenHeight(context) * 0.01)),
                    color: Theme.of(context).colorScheme.primary,
                    elevation: 10,
                    child: Text(
                      "Login",
                      style: TextStyle(
                          fontSize: MyConstants.screenHeight(context) * 0.025),
                    )),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "dont have an account ?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.register);
                      },
                      child: Text(
                        "register",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ReusableTextfield {
}
