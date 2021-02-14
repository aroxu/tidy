import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:tidy_manager/global.dart';
import 'package:tidy_manager/model/settingFolderModel.dart';
import 'package:tidy_manager/model/settingUserModel.dart';
import 'package:tidy_manager/userSetting.dart';
import 'package:tidy_manager/util/settingManager.dart';

import 'folderSetting.dart';
import 'ui/smoothDialog.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _settingsGeneralEnableAuth = false;
  int _settingsGeneralPort = 9096;
  String _settingsGeneralName = "";
  String _settingsGeneralJwtSecret = "";
  String _settingsGeneralStartOnBoot = "true";
  List<SettingUserModel> _settingsUser;
  List<SettingFolderModel> _settingsFolder;

  final _portConfigInputCtrl = TextEditingController();
  final _nameConfigInputCtrl = TextEditingController();
  final _jwtSecretKeyInputCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: new Icon(
            Icons.arrow_back,
          ),
          onPressed: () async {
            if (!settingsGeneralNameModified) {
              settingsGeneralName = _settingsGeneralName;
            }
            if (!settingsGeneralPortModified) {
              settingsGeneralPort = _settingsGeneralPort;
            }
            if (!settingsGeneralJwtSecretModified) {
              settingsGeneralJwtSecret = _settingsGeneralJwtSecret;
            }
            if (!settingsGeneralEnableAuthModified) {
              settingsGeneralEnableAuth = _settingsGeneralEnableAuth;
            }
            if (!settingsGeneralStartOnBootModified) {
              settingsGeneralStartOnBoot = _settingsGeneralStartOnBoot;
            }
            if (!settingsUserModified) {
              settingsUser = _settingsUser;
            }
            if (!settingsFolderModified) {
              settingsFolder = _settingsFolder;
            }

            if (settingsGeneralNameModified ||
                settingsGeneralPortModified ||
                settingsGeneralJwtSecretModified ||
                settingsGeneralEnableAuthModified ||
                settingsGeneralStartOnBootModified ||
                settingsUserModified ||
                settingsFolderModified) {
              _showSnackBar(
                context,
                Row(
                  children: [
                    Icon(
                      Icons.save,
                      color: Colors.black,
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text('설정 저장중...'),
                    ),
                  ],
                ),
                Duration(days: 365),
              );
              await saveSettings();
              _showSnackBar(
                context,
                Row(
                  children: [
                    Icon(
                      Icons.check,
                      color: Colors.black,
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text('설정이 저장되었습니다. 변경사항을 적용하려면 엔진을 재시작해주세요.'),
                    ),
                  ],
                ),
                Duration(seconds: 3),
              );
            }

            settingsGeneralNameModified = false;
            settingsGeneralPortModified = false;
            settingsGeneralJwtSecretModified = false;
            settingsGeneralEnableAuthModified = false;
            settingsGeneralStartOnBootModified = false;
            settingsUserModified = false;
            settingsFolderModified = false;
            return Navigator.of(context).pop();
          },
          tooltip: "뒤로가기",
        ),
        elevation: 0,
        title: Text("설정"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getSettings(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (snapshot.data[0] == "OS_NOT_SUPPORTED") {
                return createSmoothDialog(
                  context,
                  "미지원 OS",
                  Text("이 OS는 지원하지 않습니다."),
                  new TextButton(
                    child: new Text("확인"),
                    onPressed: () async {
                      Navigator.pop(context);
                      return SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                  ),
                  Icon(Icons.warning),
                  false,
                );
              } else if (snapshot.data[0] == "ERR_CONFIG_MISSING") {
                return createSmoothDialog(
                  context,
                  "설정을 읽을 수 없음",
                  Text(
                      "설정 파일의 일부 또는 전체를 읽을 수 없습니다. ${snapshot.data[1]} 폴더 아래의 tidy 폴더를 지우고 Manager를 다시 실행해주세요."),
                  new TextButton(
                    child: new Text("확인"),
                    onPressed: () async {
                      Navigator.pop(context);
                      return SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                  ),
                  Icon(Icons.warning),
                  false,
                );
              }
            });
            try {
              _settingsGeneralEnableAuth = snapshot.data[0].enableAuth;
              _settingsGeneralPort = snapshot.data[0].port;
              _settingsGeneralName = snapshot.data[0].name;
              _settingsGeneralJwtSecret = snapshot.data[0].jwtSecret;
              _settingsGeneralStartOnBoot = snapshot.data[3];
              // _settingsGeneralStartOnBoot = "NOT_SUPPORTED";

              _settingsUser = snapshot.data[1];
              _settingsFolder = snapshot.data[2];
            } catch (_) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error),
                    SizedBox(
                      height: 12,
                    ),
                    Text("Tidy 설정을 가져오는데 실패하였습니다.")
                  ],
                ),
              );
            }
            return Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(4),
                      child: Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        child: SettingsSection(
                          title: '일반',
                          tiles: [
                            SettingsTile.switchTile(
                              title: '인증 활성화',
                              subtitle: '내 Tidy 서버에 접속할때 인증을 요청하도록 합니다.',
                              subtitleMaxLines: 3,
                              leading: Icon(Icons.vpn_key),
                              switchValue: settingsGeneralEnableAuthModified
                                  ? settingsGeneralEnableAuth
                                  : _settingsGeneralEnableAuth,
                              onToggle: (bool value) {
                                setState(() {
                                  settingsGeneralEnableAuthModified = true;
                                  settingsGeneralEnableAuth = value;
                                });
                              },
                            ),
                            SettingsTile(
                              title: '포트 설정',
                              subtitle: '내 Tidy 서버에 접속 하도록 허가할 포트를 설정합니다.',
                              subtitleMaxLines: 3,
                              leading: Icon(Icons.login),
                              onPressed: (BuildContext context) {
                                _portConfigInputCtrl.text =
                                    settingsGeneralPortModified
                                        ? "$settingsGeneralPort"
                                        : "$_settingsGeneralPort";
                                createSmoothDialog(
                                  context,
                                  "포트 설정",
                                  TextFormField(
                                    maxLength: 5,
                                    obscureText: false,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]'))
                                    ],
                                    controller: _portConfigInputCtrl,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText:
                                          "1부터 65535 사이의 유효한 TCP 포트를 입력해주세요.",
                                      labelText:
                                          "내 Tidy 서버에 접속 하도록 허가할 포트를 설정합니다.",
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      new TextButton(
                                        child: new Text("확인"),
                                        onPressed: () async {
                                          if (_portConfigInputCtrl.text
                                                      .trim() ==
                                                  "" ||
                                              !(0 <
                                                      int.parse(
                                                          _portConfigInputCtrl
                                                              .text) &&
                                                  int.parse(_portConfigInputCtrl
                                                          .text) <=
                                                      65535)) {
                                            return createSmoothDialog(
                                                context,
                                                "포트 변경 실패",
                                                Text(
                                                    "1부터 65535 사이의 유효한 TCP 포트를 입력해주세요."),
                                                new TextButton(
                                                  child: new Text("확인"),
                                                  onPressed: () async {
                                                    return Navigator.pop(
                                                        context);
                                                  },
                                                ),
                                                Icon(Icons.login),
                                                false);
                                          } else {
                                            settingsGeneralPort = int.parse(
                                                _portConfigInputCtrl.text);
                                            settingsGeneralPortModified = true;
                                            return Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.login),
                                  false,
                                );
                              },
                            ),
                            SettingsTile(
                              title: '이름 설정',
                              subtitle:
                                  '내 Tidy 서버에 접속할때 방문자가 볼 이름을 설정합니다. 이 이름은 브라우저 탭 제목 및 로그인창에 표시됩니다.',
                              subtitleMaxLines: 3,
                              leading: Icon(Icons.label),
                              onPressed: (BuildContext context) {
                                _nameConfigInputCtrl.text =
                                    settingsGeneralNameModified
                                        ? "$settingsGeneralName"
                                        : "$_settingsGeneralName";
                                createSmoothDialog(
                                  context,
                                  "이름 설정",
                                  TextFormField(
                                    obscureText: false,
                                    controller: _nameConfigInputCtrl,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText:
                                          "이 이름은 브라우저 탭 제목 및 로그인창에 표시됩니다.",
                                      labelText:
                                          "내 Tidy 서버에 접속할때 방문자가 볼 이름을 설정합니다.",
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      new TextButton(
                                        child: new Text("확인"),
                                        onPressed: () async {
                                          if (_nameConfigInputCtrl.text
                                                  .trim() ==
                                              "") {
                                            return createSmoothDialog(
                                                context,
                                                "이름 변경 실패",
                                                Text("이름은 공백일 수 없습니다."),
                                                new TextButton(
                                                  child: new Text("확인"),
                                                  onPressed: () async {
                                                    return Navigator.pop(
                                                        context);
                                                  },
                                                ),
                                                Icon(Icons.login),
                                                false);
                                          } else {
                                            settingsGeneralName =
                                                _nameConfigInputCtrl.text;
                                            settingsGeneralNameModified = true;
                                            return Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.label),
                                  false,
                                );
                              },
                            ),
                            SettingsTile(
                              title: '암호화 키 설정',
                              subtitle:
                                  '사용자가 로그인 할때 사용할 로그인 키(JWT Secret)를 변경합니다. 단순하거나 유추하기 쉬운 암호는 권장하지 않습니다.',
                              subtitleMaxLines: 3,
                              leading: Icon(Icons.lock),
                              onPressed: (BuildContext context) {
                                _jwtSecretKeyInputCtrl.text =
                                    settingsGeneralJwtSecretModified
                                        ? "$settingsGeneralJwtSecret"
                                        : "$_settingsGeneralJwtSecret";
                                createSmoothDialog(
                                  context,
                                  "암호화 키 설정",
                                  TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(
                                          r'[\w\d\s!@#$%^&*()_+\-=\[\]{};:\\|,.<>\/?]*$')),
                                      FilteringTextInputFormatter.deny(' '),
                                    ],
                                    obscureText: false,
                                    controller: _jwtSecretKeyInputCtrl,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "단순하거나 유추하기 쉬운 암호는 권장하지 않습니다.",
                                      labelText:
                                          "사용자가 로그인 할때 사용할 로그인 키(JWT Secret)를 변경합니다.",
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      new TextButton(
                                        child: new Text("확인"),
                                        onPressed: () async {
                                          if (_jwtSecretKeyInputCtrl.text
                                                  .trim() ==
                                              "") {
                                            return createSmoothDialog(
                                                context,
                                                "암호화 키 변경 실패",
                                                Text("암호화 키는 공백일 수 없습니다."),
                                                new TextButton(
                                                  child: new Text("확인"),
                                                  onPressed: () async {
                                                    return Navigator.pop(
                                                        context);
                                                  },
                                                ),
                                                Icon(Icons.lock),
                                                false);
                                          } else if (_jwtSecretKeyInputCtrl.text
                                                  .trim()
                                                  .length <
                                              8) {
                                            return createSmoothDialog(
                                                context,
                                                "암호화 키 변경 실패",
                                                Text(
                                                    "암호화 키는 적어도 8자 이상이어야 합니다."),
                                                new TextButton(
                                                  child: new Text("확인"),
                                                  onPressed: () async {
                                                    return Navigator.pop(
                                                        context);
                                                  },
                                                ),
                                                Icon(Icons.lock),
                                                false);
                                          } else {
                                            settingsGeneralJwtSecret =
                                                _jwtSecretKeyInputCtrl.text;
                                            settingsGeneralJwtSecretModified =
                                                true;
                                            return Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.label),
                                  false,
                                );
                              },
                            ),
                            SettingsTile.switchTile(
                              enabled: settingsGeneralStartOnBootModified
                                  ? settingsGeneralStartOnBoot ==
                                          "NOT_SUPPORTED"
                                      ? false
                                      : true
                                  : _settingsGeneralStartOnBoot ==
                                          "NOT_SUPPORTED"
                                      ? false
                                      : true,
                              title: '시작할때 실행',
                              subtitle: settingsGeneralStartOnBootModified
                                  ? settingsGeneralStartOnBoot ==
                                          "NOT_SUPPORTED"
                                      ? '디바이스가 재시작 될때 자동으로 Tidy 엔진을 시작합니다. Manager는 시작되지 않습니다. 이 설정을 변경하려면 관리자 권한이 요구됩니다.\nLinux 운영체제에서는 명령어를 사용하여 수동으로 변경해주세요.'
                                      : '디바이스가 재시작 될때 자동으로 Tidy 엔진을 시작합니다. Manager는 시작되지 않습니다. 이 설정을 변경하려면 관리자 권한이 요구됩니다.'
                                  : _settingsGeneralStartOnBoot ==
                                          "NOT_SUPPORTED"
                                      ? '디바이스가 재시작 될때 자동으로 Tidy 엔진을 시작합니다. Manager는 시작되지 않습니다. 이 설정을 변경하려면 관리자 권한이 요구됩니다.\nLinux 운영체제에서는 명령어를 사용하여 수동으로 변경해주세요.'
                                      : '디바이스가 재시작 될때 자동으로 Tidy 엔진을 시작합니다. Manager는 시작되지 않습니다. 이 설정을 변경하려면 관리자 권한이 요구됩니다.',
                              subtitleMaxLines: 3,
                              leading: Icon(Icons.autorenew),
                              switchValue: settingsGeneralStartOnBootModified
                                  ? settingsGeneralStartOnBoot == "true"
                                      ? true
                                      : false
                                  : _settingsGeneralStartOnBoot == "true"
                                      ? true
                                      : false,
                              onToggle: (bool value) {
                                setState(() {
                                  settingsGeneralStartOnBootModified = true;
                                  settingsGeneralStartOnBoot = "$value";
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(4),
                      child: Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        child: SettingsSection(
                          title: '유저',
                          tiles: [
                            SettingsTile(
                              title: '유저 관리',
                              subtitle: '유저별로 그룹을 부여하거나 수정, 삭제 할 수 있습니다.',
                              subtitleMaxLines: 3,
                              leading: Icon(Icons.account_circle),
                              onPressed: (BuildContext context) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        UserSetting(
                                          listOriginUserSetting:
                                              settingsUserModified
                                                  ? settingsUser
                                                  : _settingsUser,
                                        )));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(4),
                      child: Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        child: SettingsSection(
                          title: '폴더',
                          tiles: [
                            SettingsTile(
                              title: '폴더 관리',
                              subtitle:
                                  '그룹별로 폴더 엑세스 권한을 조정하거나, 서버에 보여질 폴더를 조정할 수 있습니다.',
                              subtitleMaxLines: 3,
                              leading: Icon(Icons.folder),
                              onPressed: (BuildContext context) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        FolderSetting(
                                          listOriginFolderSetting:
                                              settingsFolderModified
                                                  ? settingsFolder
                                                  : _settingsFolder,
                                        )));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(4),
                      child: Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        child: SettingsSection(
                          title: '기타',
                          tiles: [
                            SettingsTile(
                              title: '지원',
                              subtitle:
                                  'Tidy Discord 지원서버에 들어와서 문제 / 버그를 보고하거나 아이디어를 낼 수도 있습니다. 또는 여러사람들과 대화도 해보세요!',
                              subtitleMaxLines: 3,
                              leading: Icon(Icons.support_agent),
                              onPressed: (BuildContext context) {
                                switch (Platform.operatingSystem) {
                                  case "linux":
                                    Process.run("x-www-browser",
                                        ["https://discord.gg/N5QAdv6sKM"]);
                                    break;
                                  case "macos":
                                    Process.run("open",
                                        ["https://discord.gg/N5QAdv6sKM"]);
                                    break;
                                  case "windows":
                                    Process.run("explorer",
                                        ["https://discord.gg/N5QAdv6sKM"]);
                                    break;
                                  default:
                                    break;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error),
                  SizedBox(
                    height: 12,
                  ),
                  Text("Tidy 설정을 가져오는데 실패하였습니다.")
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 12,
                  ),
                  Text("Tidy 설정을 가져오중...")
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _showSnackBar(
      dynamic context, Widget element, Duration duration) async {
    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } catch (e) {}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        content: Container(
          child: element,
        ),
      ),
    );
  }
}
