import 'package:flutter/material.dart';

import 'global.dart';
import 'ui/smoothDialog.dart';
import 'util/engineManager.dart';
import 'util/errCodeToMessage.dart';

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
              var status = errCodeToMessage(snapshot.data[1]);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (snapshot.data[1] == "ERR_TIDY_ENGINE_NOT_EXIST") {
                  createSmoothDialog(
                    context,
                    "엔진을 찾을 수 없습니다.",
                    "Tidy 구동에 필요한 엔진이 발견되지 않았습니다.\n최신 버전을 자동으로 다운로드 받을까요?",
                    <Widget>[
                      new TextButton(
                        child: new Text("취소"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      new TextButton(
                        child: new Text("확인"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                    Icon(Icons.warning),
                    false,
                  );
                }
              });
              return Text(errCodeToMessage(snapshot.data[1]));
            } else if (snapshot.hasError) {
              return Text("Tidy 상태를 가져오는데 실패하였습니다.");
            } else {
              return Text("Tidy 상태를 가져오는중...");
            }
          },
        ),
      ],
    );
  }
}
