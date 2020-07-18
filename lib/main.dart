import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/Music.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rimkus Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Rimkus Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Music> _musics = [
    new Music('First Music', 'Rimkus', 'assets/un.jpg',
        'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    new Music('First Music', 'Rimkus', 'assets/deux.jpg',
        'https://codabee.com/wp-content/uploads/2018/06/deux.mp3')
  ];
  Music _playedMusique;
  Duration _position = new Duration(seconds: 0);
  Duration duration = new Duration(seconds: 0);
  AudioPlayer _audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSub;
  PlayerState statut = PlayerState.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _playedMusique = _musics[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: new Image.asset(_playedMusique.imagePath),
              ),
            ),
            textStyle(_playedMusique.title, 1.5),
            textStyle(_playedMusique.artiste, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                musicButton(Icons.fast_rewind, 30.0, MusicAction.rewind),
                musicButton(
                    (statut == PlayerState.playing)
                        ? Icons.pause
                        : Icons.play_arrow,
                    45.0,
                    (statut == PlayerState.playing)
                        ? MusicAction.pause
                        : MusicAction.play),
                musicButton(Icons.fast_forward, 30.0, MusicAction.forward),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                textStyle(fromDuration(_position), 0.8),
                textStyle(fromDuration(duration), 0.8),
              ],
            ),
            new Slider(
                value: _position.inSeconds.toDouble(),
                min: 0.0,
                max: 22.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d) {
                  setState(() {
                    _audioPlayer.seek(d);
                  });
                })
          ],
        ),
      ),
    );
  }

  IconButton musicButton(IconData icon, double size, MusicAction action) {
    return new IconButton(
      icon: new Icon(icon),
      iconSize: size,
      color: Colors.white,
      onPressed: () {
        switch (action) {
          case MusicAction.play:
            play();
            break;
          case MusicAction.pause:
            pause();
            break;
          case MusicAction.rewind:
            rewind();
            break;
          case MusicAction.forward:
            forward();
            break;
        }
      },
    );
  }

  Text textStyle(String str, double scale) {
    return new Text(
      str,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
          color: Colors.white, fontSize: 20.0, fontStyle: FontStyle.italic),
    );
  }

  void configurationAudioPlayer() {
    _audioPlayer = new AudioPlayer();
    positionSub = _audioPlayer.onAudioPositionChanged.listen((pos) => {
          setState(() => {_position = pos})
        });
    stateSub = _audioPlayer.onPlayerStateChanged.listen((event) {
      print(event);
      if (event == AudioPlayerState.PLAYING) {
        setState(() {
          duration = _audioPlayer.duration;
        });
      } else if (event == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.stopped;
        });
      }
      else if (event == AudioPlayerState.COMPLETED){
        forward();
      }
    }, onError: (message) {
      print('erreur $message');
      setState(() {
        statut = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        _position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await _audioPlayer.play(_playedMusique.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await _audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  Future forward() {
    if (index == _musics.length - 1) {
      index = -1;
    }
    index++;
    _audioPlayer.stop();
    _playedMusique = _musics[index];
    configurationAudioPlayer();
    play();
  }

  Future rewind() {
    if (_position > Duration(seconds: 1)) {
      _audioPlayer.seek(0.0);
    } else {
      if (index == 0) {
        index = _musics.length;
      }
      index--;
      _audioPlayer.stop();
      _playedMusique = _musics[index];
      configurationAudioPlayer();
      play();
    }
  }

  String fromDuration(Duration duree) {
    return duree.toString().split('.').first;
  }
}

enum MusicAction { play, pause, rewind, forward }

enum PlayerState { playing, stopped, paused }
