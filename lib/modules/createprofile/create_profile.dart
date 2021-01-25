
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:softagi_chat/modules/createprofile/bloc/create_profile_cubit.dart';
import 'package:softagi_chat/modules/createprofile/bloc/create_profile_states.dart';
import 'package:softagi_chat/shared/components.dart';

class CreateProfile extends StatelessWidget {
  var fNameController = TextEditingController();

  var lNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=>CreateProfileCubit()..getRealTimeUserData(),
      child: BlocConsumer<CreateProfileCubit,CreateProfileStates>(
        listener: (ctx,state){},
        builder: (ctx,state){
          var bloc = CreateProfileCubit.get(ctx);
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Set up your profile',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40.0,
                          backgroundImage: NetworkImage(
                            bloc.userData['image'] ??
                                'https://i.pinimg.com/originals/51/f6/fb/51f6fb256629fc755b8870c801092942.png',
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            bloc.pickImage();
                          },
                          child: CircleAvatar(
                            radius: 15.0,
                            child: Icon(Icons.camera),
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: fNameController,
                      decoration: InputDecoration(hintText: 'First name (required)'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: lNameController,
                      decoration: InputDecoration(hintText: 'Last name (required)'),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                        'Your profile is end-to-end encrypted. Your profile and changes will be visible to other users when you initiate or accept new conversations.'),
                    SizedBox(
                      height: 50,
                    ),
                    defaultButton(
                      text: 'NEXT',
                      function: () {
                        if (fNameController.text.isNotEmpty &&
                            lNameController.text.isNotEmpty) {
                          bloc.updateUserData(fNameController.text, lNameController.text, context);
                        } else {
                          Fluttertoast.showToast(msg: 'Please enter your name');
                        }
                      },
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
}
