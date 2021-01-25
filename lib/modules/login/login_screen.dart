import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softagi_chat/modules/login/cubit/login_cubit.dart';
import 'package:softagi_chat/modules/login/cubit/login_states.dart';
import 'package:softagi_chat/modules/verification/bloc/verification_cubit.dart';
import 'package:softagi_chat/shared/components.dart';

class LoginScreen extends StatelessWidget {


  var codeController = TextEditingController()..text = '+20';
  var phoneController = TextEditingController();
  var node = FocusNode();

  @override
  Widget build(BuildContext context) {
    node.requestFocus();

    return BlocProvider(
      create: (context)=>LoginCubit(),
      child: BlocConsumer<LoginCubit,LoginStates>(
        listener: (ctx,state){
          if(state is LoginSuccess){
            VerificationCubit.get(ctx).getPhoneData();
          }
        },
        builder: (ctx,state){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Column(
                  children: [
                    Text(
                      'Enter your phone number to get started.',
                      textAlign: TextAlign.center,
                      style: bold18(),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      'you will receive a verification code.',
                      style: size14(),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 50.0,
                          child: TextFormField(
                            controller: codeController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'code',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            focusNode: node,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'phone number',
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50.0,
                    ),
                    defaultButton(
                      function: () {
                        LoginCubit.get(ctx).phoneVerification(phoneController.text, context);
                      },
                      text: 'next',
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

  // void phoneVerification(String phone, context) async {
  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //       phoneNumber: '+20$phone}',
  //       verificationCompleted: (PhoneAuthCredential credential) {},
  //       verificationFailed: (FirebaseAuthException e) {
  //         print(e.toString());
  //       },
  //       codeSent: (String verificationId, int resendToken) {
  //         navigateTo(context, VerificationScreen(verificationId,'+20$phone'));
  //       },
  //       codeAutoRetrievalTimeout: (String verificationId) {});
  // }
}
