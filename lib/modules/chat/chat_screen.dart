import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:softagi_chat/modules/chat/bloc/chat_screen_cubit.dart';
import 'package:softagi_chat/modules/chat/bloc/chat_screen_states.dart';
import 'package:softagi_chat/modules/home/home_screen.dart';
import 'package:softagi_chat/modules/playAudio.dart';
import 'package:softagi_chat/shared/Prefrences.dart';
import 'package:softagi_chat/shared/components.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatelessWidget {
  var messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    PopupMenu.context = context;
    return BlocProvider(
      create: (context) => ChatScreenCubit()
        ..getUserId()
        ..getRealTimeUserData()
        ..getRealTimeMyData()
        ..firebaseMessage()
        ..scroll(context),
      child: BlocConsumer<ChatScreenCubit, ChatScreenStates>(
        listener: (ctx, state) {},
        builder: (ctx, state) {
          var bloc = ChatScreenCubit.get(ctx);
          return WillPopScope(
            // ignore: missing_return
            onWillPop: () async {
              bloc.updateStatus('online');
              bloc.scrollController.dispose();
              bloc.updateChattingWith('');
              saveUserItemId('');
              await AudioPlayer().release();
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
                    onPressed: () {
                      launch(('tel://${bloc.userData['phone'].toString()}'));
                    },
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
                            controller: bloc.scrollController,
                            itemBuilder: (context, index) {
                              if (bloc.messagesList[index]['id'] ==
                                  FirebaseAuth.instance.currentUser.uid)
                                return myItem(
                                    bloc.messagesList[index], bloc, context);
                              else
                                return userItem(
                                    bloc.messagesList[index], bloc, context);
                            },
                            itemCount: bloc.messagesList.length,
                          ),
                        if (bloc.isLoading == true)
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(5),
                            color: Colors.green,
                            child: bloc.messagesList.length == 0
                                ? Text(
                                    'Start chat Say Hi..!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    'Loading...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        if (bloc.sendingImage == true)
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(5),
                              color: Colors.red,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //Expanded(child: LinearProgressIndicator()),
                                  Text(
                                    'Sending Image  ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                      width: 100,
                                      child: LinearProgressIndicator()),
                                ],
                              )),
                        if (bloc.sendingVoice == true)
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(5),
                              color: Colors.red,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //Expanded(child: LinearProgressIndicator()),
                                  Text(
                                    'Sending Voice  ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                      width: 100,
                                      child: LinearProgressIndicator()),
                                ],
                              )),
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
                                        if (bloc.myData['action'] !=
                                            'typing...')
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
                                  child: Icon(Icons.image),
                                ),
                                SizedBox(
                                  width: 3.0,
                                ),
                                if (bloc.startRec)
                                  InkWell(
                                    onTap: () {
                                      bloc.cancelRecord();
                                    },
                                    child: Icon(Icons.clear),
                                  ),
                                SizedBox(
                                  width: 3.0,
                                ),
                                InkWell(
                                  onTap: () async {
                                    bloc.startRecording();
                                  },
                                  child: bloc.startRec
                                      ? Icon(Icons.stop)
                                      : Icon(Icons.mic),
                                ),
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

  Widget userItem(item, bloc, context) {
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
              child: item['type'] == 'image'
                  ? GestureDetector(
                onTap: (){
                  viewPhoto(item['message'],context);
                },
                onLongPressStart: (LongPressStartDetails details) {
                        imagePopUP(
                            bloc: bloc,
                            context: context,
                            imageUrl: item['message'],
                            path: item['last_path'],
                            offset: details.globalPosition,
                            item: item);
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
                          if (item['type'] == 'text')
                            GestureDetector(
                              onTapUp: (TapUpDetails details) {
                                // messagePopUP(context, details.globalPosition,
                                //     bloc, item);
                              },
                              child: Text(
                                '${item['message']}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          if (item['type'] == 'audio')
                            GestureDetector(
                              onTapUp: (TapUpDetails details) {
                                audioPopUP(context, details.globalPosition,
                                    bloc, item);
                              },
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            date.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  item['last_messageTime']),
                            ),
                            style: TextStyle(color: Colors.white, fontSize: 8),
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

  Widget myItem(item, bloc, context) {
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
              child: item['type'] == 'image'
                  ? GestureDetector(
                onTap: (){
                  viewPhoto(item['message'],context);
                },
                onLongPressStart: (LongPressStartDetails details) {
                        // showImageDialog(
                        //     imageUrl: item['message'],
                        //     path: item['last_path'],
                        //     context: context,
                        //     bloc: bloc);
                        imagePopUP(
                            bloc: bloc,
                            context: context,
                            imageUrl: item['message'],
                            path: item['last_path'],
                            offset: details.globalPosition,
                            item: item);
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
                          if (item['type'] == 'text')
                            GestureDetector(
                              onTapUp: (TapUpDetails details) {
                                //showPopup(details.globalPosition);
                                messagePopUP(context, details.globalPosition,
                                    bloc, item);
                              },
                              child: Text(
                                '${item['message']}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          if (item['type'] == 'audio')
                            GestureDetector(
                              onTapUp: (TapUpDetails details) {
                                audioPopUP(context, details.globalPosition,
                                    bloc, item);
                              },
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                size: 15.0,
                                color: item['seen'] == 'true'
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

  void messagePopUP(context, Offset offset, bloc, item) async {
    var date = DateFormat("HH:mm");
    var one = date
        .format(DateTime.fromMillisecondsSinceEpoch(item['last_messageTime']));
    var two = date.format(DateTime.now());
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem(
          child: InkWell(
              onTap: () {
                bloc.deleteMessage(item['docID']);
                Navigator.pop(context);
              },
              child: Text("Delete")),
        ),
        // PopupMenuItem(
        //   child: InkWell(
        //       onTap: () {
        //         //bloc.deleteMessage(item['docID']);
        //         Navigator.pop(context);
        //       },
        //       child: Text("Delete For All")),
        // ),
        PopupMenuItem(
          child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text("Cancel")),
        ),
      ],
      elevation: 8.0,
    );
  }

  void audioPopUP(context, Offset offset, bloc, item) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: item['id'] == FirebaseAuth.instance.currentUser.uid
          ? RelativeRect.fromLTRB(left, top, 50, 0)
          : RelativeRect.fromLTRB(50, top, left, 0),
      items: [
        PopupMenuItem(
          child: InkWell(
              onTap: () {
                audioDialog(
                    audioUrl: item['message'], context: context, bloc: bloc);
              },
              child: Text('Play')),
        ),
        if (item['id'] == FirebaseAuth.instance.currentUser.uid)
          PopupMenuItem(
            child: InkWell(
                onTap: () {
                  bloc.deleteMessage(item['docID']);
                  Navigator.pop(context);
                },
                child: Text("Delete")),
          ),
        PopupMenuItem(
          child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text('Cancel')),
        ),
      ],
      elevation: 8.0,
    );
  }

  void imagePopUP({context, Offset offset, bloc, imageUrl, path, item}) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: item['id'] == FirebaseAuth.instance.currentUser.uid
          ? RelativeRect.fromLTRB(left, top, 50, 0)
          : RelativeRect.fromLTRB(50, top, left, 0),
      items: [
        PopupMenuItem(
          child: InkWell(
              onTap: () {
                bloc.saveImage(imageUri: imageUrl, path: path);
                Navigator.pop(context);
                Fluttertoast.showToast(msg: 'Image Downloaded');
              },
              child: Text("Save to gallery")),
        ),
        if (item['id'] == FirebaseAuth.instance.currentUser.uid)
          PopupMenuItem(
            child: InkWell(
                onTap: () {
                  bloc.deleteMessage(item['docID']);
                  Navigator.pop(context);
                },
                child: Text("Delete")),
          ),
        PopupMenuItem(
          child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text("Cancel")),
        ),
      ],
      elevation: 8.0,
    );
  }
 viewPhoto(String photo,context){
  print('done');
  return showDialog(context: context, builder: (context){
    return Container(child: PhotoView(
      imageProvider: NetworkImage(photo),
      backgroundDecoration: BoxDecoration(color: Colors.black),
      gaplessPlayback: false,
      enableRotation: true,
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 1.8,
      initialScale: PhotoViewComputedScale.contained,
      basePosition: Alignment.center,
    ),);
  });

}
  void showImageDialog({imageUrl, path, context, bloc}) {
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
                child: TextButton(
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

  void audioDialog({
    audioUrl,
    context,
    bloc,
  }) {
    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (_, __, ___) {
        return AudioPlay(audioUrl);
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
          child: child,
        );
      },
    );
  }
}
