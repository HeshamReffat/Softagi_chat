import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softagi_chat/modules/home/bloc/HomeScreenStates.dart';

class HomeScreenCubit extends Cubit<HomeScreenStates> {
  HomeScreenCubit() : super(HomeInit());
  Map data = {};
  List myChats = [];

  static HomeScreenCubit get(context) => BlocProvider.of(context);


  void getMyChats() {
    //emit(HomeLoading());
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('chats')
        .orderBy('lmessage_time', descending: true)
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      myChats = event.docs;
      emit(HomeSuccess());
    });
  }
  void deleteChat(id){
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('chats').doc(id).collection('messages').get().then((value) {
      for (DocumentSnapshot ds in value.docs){
        ds.reference.delete();
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('chats').doc(id).delete();
    });
  }
  void getRealTimeData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((event) {
          data = event.data();
          emit(GetRealTimeMyData());
    });
  }

  void updateStatus() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({
      'status': 'online',
    }).then((value) {
      emit(UpdateStatus());
      print('success');
    }).catchError((error) {
      print(error.toString());
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
