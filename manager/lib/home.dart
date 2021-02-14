import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tidy_manager/ui/authDialog.dart';
import 'package:tidy_manager/util/engineInstaller.dart';

import 'global.dart';
import 'ui/smoothDialog.dart';
import 'util/engineManager.dart';
import 'util/statusCodeToMessage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _sudoPasswordInputCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool _isPasswordRequired;
    if (Platform.isWindows) {
      _isPasswordRequired = false;
    } else {
      userPasswordForSudo == ""
          ? _isPasswordRequired = true
          : _isPasswordRequired = false;
    }
    if (_isPasswordRequired) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        authDialog(context, _sudoPasswordInputCtrl);
        isEngineServiceRunning = await isEngineRunning();
      });
      return Text("상태를 알아오기 전 사용자 인증 대기중...");
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FutureBuilder<List<dynamic>>(
            future: getEngineStatus(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) {
                    if (snapshot.data[1] == "ERR_TIDY_ENGINE_NOT_EXIST" &&
                        !engineInstalledChecked) {
                      isEngineServiceRunning =
                          snapshot.data[1] == "PROCESS_RUNNING";
                      createSmoothDialog(
                        context,
                        "엔진을 찾을 수 없습니다.",
                        Text(
                            "Tidy 구동에 필요한 엔진이 발견되지 않았습니다.\n최신 버전을 자동으로 다운로드 받을까요?"),
                        Row(
                          children: [
                            new TextButton(
                              child: new Text("취소"),
                              onPressed: () {
                                setState(() {
                                  engineInstalledChecked = true;
                                });
                                Navigator.pop(context);
                              },
                            ),
                            new TextButton(
                              child: new Text("확인"),
                              onPressed: () async {
                                engineInstalledChecked = true;
                                reCheckRequired = true;
                                installingEngine = true;
                                Navigator.pop(context);
                                return await engineInstaller(context);
                              },
                            ),
                          ],
                        ),
                        Icon(Icons.warning),
                        false,
                      );
                    }
                  },
                );
                return Column(
                  children: [
                    FloatingActionButton(
                      heroTag: "homeStartStopFAB",
                      onPressed: snapshot.data[1] == "ERR_TIDY_ENGINE_NOT_EXIST"
                          ? () async {
                              createSmoothDialog(
                                context,
                                "엔진을 찾을 수 없습니다.",
                                Text(
                                    "Tidy 구동에 필요한 엔진이 발견되지 않았습니다.\n최신 버전을 자동으로 다운로드 받을까요?"),
                                Row(
                                  children: [
                                    new TextButton(
                                      child: new Text("취소"),
                                      onPressed: () {
                                        setState(() {
                                          engineInstalledChecked = true;
                                        });
                                        Navigator.pop(context);
                                      },
                                    ),
                                    new TextButton(
                                      child: new Text("확인"),
                                      onPressed: () async {
                                        engineInstalledChecked = true;
                                        reCheckRequired = true;
                                        installingEngine = true;
                                        Navigator.pop(context);
                                        return await engineInstaller(context);
                                      },
                                    ),
                                  ],
                                ),
                                Icon(Icons.warning),
                                false,
                              );
                            }
                          : () async {
                              toggleEngineStatus();
                              setState(() {
                                isEngineServiceRunning =
                                    !isEngineServiceRunning;
                              });
                            },
                      child: snapshot.data[1] == "ERR_TIDY_ENGINE_NOT_EXIST"
                          ? Icon(Icons.warning)
                          : isEngineServiceRunning
                              ? Icon(Icons.stop)
                              : Icon(Icons.play_arrow),
                      tooltip: snapshot.data[1] == "ERR_TIDY_ENGINE_NOT_EXIST"
                          ? "엔진을 설치하려면 누르세요."
                          : isEngineServiceRunning
                              ? "정지하기"
                              : "실행하기",
                    ),
                    Divider(
                      thickness: 0,
                      color: new Color.fromRGBO(255, 255, 255, 0.0),
                    ),
                    Text(snapshot.data[1] == "PROCESS_RUNNING" ||
                            snapshot.data[1] == "PROCESS_STOPPED" ||
                            snapshot.data[1] ==
                                "PROCESS_STOPPED_OR_NOT_INSTALLED"
                        ? isEngineServiceRunning
                            ? statusCodeToMessage("PROCESS_RUNNING")
                            : statusCodeToMessage("PROCESS_STOPPED")
                        : statusCodeToMessage(snapshot.data[1])),
                  ],
                );
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
}
