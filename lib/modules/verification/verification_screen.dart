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

// void phoneAuthentication(String code, context) async {
//   PhoneAuthCredential phoneAuthCredential =
//       PhoneAuthProvider.credential(verificationId: this.code, smsCode: code);
//
//   await FirebaseAuth.instance
//       .signInWithCredential(phoneAuthCredential)
//       .then((value) {
//     FirebaseFirestore.instance.collection('users').doc(value.user.uid).set({
//       'first_name': 'no',
//       'last_name': 'name',
//       'id': value.user.uid,
//       'phone': this.phone,
//       'image':
//           'https://i.pinimg.com/originals/51/f6/fb/51f6fb256629fc755b8870c801092942.png',
//       'status': 'offline',
//       'last_path': 'demo',
//       'chatCreated': 'false',
//       'last_message': '',
//       'newMessage': 0,
//       'lmessage_time': DateTime.now().millisecondsSinceEpoch,
//       'action': '',
//       'chattingWith':'',
//       'slogan':'Available'
//     }).then((value) {
//       // navigateAndFinish(
//       //   context,
//       //   HomeScreen(),
//       // );
//     }).catchError((error) {
//       print(error.toString());
//     });
//     print(value.user.uid);
//     //userId = value.user.uid;
//     navigateAndFinish(
//         context, CreateProfile(userId: value.user.uid, phone: phone));
//   }).catchError((e) {
//     Fluttertoast.showToast(msg: 'SMS code is Wrong');
//   });
// }
}
