import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softagi_chat/modules/verification/bloc/verification_cubit.dart';
import 'package:softagi_chat/modules/verification/bloc/verification_states.dart';
import 'package:softagi_chat/shared/components.dart';

class VerificationScreen extends StatelessWidget {
  var codeController = TextEditingController();
  var node = FocusNode();

  @override
  Widget build(BuildContext context) {
    node.requestFocus();

    return BlocConsumer<VerificationCubit, VerificationStates>(
      listener: (ctx, state) {
        // if(state is VerificationInit){
        // }
      },
      builder: (ctx, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
          body: Padding(
            padding: EdgeInsets.all(50.0),
            child: Column(
              children: [
                Text(
                  'Enter your verification code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30.0,
                ),
                TextFormField(
                  controller: codeController,
                  focusNode: node,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'sms code',
                  ),
                ),
                SizedBox(
                  height: 50.0,
                ),
                defaultButton(
                  function: () {
                    VerificationCubit.get(ctx).phoneAuthentication(codeController.text, context);
                  },
                  text: 'start',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
