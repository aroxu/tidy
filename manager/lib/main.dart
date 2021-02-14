import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:tidy_manager/global.dart';
import 'package:tidy_manager/home.dart';
import 'package:tidy_manager/ui/smoothDialog.dart';

import 'settings.dart';
import 'ui/animatedBackground.dart';
import 'ui/animatedWave.dart';

void main() {
  runApp(
    Tidy(),
  );
}

class Tidy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tidy Manager',
      theme: ThemeData.dark(),
      home: TidyMainPage(title: 'Tidy Manager'),
      debugShowCheckedModeBanner: false,
    );
  }
}

Widget onBottom(Widget child) => Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: child,
      ),
    );

class TidyMainPage extends StatefulWidget {
  TidyMainPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TidyMainPageState createState() => _TidyMainPageState();
}

class _TidyMainPageState extends State<TidyMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedBackground()),
          onBottom(
            AnimatedWave(
              height: 180,
              speed: 1.5,
            ),
          ),
          onBottom(
            AnimatedWave(
              height: 120,
              speed: 0.5,
              offset: pi,
            ),
          ),
          onBottom(
            AnimatedWave(
              height: 220,
              speed: 1.0,
              offset: pi / 2,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Phoenix(
                child: Home(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "homeSettingsFAB",
        elevation: 0,
        onPressed: () {
          if (installingEngine) {
            return createSmoothDialog(
              context,
              "사용할 수 없음",
              Text("엔진 설치중에는 설정을 열 수 없습니다."),
              Row(
                children: [
                  new TextButton(
                    child: new Text("확인"),
                    onPressed: () async {
                      return Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Icon(Icons.warning),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => Settings(),
              ),
            );
          }
        },
        tooltip: '설정',
        child: Icon(Icons.settings),
      ),
    );
  }
}
