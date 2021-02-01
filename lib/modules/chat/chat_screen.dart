import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:softagi_chat/modules/chat/bloc/chat_screen_cubit.dart';
import 'package:softagi_chat/modules/chat/bloc/chat_screen_states.dart';
import 'package:softagi_chat/modules/home/home_screen.dart';
import 'package:softagi_chat/shared/Prefrences.dart';
import 'package:softagi_chat/shared/components.dart';

class ChatScreen extends StatelessWidget {
  var messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)=> ChatScreenCubit()..getUserId()..getRealTimeUserData()..getRealTimeMyData()..firebaseMessage(),
      child: BlocConsumer<ChatScreenCubit,ChatScreenStates>(
        listener: (ctx,state){
        },
        builder: (ctx,state){
          var bloc = ChatScreenCubit.get(ctx);
          return WillPopScope(
            // ignore: missing_return
            onWillPop: () {
              bloc.updateStatus('online');
              bloc.updateChattingWith('');
              saveUserItemId('');
              navigateAndFinish(context, HomeScreen());
            },
            child: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                titleSpacing: 0.0,
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.0,
                      backgroundImage: NetworkImage(
                        bloc.userData['image'] ??
                            'https://i.pinimg.com/originals/51/f6/fb/51f6fb256629fc755b8870c801092942.png',
                      ),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${bloc.userData['first_name']} ${bloc.userData['last_name']}',
                            style: TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          if (bloc.userData['action'] != '')
                            Text(
                              '${bloc.userData['action']}',
                              style: TextStyle(
                                fontSize: 12.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.phone,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.video_call,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        if (bloc.messagesList.length > 0)
                          ListView.builder(
                            reverse: true,
                            itemBuilder: (context, index) {
                              if (bloc.messagesList[index]['id'] ==
                                  FirebaseAuth.instance.currentUser.uid)
                                return myItem(bloc.messagesList[index],bloc,context);
                              else
                                return userItem(bloc.messagesList[index],bloc,context);
                            },
                            itemCount: bloc.messagesList.length,
                          ),
                        if (bloc.messagesList.length == 0)
                          Center(
                            child: Text('No messages yet'),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                10.0,
                              ),
                              border: Border.all(
                                color: Colors.grey[300],
                                width: 1.0,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: messageController,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: () {
                                      FocusScope.of(context).unfocus();
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'enter message ...'),
                                    maxLines: null,
                                    onChanged: (text) {
                                      if (text.length > 0) {
                                        if (bloc.myData['action'] != 'typing...')
                                          bloc.updateStatus('typing...');
                                      }
                                      if (text.isEmpty) {
                                        bloc.updateStatus('online');
                                      }
                                    },
                                  ),
                                ),
                                InkWell(
                                    onTap: () {
                                      bloc.pickImage();
                                    },
                                    child: Icon(Icons.image)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15.0,
                        ),
                        GestureDetector(
                          onTap: messageController.text.isEmpty
                              ? null
                              : () {
                            bloc.sendMessage(messageController.text);
                            bloc.updateStatus('online');
                            bloc.sendNotification(messageController.text);
                            messageController.clear();
                            if (bloc.checkChat != null) {
                              bloc.checkChat['chatCreated'] == 'true'
                                  ? bloc.updateInfoChat()
                                  : bloc.createChat();
                            } else {
                              bloc.createChat();
                            }
                          },
                          child: CircleAvatar(
                            radius: 25,
                            child: Icon(Icons.send),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget userItem(item,bloc,context) {
    final date = DateFormat('MMM d hh:mm a');
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 5.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: CircleAvatar(
              radius: 13.0,
              backgroundImage: NetworkImage(bloc.userData['image']),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                    0.0,
                  ),
                  bottomRight: Radius.circular(
                    15.0,
                  ),
                  topLeft: Radius.circular(
                    15.0,
                  ),
                  topRight: Radius.circular(
                    15.0,
                  ),
                ),
              ),
              child: item['last_path'] != 'notfound'
                  ? InkWell(
                      onLongPress: () {
                        showDialog(
                            imageUrl: item['message'], path: item['last_path'],context: context,bloc: bloc);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 220,
                            width: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(item['message']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(
                            date.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  item['last_messageTime']),
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${item['message']}',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5.0,),
                          Text(
                            date.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  item['last_messageTime']),
                            ),
                            style:
                                TextStyle(color: Colors.white, fontSize: 8),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget myItem(item,bloc,context) {
    final date = DateFormat('MMM d hh:mm a');
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 5.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        //crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                    15.0,
                  ),
                  bottomRight: Radius.circular(
                    0.0,
                  ),
                  topLeft: Radius.circular(
                    15.0,
                  ),
                  topRight: Radius.circular(
                    15.0,
                  ),
                ),
              ),
              // padding: EdgeInsets.all(
              //   10.0,
              // ),
              child: item['last_path'] != 'notfound'
                  ? InkWell(
                      onLongPress: () {
                        showDialog(
                            imageUrl: item['message'], path: item['last_path'],context: context,bloc: bloc);
                        // showPopupMenu(Offset(MediaQuery.of(context).size.width +50,MediaQuery.of(context).size.height -150));
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 220,
                            width: 200,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(item['message']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(
                            date.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  item['last_messageTime']),
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Text(
                            '${item['message']}',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5.0,),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                size: 15.0,
                                color: bloc.userData['chattingWith'] == FirebaseAuth.instance.currentUser.uid
                                    ? Colors.blue
                                    : Colors.white,
                              ),
                              Text(
                                date.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      item['last_messageTime']),
                                ),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 8.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 35),
            child: CircleAvatar(
              radius: 13.0,
              backgroundImage: NetworkImage(bloc.myData['image']),
            ),
          ),
        ],
      ),
    );
  }

  // showPopupMenu(Offset offset) async {
  //   double left = offset.dx;
  //   double top = offset.dy;
  //   await showMenu(
  //     context: context,
  //     position: RelativeRect.fromLTRB(left, top, 0, 0),
  //     items: [
  //       PopupMenuItem(
  //         child: Text("View"),
  //       ),
  //     ],
  //     elevation: 8.0,
  //   );
  // }

  void showDialog({imageUrl, path,context,bloc}) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 80,
            width: 150,
            child: SizedBox.expand(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20)),
                child: FlatButton(
                  onPressed: () {
                    bloc.saveImage(imageUri: imageUrl, path: path);
                    Navigator.pop(context);
                    Fluttertoast.showToast(msg: 'Image Downloaded');
                  },
                  child: Text('Save'),
                ),
              ),
            ),
            margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }
  // void updateMessagesSeen() async{
  //   CollectionReference ref =  FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(FirebaseAuth.instance.currentUser.uid)
  //       .collection('chats')
  //       .doc(widget.userId)
  //       .collection('messages');
  //   QuerySnapshot messages = await ref.get();
  //   messages.docs.forEach((element) {
  //     //messages = element.data();
  //       element.reference.update({
  //         'seen': 'true',
  //       });
  //   });
  // }
  // void requestPersmission() async {
  //   var status = await Permission.storage.status;
  //   if (status.isUndetermined) {
  //     // You can request multiple permissions at once.
  //     Map<Permission, PermissionStatus> statuses = await [
  //       Permission.storage,
  //       Permission.camera,
  //     ].request();
  //     print(statuses[
  //     Permission.storage]); // it should print PermissionStatus.granted
  //   }
  // }

}
