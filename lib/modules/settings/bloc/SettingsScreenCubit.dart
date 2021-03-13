import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:softagi_chat/modules/settings/bloc/SettingsScreenStates.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:softagi_chat/shared/Prefrences.dart';

class SettingsScreenCubit extends Cubit<SettingsScreenStates> {
  SettingsScreenCubit() : super(SettingsScreenInit());
  Map data = {};
  File image;
  static SettingsScreenCubit get(context) => BlocProvider.of(context);

  void getRealTimeMyData() {
    emit(SettingsScreenLoading());
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((event) {
          data = event.data();
          emit(GetRealTimeMyData());
    });
  }

  Future<void> pickImage() async {
    await ImagePicker().getImage(source: ImageSource.gallery).then((value) {
      if (value != null) {
        image = File(value.path);
        print(value.path);
        uploadImage();
        emit(PickImage());
      }
    });
  }

  uploadImage() {
    if (data['last_path'] != 'demo') {
      firebase_storage.FirebaseStorage.instance
          .ref()
          .child('users/${data['last_path']}')
          .delete()
          .then((value) {
        firebase_storage.FirebaseStorage.instance
            .ref()
            .child('users/${FirebaseAuth.instance.currentUser.uid}/profileImage/${Uri.file(image.path).pathSegments.last}')
            .putFile(image)
            .onComplete
            .then((value) {
          value.ref.getDownloadURL().then((value) {
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser.uid)
                .update({
              'image': value.toString(),
              'last_path': '${FirebaseAuth.instance.currentUser.uid}/profileImage/${Uri.file(image.path).pathSegments.last}',
            }).then((value) {
              emit(DeletedAndUploaded());
              print('success');
            }).catchError((error) {
              print(error.toString());
            });
          });
        });
      }).catchError((error) {});
    } else {
      firebase_storage.FirebaseStorage.instance
          .ref()
          .child('users/${FirebaseAuth.instance.currentUser.uid}/profileImage/${Uri.file(image.path).pathSegments.last}')
          .putFile(image)
          .onComplete
          .then((value) {
        value.ref.getDownloadURL().then((value) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser.uid)
              .update({
            'image': value.toString(),
            'last_path': '${FirebaseAuth.instance.currentUser.uid}/profileImage/${Uri.file(image.path).pathSegments.last}',
          }).then((value) {
            emit(FirstTimeUploaded());
            print('success');
          }).catchError((error) {
            print(error.toString());
          });
        });
      });
    }
  }
}
