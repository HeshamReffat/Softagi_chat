import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:softagi_chat/modules/createprofile/create_profile.dart';
import 'package:softagi_chat/modules/home/home_screen.dart';
import 'package:softagi_chat/modules/verification/bloc/verification_cubit.dart';
import 'package:softagi_chat/shared/Prefrences.dart';
import 'package:softagi_chat/shared/ThemeChanger.dart';
import 'modules/welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initPref();
  Widget screen;
  var currentUser = FirebaseAuth.instance.currentUser;
  var profile = getCreateProfile();
  if (currentUser != null && profile == 'Created') {
    screen = HomeScreen();
  } else if (profile == 'not') {
    screen = CreateProfile();
  } else {
    screen = WelcomeScreen();
  }
  return runApp(  MyApp(screen));
}
class MyApp extends StatefulWidget {
  Widget screen;

  MyApp(this.screen);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState _lastLifecyleState;
  var profile = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onDeactivate() {
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(
        "LifecycleWatcherState#didChangeAppLifecycleState state=${state.toString()}");
    setState(() {
      _lastLifecyleState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Future<bool> check() async {
    //   var connectivityResult = await (Connectivity().checkConnectivity());
    //   if (connectivityResult == ConnectivityResult.mobile) {
    //     return true;
    //   } else if (connectivityResult == ConnectivityResult.wifi) {
    //     return true;
    //   }
    //   return false;
    // }
    // check().then((value) {
    //   if(value == true){
    //     FirebaseFirestore.instance
    //         .collection('users')
    //         .doc(FirebaseAuth.instance.currentUser.uid)
    //         .update({
    //       'status': 'online',
    //     }).then((value) {
    //       FirebaseFirestore.instance
    //           .collection('users')
    //           .doc(FirebaseAuth.instance.currentUser.uid)
    //           .update({
    //         'action': 'online',
    //       });
    //       print('status online');
    //     }).catchError((error) {
    //       print(error.toString());
    //     });
    //   }else{
    //     FirebaseFirestore.instance
    //         .collection('users')
    //         .doc(FirebaseAuth.instance.currentUser.uid)
    //         .update({
    //       'status': 'off',
    //     }).then((value) {
    //       FirebaseFirestore.instance
    //           .collection('users')
    //           .doc(FirebaseAuth.instance.currentUser.uid)
    //           .update({
    //         'action': '',
    //       });
    //     }).catchError((error) {
    //       print(error.toString());
    //     });
    //   }
    // });
    if (_lastLifecyleState == AppLifecycleState.inactive ||
        _lastLifecyleState == AppLifecycleState.detached) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({
        'status': 'off',
        'action': '',
        'chattingWith': '',
      }).then((value) {
        print('Status offline');
      }).catchError((error) {
        print(error.toString());
      });
    }
    if (_lastLifecyleState == AppLifecycleState.resumed) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({
        'status': 'online',
        'action': 'online',
        'chattingWith': getUserItemId(),
      }).then((value) {
        print('status online');
      }).catchError((error) {
        print(error.toString());
      });

      //  Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      //   // Got a new connectivity status!
      // });
      //print('offfff');
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (ctx) => VerificationCubit()..deviceToken()),
      ],
      child: ChangeNotifierProvider<ThemeChanger>(
        create: (_) => ThemeChanger(),
        child: Builder(builder: (context) {
          final themeChanger = Provider.of<ThemeChanger>(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Softagi Chat',
            themeMode: themeChanger.themeMode,
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColorDark: Colors.white10,
              primaryColor: Color(0xFF1C1C1C),
              scaffoldBackgroundColor: Color(0xFF1C1C1C),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                foregroundColor: Colors.white,
              ),
              /* dark theme settings */
            ),
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              primaryColorDark: Colors.blueGrey[700],
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: widget.screen,
          );
        }),
      ),
    );
  }
  void getProfile() {
    profile = getCreateProfile();
    setState(() {});
  }
}
