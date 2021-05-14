import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:softagi_chat/modules/settings/bloc/SettingsScreenCubit.dart';
import 'package:softagi_chat/modules/settings/bloc/SettingsScreenStates.dart';
import 'package:softagi_chat/shared/Prefrences.dart';
import 'package:softagi_chat/shared/ThemeChanger.dart';
import 'package:softagi_chat/shared/components.dart';

class SettingsScreen extends StatelessWidget {
  var fNameController = TextEditingController();
  var lNameController = TextEditingController();
  var sloganController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsScreenCubit()..getRealTimeMyData(),
      child: BlocConsumer<SettingsScreenCubit, SettingsScreenStates>(
        listener: (ctx, state) {},
        builder: (ctx, state) {
          var bloc = SettingsScreenCubit.get(ctx);
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Settings',
              ),
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 40.0,
                              backgroundImage: bloc.data['image'] == null
                                  ? NetworkImage(
                                      'https://i.pinimg.com/originals/51/f6/fb/51f6fb256629fc755b8870c801092942.png')
                                  : NetworkImage(bloc.data['image']),
                            ),
                            GestureDetector(
                              onTap: () {
                                bloc.pickImage();
                              },
                              child: CircleAvatar(
                                radius: 15.0,
                                backgroundColor: Colors.green,
                                child: Icon(
                                  Icons.camera,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${bloc.data['first_name']} ${bloc.data['last_name']}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        editNameDialog(context);
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.green,
                                      )),
                                ],
                              ),
                              Text(
                                FirebaseAuth.instance.currentUser.phoneNumber,
                                style: size14(),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                      child: Text('${bloc.data['slogan']}')),
                                  InkWell(
                                      onTap: () {
                                        editSloganDialog(context);
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.green,
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.message,
                          size: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SMS and MMS',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              'off',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.add_alert_rounded,
                          size: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notification',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              'on',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.lock,
                          size: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Privacy',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                'Screen lock off,Registration lock off',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.wb_sunny_rounded,
                          size: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        GestureDetector(
                          onTap: () {
                            showChooser(context);
                            // changeBrightness(context);
                            // changeColor(context);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width - 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Appearance',
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  'Theme System default,Language System default',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.image,
                          size: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Chats and media',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.storage_outlined,
                          size: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Storage',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Linked devices',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.help,
                          size: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Help',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.code,
                          size: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Advanced',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 30,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          'Donate to us',
                          style: TextStyle(fontSize: 20),
                        ),
                        Spacer(),
                        Icon(Icons.ios_share)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void editNameDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text('Edit Name')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'First name (required)'),
                      controller: fNameController,
                    ),
                  )),
              SizedBox(
                height: 10.0,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Last name (required)'),
                    controller: lNameController,
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              defaultButton(
                function: () {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .update({
                    'first_name': fNameController.text,
                    'last_name': lNameController.text,
                  }).then((value) {
                    fNameController.clear();
                    lNameController.clear();
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    print(error.toString());
                  });
                },
                text: 'Save',
              ),
            ],
          ),
        );
      },
    );
  }

  void editSloganDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text('Bio')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          border: InputBorder.none, hintText: 'Bio (required)'),
                      controller: sloganController,
                    ),
                  )),
              SizedBox(
                height: 20.0,
              ),
              defaultButton(
                  function: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser.uid)
                        .update({
                      'slogan': sloganController.text,
                    }).then((value) {
                      sloganController.clear();
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      print(error.toString());
                    });
                  },
                  text: 'Save'),
            ],
          ),
        );
      },
    );
  }

  void showChooser(context) {
    final themeChanger = Provider.of<ThemeChanger>(context,listen: false);
    showDialog<void>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Theme'),
          children: <Widget>[
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              groupValue: themeChanger.themeMode,
              value: ThemeMode.system,
              onChanged: themeChanger.setTheme,
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light Mode'),
              groupValue: themeChanger.themeMode,
              value: ThemeMode.light,
              onChanged: themeChanger.setTheme,
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark Mode  👻'),
              groupValue: themeChanger.themeMode,
              value: ThemeMode.dark,
              onChanged: themeChanger.setTheme,
            ),
          ],
        );
      },
    );
  }
}
