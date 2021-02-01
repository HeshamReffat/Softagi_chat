import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softagi_chat/modules/login/cubit/login_states.dart';
import 'package:softagi_chat/modules/verification/verification_screen.dart';
import 'package:softagi_chat/shared/Prefrences.dart';
import 'package:softagi_chat/shared/components.dart';

class LoginCubit extends Cubit<LoginStates> {
  LoginCubit() : super(LoginInit());

  static LoginCubit get(context) => BlocProvider.of(context);

  void phoneVerification(String phone, context) async {
    emit(LoginLoading());
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+20$phone}',
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          print(e.toString());
        },
        codeSent: (String verificationId, int resendToken) async {
          savePhone(phone);
          saveSmSCode(verificationId);
          await FirebaseMessaging().getToken().then((value) {
            print(value.toString());
            saveDeviceToken(value.toString()).then((value) {
              navigateTo(context, VerificationScreen());
            });
          });
          emit(LoginSuccess());
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          emit(LoginFailed());
        });
  }
}
