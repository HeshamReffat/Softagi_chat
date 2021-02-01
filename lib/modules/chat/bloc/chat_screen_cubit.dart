import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:softagi_chat/modules/chat/bloc/chat_screen_states.dart';
import 'package:softagi_chat/shared/Prefrences.dart';

class ChatScreenCubit extends Cubit<ChatScreenStates> {
  ChatScreenCubit() : super(ChatScreenInit());
  String userId;
  Map userData = {};
  Map myData = {};
  Map checkChat = {};
  File image;
  int newMessage = 0;
  List messagesList = [];

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
        "sound": "default"
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
    fbm.requestNotificationPermissions(const IosNotificationSettings(sound: true));
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
      'seen': 'false',
    }).then((value) {
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
        'time': Timestamp.now(),
        'last_messageTime': DateTime.now().millisecondsSinceEpoch,
        'last_path': 'notfound',
        'seen': 'false',
      }).then((value) {
        updateLastMessage(message);
        emit(SendUserMessage());
        print('usermessages');
      }).catchError((error) {
        print(error.toString());
      });
    }).catchError((error) {
      print(error.toString());
    });
  }

  void getMessages() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('chats')
        .doc(userData['id'])
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((event) {
      //print('list =====> ${event.docs.length}');
      chatCreated();
      messagesList = event.docs;
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
          }).then((value) {
            updateLastMessage('Photo');
            if (userData['chattingWith'] ==
                FirebaseAuth.instance.currentUser.uid) {
              newMessage = 0;
            } else {
              newMessage++;
            }
            print('usermessages');
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
