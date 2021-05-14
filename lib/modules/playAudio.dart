import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlay extends StatefulWidget {
  var audio;

  AudioPlay(this.audio);

  @override
  _AudioPlayState createState() => _AudioPlayState();
}

class _AudioPlayState extends State<AudioPlay> {
  String currentTime = "00:00";
  String totalTime = "00:00";
  double sliderCurrentTime = 0.0;
  double sliderTotalTime = 0.0;
  AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _player.stop();
        isPlaying = false;
        Navigator.pop(context);
        setState(() {});
        return;
      },
      child:
         Card(
           color: Colors.transparent,
           child: Align(
            alignment: Alignment.center,
            child: Container(
              height: 80,
              width: double.infinity,
              child: SizedBox.expand(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        onPressed: () async {

                          _player.onAudioPositionChanged
                              .listen((Duration duration) {
                            setState(() {
                              currentTime = duration.toString().split(".")[0];
                              sliderCurrentTime =
                                  duration.inMilliseconds.toDouble();
                            });
                          });
                          _player.onDurationChanged.listen((Duration duration) {
                            setState(() {
                              totalTime = duration.toString().split(".")[0];
                              sliderTotalTime =
                                  duration.inMilliseconds.toDouble();
                            });
                          });
                           _player.onPlayerCompletion.listen((event) {
                            setState(() {
                              isPlaying = false;
                            });
                            Navigator.pop(context);
                          });
                          if (isPlaying == false) {
                            await _player.play(widget.audio);
                            //await _player.earpieceOrSpeakersToggle();

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
                      Column(
                        children: [
                          Slider(
                            min: 0,
                            max: sliderTotalTime,
                            value: sliderCurrentTime,
                            activeColor: Colors.white,
                            inactiveColor: Colors.grey,
                            onChanged: (value) {
                              _player.seek(Duration(milliseconds: value.floor()));
                              setState(() {});
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(currentTime.toString(),
                                  style: TextStyle(color: Colors.white)),
                              SizedBox(
                                width: 50,
                              ),
                              Text(totalTime.toString(),
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),

                      // Text(
                      //   currentTime.toString(),
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.w700,
                      //       color: Colors.white,
                      //       fontSize: 14.0),
                      // ),
                      // Text(
                      //   " | ",
                      //   style:
                      //   TextStyle(color: Colors.white, fontSize: 14.0),
                      // ),
                      // Text(
                      //   completeTime.toString(),
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.w300,
                      //       color: Colors.white,
                      //       fontSize: 14.0),
                      // ),
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
         ),
    );
  }
}
