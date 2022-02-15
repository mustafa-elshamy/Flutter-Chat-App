import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../bloc/chat_room_bloc/chat_room_bloc.dart';
import '../bloc/data_bloc/data_bloc.dart';
import '../bloc/data_bloc/data_bloc.dart';
import '../helper/helper_functions.dart';
import '../model/user.dart';
import '../services/authentication.dart';
import '../services/database.dart';
import '../widgets/widget.dart';
import 'chat.dart';
import 'chat_room.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DataBloc, DataState>(
      listener: (context, state) {
        if (state is LoginErrorState) {
          ShowToast(state.errorMessage);
        } else if (state is LoginInState) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatRoom(state.currentUser)));
        }
      },
      builder: (context, state) {
        return Scaffold(
            appBar: appBarMain(context, "Chat App"),
            body: Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(left: 24, right: 24, bottom: 50),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: TextDecor("Email"),
                          validator: (val) {
                            if (val.isEmpty) return "Enter email";
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "Incorrect Email";
                          },
                          controller: emailController,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: TextDecor("Password"),
                          validator: (val) {
                            return val.isEmpty ? "Enter password" : null;
                          },
                          controller: passController,
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        if (formKey.currentState.validate()) {
                          BlocProvider.of<DataBloc>(context).add(SignInEvent(
                              email: emailController.text,
                              password: passController.text));
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width - 30,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(30)),
                        alignment: Alignment.center,
                        child: Text(
                          "Sign In",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: MediaQuery.of(context).size.width - 30,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      alignment: Alignment.center,
                      child: Text(
                        "Sign In With Google",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have account? ",
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            BlocProvider.of<DataBloc>(context).add(
                                NavigateSwitchScreenEvent(isSignIn: false));
                          },
                          child: Text(
                            "Register Now",
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontSize: 15),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }
}
