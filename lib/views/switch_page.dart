import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/data_bloc/data_bloc.dart';
import '../widgets/widget.dart';
import 'signin.dart';
import 'signup.dart';

class SwitchPage extends StatefulWidget {
  const SwitchPage({Key key}) : super(key: key);

  @override
  _SwitchPageState createState() => _SwitchPageState();
}

class _SwitchPageState extends State<SwitchPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataBloc, DataState>(builder: (context, state) {
      print("main: $state");
      if (state is NavigateSwitchScreenState) {
        return state.isSignScreen ? SignIn() : SignUp();
      } else if (state is LoginErrorState) {
        return state.isSignInScreen ? SignIn() : SignUp();
      } else if (state is LogoutState) {
        return SignIn();
      } else {
        // impossible
        return Container();
      }
    });
  }
}
