import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/chat_bloc/chat_bloc.dart';
import 'bloc/chat_room_bloc/chat_room_bloc.dart';
import 'bloc/data_bloc/data_bloc.dart';
import 'views/chat_room.dart';
import 'views/switch_page.dart';
import 'widgets/widget.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DataBloc dataBloc = DataBloc();

  @override
  void initState() {
    super.initState();
    dataBloc.add(InitializeFirebase());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatRoomBloc()),
        BlocProvider(create: (context) => dataBloc),
        BlocProvider(create: (context) => ChatBloc())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.black38,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: BlocBuilder<DataBloc, DataState>(
          builder: (context, state) {
            if (state is LoginInState) {
              return ChatRoom(state.currentUser);
            } else if (state is LoadingState) {
              return Loading("Connecting to Firebase...");
            }
            return SwitchPage();
          },
        ),
      ),
    );
  }
}
