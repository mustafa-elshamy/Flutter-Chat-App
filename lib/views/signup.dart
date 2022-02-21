import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/data_bloc/data_bloc.dart';
import '../widgets/widget.dart';
import 'chat_room.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formkey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController();
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
              padding: EdgeInsets.symmetric(horizontal: 24,vertical: 10),
              child: ListView(
//                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: formkey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height/4,
                          width: MediaQuery.of(context).size.height/2,
                          child: Image.asset("assets/images/chat.png"),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height/7,),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: TextDecor("Username"),
                          controller: usernameController,
                          validator: (val) {
                            if (val.isEmpty) return "Enter username";
                            if (val.length < 4)
                              return "Enter at least 4 characters";
                            return null;
                          },
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: TextDecor("Email"),
                          controller: emailController,
                          validator: (val) {
                            if (val.isEmpty) return "Enter email";
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)
                                ? null
                                : "Incorrect Email";
                          },
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration: TextDecor("Password"),
                          controller: passController,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          validator: (val) {
                            if (val.isEmpty) return "Enter password";
                            return val.length < 8
                                ? "Enter at least 8 characters"
                                : null;
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      if (formkey.currentState.validate()) {
                        BlocProvider.of<DataBloc>(context).add(SignUpEvent(
                            username: usernameController.text,
                            email: emailController.text,
                            password: passController.text));
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30)),
                      alignment: Alignment.center,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      alignment: Alignment.center,
                      child: Text(
                        "Sign Up With Google",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have account? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          BlocProvider.of<DataBloc>(context)
                              .add(NavigateSwitchScreenEvent(isSignIn: true));
                        },
                        child: Text(
                          "Sign in",
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
            ));
      },
    );
  }
}
