import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:softagi_chat/modules/chat/chat_screen.dart';
import 'package:softagi_chat/modules/users/bloc/UsersScreenCubit.dart';
import 'package:softagi_chat/modules/users/bloc/UsersScreenStates.dart';
import 'package:softagi_chat/shared/Prefrences.dart';
import 'package:softagi_chat/shared/components.dart';

class UsersScreen extends StatelessWidget {
  var phonesNumber;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsersScreenCubit()..getUsers(),
      child: BlocConsumer<UsersScreenCubit, UsersScreenStates>(
        listener: (ctx, state) {},
        builder: (ctx, state) {
          var bloc = UsersScreenCubit.get(ctx);
          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Text(
                'Users',
              ),
            ),
            body: SmartRefresher(
              controller: bloc.refreshController,
              onRefresh: bloc.onRefresh,
              onLoading: bloc.onLoading,
              enablePullDown: true,
             // enablePullUp: true,
              header: WaterDropMaterialHeader(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (bloc.users.length > 0)
                    ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (bloc.users[index]['id'] !=
                            FirebaseAuth.instance.currentUser.uid) {
                          return buildItem(bloc.users[index], context, bloc);
                        } else {
                          return Container();
                        }
                      },
                      // separatorBuilder: (context, index) =>
                      //     Container(
                      //   width: double.infinity,
                      //   height: 1.0,
                      //   //color: Colors.grey[300],
                      // ),
                      itemCount: bloc.users.length,
                    ),
                  if (bloc.users.length == 0)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildItem(item, context, UsersScreenCubit bloc) => InkWell(
        onTap: () {
          saveUserItemId(item['id']).then((value) {
            bloc.updateChattingWith(item['id']);
            navigateTo(
              context,
              ChatScreen(),
            );
          });
        },
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: NetworkImage(
                      item['image'],
                    ),
                  ),
                  if (item['status'] == 'online')
                    CircleAvatar(
                      radius: 7.0,
                      backgroundColor: Colors.green,
                    ),
                ],
              ),
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${item['first_name']} ${item['last_name']}',
                      style: bold18(),
                    ),
                    Text(
                      '${item['slogan']}',
                      style: grey14(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  // void getContacts() async {
  //   PermissionStatus status = await Permission.contacts.request();
  //   if (status.isGranted) {
  //     Iterable<Contact> contacts = await ContactsService.getContacts();
  //     contacts.forEach((element) {
  //       element.phones.forEach((phone) {
  //         phonesNumber = phone.value;
  //         print(phonesNumber);
  //       });
  //     });
  //   }
  // }
}
