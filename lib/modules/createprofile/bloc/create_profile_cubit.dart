import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:softagi_chat/modules/createprofile/bloc/create_profile_states.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:softagi_chat/modules/home/home_screen.dart';
import 'package:softagi_chat/shared/components.dart';

class CreateProfileCubit extends Cubit<CreateProfileStates> {
  String userId = FirebaseAuth.instance.currentUser.uid;
  File image;
  Map userData = {};

  CreateProfileCubit() : super(ProfileInit());

  static CreateProfileCubit get(context) => BlocProvider.of(context);

  Future<void> pickImage() async {
    await ImagePicker().getImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        image = File(value.path);
        print(value.path);
        uploadImage();
        emit(ProfilePickImage());
      }
    });
  }

  void uploadImage() {
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child(
            'users/${FirebaseAuth.instance.currentUser.uid}/profileImage/${Uri.file(image.path).pathSegments.last}')
        .putFile(image)
        .onComplete
        .then((value) {
      value.ref.getDownloadURL().then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .update({
          'image': value.toString(),
          'last_path':
              '${FirebaseAuth.instance.currentUser.uid}/profileImage/${Uri.file(image.path).pathSegments.last}',
        }).then((value) {
          emit(UploadImageSuccess());
          print('success');
        }).catchError((error) {
          print(error.toString());
        });
      });
    });
  }

  void getRealTimeUserData() {
    //emit(ProfileLoading());
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((event) {
      userData = event.data();
      emit(GetRealTimeUserData());
    });
  }
  void updateUserData(String fName,String lName,context){
    emit(ProfileLoading());
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'first_name': fName,
      'last_name': lName,
      'status': 'online',
      'action': 'online',
    }).then((value) {
      emit(ProfileSuccess());
      navigateAndFinish(
        context,
        HomeScreen(),
      );
    }).catchError((error) {
      print(error.toString());
    });
  }
}
