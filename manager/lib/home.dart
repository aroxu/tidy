import 'package:flutter/material.dart';

import 'global.dart';
import 'util/engineManager.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FutureBuilder<List<dynamic>>(
          future: getEngineStatus(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data[1]);
            } else if (snapshot.hasError) {
              return Text("에러 일때 화면");
            } else {
              return Text("로딩 화면");
            }
          },
        ),
      ],
    );
  }
}
