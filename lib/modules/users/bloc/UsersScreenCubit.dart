import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softagi_chat/modules/users/bloc/UsersScreenStates.dart';

class UsersScreenCubit extends Cubit<UsersScreenStates> {
  UsersScreenCubit() : super(UsersScreenInit());
  List users = [];

  static UsersScreenCubit get(context) => BlocProvider.of(context);

  void getUsers() {
    emit(UsersScreenLoading());
    FirebaseFirestore.instance.collection('users').snapshots().listen((event) {
      print(event.docs.length);
      users = event.docs;
      emit(UsersScreenSuccess());
    });
  }
  void updateChattingWith(String text) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({'chattingWith': text}).then((value) {
      emit(UpdateChattingWith());
    });
  }
}
