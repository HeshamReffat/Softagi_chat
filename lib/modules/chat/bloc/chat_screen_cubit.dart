import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:softagi_chat/modules/chat/bloc/chat_screen_states.dart';
import 'package:softagi_chat/shared/Prefrences.dart';
import 'package:audio_recorder/audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:file/local.dart';

class ChatScreenCubit extends Cubit<ChatScreenStates> {
  ChatScreenCubit({localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem(),
        super(ChatScreenInit());

  LocalFileSystem localFileSystem;
  String userId;
  Map userData = {};
  Map myData = {};
  Map checkChat = {};
  bool startRec = false;
  int docLimit = 12;
  Recording recording = Recording();
  bool _isRecording = false;
  AudioPlayer player = AudioPlayer();
  TextEditingController _controller = new TextEditingController();
  ScrollController scrollController = ScrollController();
  File image;
  int newMessage = 0;
  List<DocumentSnapshot> messagesList = [];
  List<DocumentSnapshot> messagesList2 = [];
  DocumentSnapshot lastMessage;
  bool remainingMessage = true;
  bool isLoading = false;

  static ChatScreenCubit get(context) => BlocProvider.of(context);

  void getRealTimeMyData() {
    //emit(ChatScreenLoading());
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((event) {
      myData = event.data();
      getMessages();
      //getUserId();
      emit(ChatScreenMyData());
    });
  }

  final headers = {
    'content-type': 'application/json',
    'Authorization':
        'key=AAAA-8Jrl9M:APA91bE7LFuH7CrmHqy-NRZUeVEsA1ni5j0pZABnWBKqVT7ODgiIGRrsddXLBJojbl6rjqtFNtgPRV5_7Vuoo51yprLpgFR49lwo14GqyzgLDyBXf5lzySIhgcKKQ9KZElqdZm-4EFkj'
  };

  // var data = {
  //   "to":
  //       "fzPYdStpRc-l6vhEh5ZQnl:APA91bFDP9uuJQ2XoYHxto4tRL3B12vGTLkKruCQ3ylBzSp7Pq8IsJPFD7iJGkIfzBggwtYTwTMKW8To3JexWxtm9dRNRSGd4mCSo-ZV0v910bkoa7o__hEsmJMUENECOZKgNW_mDqh8",
  //   "notification": {
  //     "title": "message From",
  //     "body": "Hello From PostMan",
  //     "sound": "deafult"
  //   },
  //   "android": {
  //     "priority": "HIGH",
  //     "notification": {
  //       "notification_priority": "PRIORITY_MAX",
  //       "sound": "deafult",
  //       "default_sound": "true",
  //       "default_vibrate_timings": "true",
  //       "default_light_settings": "true"
  //     }
  //   }
  // };

  void sendNotification(String text, {String image}) async {
    Dio dio = Dio();
    dio.options.baseUrl = 'https://fcm.googleapis.com/';
    dio.options.headers = headers;
    await dio.post('fcm/send', data: {
      "to": "${userData['deviceToken']}",
      "notification": {
        "title": "${myData['first_name']} ${myData['last_name']}",
        "body": "$text",
        "image": '$image',
        "sound": "default",
      },
      "android": {
        "priority": "HIGH",
        "notification": {
          "notification_priority": "PRIORITY_MAX",
          "sound": "default",
          "default_sound": true,
          "default_vibrate_timings": true,
          "default_light_settings": true
        }
      }
    });
    emit(ChatScreenMessageNotification());
  }

  void firebaseMessage() {
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    fbm.configure(onMessage: (msg) {
      print('$msg this is it');
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
    emit(ChatScreenMessage());
  }

  void getRealTimeUserData() {
    //emit(ChatScreenLoading());
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((event) {
      userData = event.data();
      emit(ChatScreenUserData());
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

  saveImage({imageUri, path}) async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      var response = await Dio()
          .get(imageUri, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 80,
          name: path);
      print(response);
      print(result);
      emit(SaveImage());
    }
  }

  void updateStatus(String status) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({
      'action': status,
    }).then((value) {
      emit(ChatScreenUpdateAction());
      print('status updated');
    }).catchError((error) {
      print(error.toString());
    });
  }

  void updateCounter() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('chats')
        .doc(userData['id'])
        .update({
      'newMessage': 0,
    }).then((value) {
      print('Counter updated');
      emit(ChatScreenUpdateCounter()); //
    });
  }

  void chatCreated() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('chats')
        .doc(userId)
        .get()
        .then((value) {
      checkChat = value.data();
      if (value.exists &&
          checkChat['newMessage'] != 0 &&
          myData['chattingWith'] == userId) updateCounter();
      //emit(ChatScreenCheckChats());
    });
  }

  void updateLastMessage(lMessage) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('chats')
        .doc(userData['id'])
        .update({
      'last_message': lMessage,
      'lmessage_time': DateTime.now().millisecondsSinceEpoch,
      'chatCreated': 'true',
      //'counter': counter,
    }).then((value) {
      //emit(UpdateMyLastMessage());
      FirebaseFirestore.instance
          .collection('users')
          .doc(userData['id'])
          .collection('chats')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({
        'last_message': lMessage,
        'lmessage_time': DateTime.now().millisecondsSinceEpoch,
        // 'newMessage': newMessage,
        'chatCreated': 'true',
      }).then((value) {
        if (userData['chattingWith'] == FirebaseAuth.instance.currentUser.uid) {
          setNewMessage(0);
        } else {
          setNewMessage(newMessage);
        }
        if (userData['chattingWith'] == FirebaseAuth.instance.currentUser.uid)
          messagesList.forEach((msg) {
            if (msg['seen'] == 'false')
              msg.reference.update({
                'seen': 'true',
              });
          });
        print(newMessage);
        //emit(UpdateUserLastMessage());
      });
    });
  }

  void setNewMessage(message) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userData['id'])
        .collection('chats')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({
      'newMessage': message,
    });
  }

  uploadAudioFile(File audio) {
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('users/${Uri.file(audio.path).pathSegments.last}')
        .putFile(audio)
        .onComplete
        .then((value) {
      value.ref.getDownloadURL().then((audioValue) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection('chats')
            .doc(userData['id'])
            .collection('messages')
            .add({
          'message': audioValue.toString(),
          'id': FirebaseAuth.instance.currentUser.uid,
          'time': Timestamp.now(),
          'last_messageTime': DateTime.now().millisecondsSinceEpoch,
          'last_path': Uri.file(audio.path).pathSegments.last,
          'type': 'audio',
          'seen': 'false',
        }).then((value) {
          print('my Audio');
          FirebaseFirestore.instance
              .collection('users')
              .doc(userData['id'])
              .collection('chats')
              .doc(FirebaseAuth.instance.currentUser.uid)
              .collection('messages')
              .add({
            'message': audioValue.toString(),
            'id': FirebaseAuth.instance.currentUser.uid,
            'time': Timestamp.now(),
            'last_messageTime': DateTime.now().millisecondsSinceEpoch,
            'last_path': Uri.file(audio.path).pathSegments.last,
            'type': 'audio',
            'seen': 'false',
          }).then((value) {
            updateLastMessage('Audio');
            if (userData['chattingWith'] ==
                FirebaseAuth.instance.currentUser.uid) {
              newMessage = 0;
            } else {
              newMessage++;
            }
            print('user Audio');
            emit(AudioUploadSuccess());
          }).catchError((error) {
            print(error.toString());
          });
        }).catchError((error) {
          print(error.toString());
        });
      });
    });
  }

  changeStartRec() {
    startRec = !startRec;
    emit(ChangeStartRec());
  }

  void startRecording() async {
    if (startRec == false) {
      await Permission.storage.request();
      await Permission.microphone.request();
      try {
        if (await AudioRecorder.hasPermissions) {
          if (_controller.text != null && _controller.text != "") {
            String path = _controller.text;
            if (!_controller.text.contains('/')) {
              io.Directory appDocDirectory =
                  await getApplicationDocumentsDirectory();
              path = appDocDirectory.path + '/' + _controller.text;
            }
            print("Start recording: $path");
            await AudioRecorder.start(
                path: path, audioOutputFormat: AudioOutputFormat.AAC);
          } else {
            await AudioRecorder.start();
          }
          bool isRecording = await AudioRecorder.isRecording;
          recording = new Recording(duration: new Duration(), path: "");
          _isRecording = isRecording;
          changeStartRec();
          emit(AudioRecSuccess());
        } else {
          Fluttertoast.showToast(msg: "You must accept permissions");
        }
      } catch (e) {
        print(e);
      }
    } else {
      var recording = await AudioRecorder.stop();
      print("Stop recording: ${recording.path}");
      bool isRecording = await AudioRecorder.isRecording;
      File file = localFileSystem.file(recording.path);

      uploadAudioFile(file);

      print("  File length: ${await file.length()}");
      recording = recording;
      _isRecording = isRecording;
      changeStartRec();
      emit(AudioRecFinish());
      _controller.text = recording.path;
      if (startRec == false) {
        _controller.clear();
      }
    }
  }

  void cancelRecord() async {
    var recording = await AudioRecorder.stop();
    print("Stop recording: ${recording.path}");
    bool isRecording = await AudioRecorder.isRecording;
    File file = localFileSystem.file(recording.path);

    //uploadAudioFile(file);

    print("  File length: ${await file.length()}");
    recording = recording;
    _isRecording = isRecording;
    changeStartRec();
    emit(AudioRecFinish());
    _controller.text = recording.path;
    if (startRec == false) {
      _controller.clear();
    }
  }
  void deleteMessage(id){
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('chats')
        .doc(userData['id'])
        .collection('messages').doc(id).delete();
  }

  void sendMessage(String message) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('chats')
        .doc(userData['id'])
        .collection('messages')
        .add({
      'message': message,
      'id': FirebaseAuth.instance.currentUser.uid,
      'time': Timestamp.now(),
      'last_messageTime': DateTime.now().millisecondsSinceEpoch,
      'last_path': 'notfound',
      'docID':'',
      'seen': 'false',
      'type': 'text',
    }).then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('chats')
          .doc(userData['id'])
          .collection('messages')
          .doc(value.id).update({'docID':value.id});
      if (userData['chattingWith'] == FirebaseAuth.instance.currentUser.uid) {
        newMessage = 0;
      } else {
        newMessage++;
      }
      //emit(SendMyMessage());
      print('my messages');
      FirebaseFirestore.instance
          .collection('users')
          .doc(userData['id'])
          .collection('chats')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('messages')
          .add({
        'message': message,
        'id': FirebaseAuth.instance.currentUser.uid,
        // Change message time stamp
        'docID':'',
        'time': Timestamp.now(),
        'last_messageTime': DateTime.now().millisecondsSinceEpoch,
        'last_path': 'notfound',
        'seen': 'false',
        'type': 'text',
      }).then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userData['id'])
            .collection('chats')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection('messages')
            .doc(value.id).update({'docID':value.id});
        updateLastMessage(message);
        //messagesList2.clear();
        remainingMessage = true;
        emit(SendUserMessage());
        print('usermessages');
      }).catchError((error) {
        print(error.toString());
      });
    }).catchError((error) {
      print(error.toString());
    });
  }

  getMessages() {
    if (messagesList.length > 0) {
      isLoading = false;
    } else {
      isLoading = true;
    }
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('chats')
        .doc(userData['id'])
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(docLimit)
        .snapshots()
        .listen((event) {
      //print('list =====> ${event.docs.length}');
      chatCreated();
      messagesList = event.docs;
      if (messagesList.length > 0) {
        lastMessage = messagesList[messagesList.length - 1];
        isLoading = false;
      }
      emit(GetMessages());
      // if (userData['chattingWith'] == FirebaseAuth.instance.currentUser.uid)
      //   messagesList.forEach((msg) {
      //     if (msg['seen'] == 'false')
      //       msg.reference.update({
      //         'seen': 'true',
      //       });
      //   });
      // updateMessagesSeen();
      //print(messagesList.first['time']);
      //newMessage = 0;
      //print(image.path);
    });
  }



  void scroll(context) {
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        getMoreMessages();
        emit(ScrollListen());
      }
    });
  }

  getMoreMessages() async {
    print('more messages');
    if (remainingMessage) {
      isLoading = true;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection('chats')
          .doc(userData['id'])
          .collection('messages')
          .orderBy('time', descending: true)
          .startAfterDocument(lastMessage)
          .limit(docLimit)
          .get()
          .then((event) {
        messagesList2 = event.docs;
        //print('list =====> ${event.docs.length}');
        lastMessage = messagesList2.last;
        messagesList.addAll(messagesList2);
        if (messagesList2.length < docLimit) {
          remainingMessage = false;
        }
        isLoading = false;
        emit(GetMoreMessages());
        if (userData['chattingWith'] == FirebaseAuth.instance.currentUser.uid)
          messagesList.forEach((msg) {
            if (msg['seen'] == 'false')
              msg.reference.update({
                'seen': 'true',
              });
          });
        // updateMessagesSeen();
        //print(messagesList.first['time']);
        //newMessage = 0;
        //print(image.path);
      });
    } else {
      print('noMore');
      Fluttertoast.showToast(msg: 'No more Messages');
    }
  }

  void updateInfoChat() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('chats')
        .doc(userId)
        .update({
      'first_name': userData['first_name'],
      'last_name': userData['last_name'],
      'image': userData['image'],
      'status': userData['status'],
      'last_path': userData['last_path'],
      'action': userData['action'],
    }).then((value) {
      print('my Data updated');
      //emit(UpdateMyInfoChat());
      FirebaseFirestore.instance
          .collection('users')
          .doc(userData['id'])
          .collection('chats')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({
        'first_name': myData['first_name'],
        'last_name': myData['last_name'],
        'image': myData['image'],
        'status': myData['status'],
        'last_path': myData['last_path'],
        'action': myData['action'],
      }).then((value) {
        print('user data Updated');
        emit(UpdateUserInfoChat());
      }).catchError((error) {
        print(error.toString());
      });
    }).catchError((error) {
      print(error.toString());
    });
  }

  void createChat() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('chats')
        .doc(userData['id'])
        .set(userData)
        .then((value) {
      print('my chat created');
      //emit(CreateMyChat());
      FirebaseFirestore.instance
          .collection('users')
          .doc(userData['id'])
          .collection('chats')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set(myData)
          .then((value) {
        print('user chat created');
        emit(CreateUserChat());
      }).catchError((error) {
        print(error.toString());
      });
    }).catchError((error) {
      print(error.toString());
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

  void uploadImage() {
    firebase_storage.FirebaseStorage.instance
        .ref()
        .child('chatImages/${Uri.file(image.path).pathSegments.last}')
        .putFile(image)
        .onComplete
        .then((value) {
      value.ref.getDownloadURL().then((imageValue) {
        sendNotification('Photo', image: imageValue.toString());
        FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .collection('chats')
            .doc(userData['id'])
            .collection('messages')
            .add({
          'message': imageValue.toString(),
          'id': FirebaseAuth.instance.currentUser.uid,
          'time': Timestamp.now(),
          'last_messageTime': DateTime.now().millisecondsSinceEpoch,
          'last_path': Uri.file(image.path).pathSegments.last,
          'type': 'image',
          'seen': 'false',
        }).then((value) {
          print('my image');
          FirebaseFirestore.instance
              .collection('users')
              .doc(userData['id'])
              .collection('chats')
              .doc(FirebaseAuth.instance.currentUser.uid)
              .collection('messages')
              .add({
            'message': imageValue.toString(),
            'id': FirebaseAuth.instance.currentUser.uid,
            'time': Timestamp.now(),
            'last_messageTime': DateTime.now().millisecondsSinceEpoch,
            'last_path': Uri.file(image.path).pathSegments.last,
            'type': 'image',
            'seen': 'false',
          }).then((value) {
            updateLastMessage('Photo');
            if (userData['chattingWith'] ==
                FirebaseAuth.instance.currentUser.uid) {
              newMessage = 0;
            } else {
              newMessage++;
            }
            print('userimage');
            emit(ImageUploadSuccess());
          }).catchError((error) {
            print(error.toString());
          });
        }).catchError((error) {
          print(error.toString());
        });
      });
    });
  }

  void getUserId() {
    userId = getUserItemId();
    emit(GetUserId());
  }
}
