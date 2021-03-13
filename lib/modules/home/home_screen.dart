import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:softagi_chat/modules/chat/chat_screen.dart';
import 'package:softagi_chat/modules/home/bloc/HomeScreenCubit.dart';
import 'package:softagi_chat/modules/home/bloc/HomeScreenStates.dart';
import 'package:softagi_chat/modules/settings/settings_screen.dart';
import 'package:softagi_chat/modules/users/users_screen.dart';
import 'package:softagi_chat/shared/Prefrences.dart';
import 'package:softagi_chat/shared/components.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeScreenCubit(),
      child: Builder(
        builder: (builderContext) {
          HomeScreenCubit.get(builderContext).getRealTimeData();
          HomeScreenCubit.get(builderContext).getMyChats();
          HomeScreenCubit.get(builderContext).updateStatus();
          return BlocConsumer<HomeScreenCubit, HomeScreenStates>(
            listener: (ctx, state) {},
            builder: (ctx, state) {
              var bloc = HomeScreenCubit.get(ctx);
              return Scaffold(
                appBar: AppBar(
                  elevation: 0.0,
                  title: GestureDetector(
                    onTap: () {
                      navigateTo(
                        context,
                        SettingsScreen(),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20.0,
                          backgroundImage: bloc.data['image'] == null
                              ? NetworkImage(
                              'https://i.pinimg.com/originals/51/f6/fb/51f6fb256629fc755b8870c801092942.png')
                              : NetworkImage(bloc.data['image']),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Text(
                          'Chat App',
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'My Chats',
                        style: bold16(),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (bloc.myChats.length > 0)
                            ListView.separated(
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                if (bloc.myChats[index]['id'] !=
                                    FirebaseAuth.instance.currentUser.uid)
                                  return itemSwipe(
                                    bloc: bloc,
                                    id: bloc.myChats[index]['id'],
                                    child: buildItem(
                                        bloc.myChats[index], context, bloc),
                                  );
                                else
                                  return Container();
                              },
                              separatorBuilder: (context, index) => Divider(),
                              itemCount: bloc.myChats.length,
                            ),
                          if (bloc.myChats.length == 0)
                            Center(
                              child: Text('No chats yet'),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Colors.indigo,
                  onPressed: () {
                    navigateTo(
                      context,
                      UsersScreen(),
                    );
                  },
                  child: Icon(
                    Icons.edit,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildItem(item, context, HomeScreenCubit bloc) {
    final date = DateFormat('hh:mm a');
    return InkWell(
      onLongPress: () {
        //deleteChat(item['id']);
      },
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
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(
                    item['image'],
                  ),
                ),
                // if(counter != 0)
                if (item['newMessage'] != 0)
                  CircleAvatar(
                    radius: 10.0,
                    backgroundColor: Colors.red,
                    child:
                    // Icon(
                    //   Icons.message,
                    //   size: 12,
                    //   color: Colors.white,
                    // )
                    Text(
                      '${item['newMessage']}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
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
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item['last_message']}',
                          style: bold14(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Spacer(),
                      Text(
                        date.format(
                          DateTime.fromMillisecondsSinceEpoch(
                              item['lmessage_time']),
                        ),
                      ),
                      //Text('${DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(item['lmessage_time'])).inHours} min ago')
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemSwipe({child,bloc, id}) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: child,
      // actions: <Widget>[
      //   IconSlideAction(
      //     caption: 'Archive',
      //     color: Colors.blue,
      //     icon: Icons.archive,
      //     onTap: () => Fluttertoast.showToast(msg:'Archive'),
      //   ),
      //   IconSlideAction(
      //     caption: 'Share',
      //     color: Colors.indigo,
      //     icon: Icons.share,
      //     onTap: () => Fluttertoast.showToast(msg:'Share'),
      //   ),
      // ],
      secondaryActions: <Widget>[
        // IconSlideAction(
        //   caption: 'More',
        //   color: Colors.black45,
        //   icon: Icons.more_horiz,
        //   onTap: () => Fluttertoast.showToast(msg:'More'),
        // ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            bloc.deleteChat(id);
            return Fluttertoast.showToast(msg: 'Delete');
          },
        ),
      ],
    );
  }

  void deleteChat(chatID, context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Delete Chat'),
          content: Text('Are You Sure?'),
          actions: [
            FlatButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser.uid)
                      .collection('chats')
                      .doc(chatID)
                      .delete();
                  Navigator.pop(context);
                },
                child: Text('yes'))
          ],
        );
      },
    );
  }
}
