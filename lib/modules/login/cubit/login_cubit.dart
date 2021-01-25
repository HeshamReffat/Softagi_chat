import 'package:firebase_auth/firebase_auth.dart';
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
        codeSent: (String verificationId, int resendToken) {
          emit(LoginSuccess());
          savePhone(phone);
          saveSmSCode(verificationId);
          navigateTo(context, VerificationScreen());
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          emit(LoginFailed());
        });
  }
}
