import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:softagi_chat/modules/createprofile/create_profile.dart';
import 'package:softagi_chat/modules/verification/bloc/verification_states.dart';
import 'package:softagi_chat/shared/Prefrences.dart';
import 'package:softagi_chat/shared/components.dart';

class VerificationCubit extends Cubit<VerificationStates> {
  VerificationCubit() : super(VerificationInit());
  String smsCode;
  String phone;
  String token;

  static VerificationCubit get(context) => BlocProvider.of(context);

  void phoneAuthentication(String code, context) async {
    emit(VerificationLoading());
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: this.smsCode, smsCode: code);

    await FirebaseAuth.instance
        .signInWithCredential(phoneAuthCredential)
        .then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(value.user.uid)
          .set({
            'first_name': 'no',
            'last_name': 'name',
            'id': value.user.uid,
            'phone': this.phone,
            'image':
                'https://i.pinimg.com/originals/51/f6/fb/51f6fb256629fc755b8870c801092942.png',
            'status': 'offline',
            'last_path': 'demo',
            'chatCreated': 'false',
            'last_message': '',
            'newMessage': 0,
            'lmessage_time': DateTime.now().millisecondsSinceEpoch,
            'action': '',
            'chattingWith': '',
            'deviceToken': token,
            'slogan': 'Available'
          })
          .then((value) {})
          .catchError((error) {
            print(error.toString());
          });
      print(value.user.uid);
      saveCreateProfile('not');
      emit(VerificationSuccess());
      navigateAndFinish(context, CreateProfile());
    }).catchError((e) {
      emit(VerificationFailed());
      Fluttertoast.showToast(msg: 'SMS code is Wrong');
    });
  }

  void getPhoneData() {
    phone = '+20 ${getPhone()}';
    smsCode = getCode();
    emit(VerificationPhone());
  }

  void deviceToken() {
    token = getDeviceToken();
    print(token);
    emit(VerificationToken());
  }
}
