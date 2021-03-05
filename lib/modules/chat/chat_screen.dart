import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:softagi_chat/modules/chat/bloc/chat_screen_cubit.dart';
import 'package:softagi_chat/modules/chat/bloc/chat_screen_states.dart';
import 'package:softagi_chat/modules/home/home_screen.dart';
import 'package:softagi_chat/shared/Prefrences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:softagi_chat/shared/components.dart';

class ChatScreen extends StatelessWidget {
  var messageController = TextEditingController();
  String currentTime = "00:00";
  String completeTime = "00:00";
  AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatScreenCubit()
        ..getUserId()
        ..getRealTimeUserData()
        ..getRealTimeMyData()
        ..firebaseMessage().. scroll(context),
      child: BlocConsumer<ChatScreenCubit, ChatScreenStates>(
        listener: (ctx, state) {},
        builder: (ctx, state) {
          var bloc = ChatScreenCubit.get(ctx);
          return WillPopScope(
            // ignore: missing_return
            onWillPop: () async {
              bloc.updateStatus('online');
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
                                InkWell(
                                  onTap: () async {
                                    // if (startRec == false) {
                                    //   await Permission.storage.request();
                                    //   await Permission.microphone.request();
                                    //   try {
                                    //     if (await AudioRecorder
                                    //         .hasPermissions) {
                                    //       if (_controller.text != null &&
                                    //           _controller.text != "") {
                                    //         String path = _controller.text;
                                    //         if (!_controller.text
                                    //             .contains('/')) {
                                    //           io.Directory appDocDirectory =
                                    //               await getApplicationDocumentsDirectory();
                                    //           path = appDocDirectory.path +
                                    //               '/' +
                                    //               _controller.text;
                                    //         }
                                    //         print("Start recording: $path");
                                    //         await AudioRecorder.start(
                                    //             path: path,
                                    //             audioOutputFormat:
                                    //                 AudioOutputFormat.AAC);
                                    //       } else {
                                    //         await AudioRecorder.start();
                                    //       }
                                    //       bool isRecording =
                                    //           await AudioRecorder.isRecording;
                                    //       setState(() {
                                    //         _recording = new Recording(
                                    //             duration: new Duration(),
                                    //             path: "");
                                    //         _isRecording = isRecording;
                                    //         startRec = true;
                                    //       });
                                    //     } else {
                                    //       Fluttertoast.showToast(
                                    //           msg:
                                    //               "You must accept permissions");
                                    //     }
                                    //   } catch (e) {
                                    //     print(e);
                                    //   }
                                    // } else {
                                    //   var recording =
                                    //       await AudioRecorder.stop();
                                    //   print(
                                    //       "Stop recording: ${recording.path}");
                                    //   bool isRecording =
                                    //       await AudioRecorder.isRecording;
                                    //   File file = widget.localFileSystem
                                    //       .file(recording.path);
                                    //
                                    //   bloc.uploadAudioFile(file);
                                    //
                                    //   print(
                                    //       "  File length: ${await file.length()}");
                                    //   setState(() {
                                    //     _recording = recording;
                                    //     _isRecording = isRecording;
                                    //     startRec = false;
                                    //   });
                                    //   _controller.text = recording.path;
                                    // }
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
              child: item['last_path'] != 'notfound'
                  ? InkWell(
                      onLongPress: () {
                        showImageDialog(
                            imageUrl: item['message'],
                            path: item['last_path'],
                            context: context,
                            bloc: bloc);
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
              child: item['last_path'] == 'image'
                  ? InkWell(
                      onLongPress: () {
                        showImageDialog(
                            imageUrl: item['message'],
                            path: item['last_path'],
                            context: context,
                            bloc: bloc);
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
                          if (item['last_path'] == 'notfound')
                            Text(
                              '${item['message']}',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          if (item['last_path'] == 'audio')
                            MaterialButton(
                              onPressed: () {
                                audioDialog(
                                    audioUrl: item['message'],
                                    context: context,
                                    bloc: bloc);
                              },
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
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
                                color: bloc.userData['chattingWith'] ==
                                        FirebaseAuth.instance.currentUser.uid
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
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async {
                await _player.stop();
                isPlaying = false;
                Navigator.pop(context);
                setState(() {});
                return;
              },
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  child: SizedBox.expand(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FlatButton(
                            onPressed: () async {
                              _player.onAudioPositionChanged
                                  .listen((Duration duration) {
                                setState(() {
                                  currentTime =
                                      duration.toString().split(".")[0];
                                });
                              });
                              _player.onDurationChanged
                                  .listen((Duration duration) {
                                setState(() {
                                  completeTime =
                                      duration.toString().split(".")[0];
                                });
                              });
                              if (isPlaying == false) {
                                await _player.play(audioUrl);

                                setState(() {
                                  isPlaying = true;
                                });
                              } else {
                                await _player.pause();

                                setState(() {
                                  isPlaying = false;
                                });
                              }
                            },
                            child: isPlaying
                                ? Icon(
                                    Icons.pause,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            currentTime,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 14.0),
                          ),
                          Text(
                            " | ",
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.0),
                          ),
                          Text(
                            completeTime,
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                fontSize: 14.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            );
          },
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
}
