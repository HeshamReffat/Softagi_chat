import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:softagi_chat/modules/users/bloc/UsersScreenStates.dart';

class UsersScreenCubit extends Cubit<UsersScreenStates> {
  UsersScreenCubit() : super(UsersScreenInit());
  List users = [];
  List<Contact> contact = [];
  List<Contact> phonesNumber = [];

  String getNumber(number) =>
      number.toString().replaceAll('+2', '').replaceAll(' ', '').toLowerCase();

  static UsersScreenCubit get(context) => BlocProvider.of(context);



  RefreshController refreshController =
  RefreshController(initialRefresh: false);

  void onRefresh() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 500));
    // if failed,use refreshFailed()
    getUsers();
    refreshController.refreshCompleted();
    emit(OnRefresh());
  }

  void onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    getUsers();
    refreshController.loadComplete();
    emit(OnLoading());
  }
    void getUsers() {
    emit(UsersScreenLoading());
    FirebaseFirestore.instance.collection('users').get().then((event) {
      print(event.docs.length);
      users = event.docs;
      //getContacts();
      emit(UsersScreenSuccess());
    });
  }

  void getUsersSigned() {
    //emit(UsersScreenLoading());
      FirebaseFirestore.instance.collection('users').get().then((event) {
        //print(event.docs.length);
        var data = event.docs;
        data.forEach((element) async {
          for (int i = 0; i < contact.length; i++) {
            if (getNumber(contact[i].phones.elementAt(0).value) ==
                (getNumber(element['phone']))&& element['id'] != FirebaseAuth.instance.currentUser.uid) {
              phonesNumber.add(contact[i]);

              print(phonesNumber.length);
            }
            emit(UsersSignedSuccess());
          }
        });
      });
  }

  void getContacts() async {
    PermissionStatus status = await Permission.contacts.request();
    if (status.isGranted) {
      await ContactsService.getContacts(withThumbnails: false).then((value) {
        value.forEach((element) {
          if (element.phones.isNotEmpty) {
            contact.add(element);
          }
          getUsersSigned();
          emit(GetContacts());
        });
        // element.phones.forEach((phone) {
        //   phonesNumber = phone.value;
        // print(contact.length);

      });
    }
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
