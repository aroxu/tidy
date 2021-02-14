import 'package:dbcrypt/dbcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:tidy_manager/global.dart';
import 'package:tidy_manager/model/settingUserModel.dart';
import 'package:tidy_manager/ui/smoothDialog.dart';
import 'package:tidy_manager/util/forEachIndex.dart';

import 'util/replaceLast.dart';

class UserSetting extends StatefulWidget {
  final List<SettingUserModel> listOriginUserSetting;

  UserSetting({Key key, @required this.listOriginUserSetting})
      : super(key: key);

  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  final _settingsNameInput = TextEditingController();
  final _settingsPasswordInput = TextEditingController();
  final _settingsAssignedRolesInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    settingsUser = widget.listOriginUserSetting;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: new Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          tooltip: "뒤로가기",
        ),
        elevation: 0,
        title: Text("유저 관리"),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: SettingsSection(
                  tiles: settingsUser
                      .map<SettingsTile>(
                        (e) => SettingsTile(
                          title: e.name,
                          subtitle: e.role.join(", "),
                          subtitleMaxLines: 3,
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              createSmoothDialog(
                                  context,
                                  "삭제 확인",
                                  Text("정말 유저 '${e.name}'을(를) 삭제할까요?"),
                                  Row(children: [
                                    new TextButton(
                                      onPressed: () {
                                        return Navigator.pop(context);
                                      },
                                      child: Text("취소"),
                                    ),
                                    new TextButton(
                                      onPressed: () {
                                        setState(() {
                                          List<SettingUserModel>.from(
                                                  settingsUser)
                                              .forEachIndex((element, i) {
                                            if (element.name == e.name) {
                                              settingsUser.removeAt(i);
                                            }
                                          });
                                          settingsUserModified = true;
                                        });
                                        return Navigator.pop(context);
                                      },
                                      child: Text("확인"),
                                    )
                                  ]),
                                  Icon(Icons.check),
                                  false);
                            },
                            tooltip: "${e.name} 삭제",
                          ),
                          onPressed: (BuildContext context) {
                            _settingsNameInput.text = e.name;
                            _settingsPasswordInput.text = "";
                            _settingsAssignedRolesInput.text = e.role.join(',');
                            createSmoothDialog(
                              context,
                              "유저 수정하기",
                              Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      obscureText: false,
                                      controller: _settingsNameInput,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "유저 목록에 이 이름이 표시됩니다.",
                                        labelText: "유저의 이름을 변경합니다.",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    TextFormField(
                                      obscureText: true,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(
                                            r'[\w\d\s!@#$%^&*()_+\-=\[\]{};:\\|,.<>\/?]*$')),
                                        FilteringTextInputFormatter.deny(' '),
                                      ],
                                      controller: _settingsPasswordInput,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText:
                                            "입력한 암호는 해시형태로 저장되며, 공백으로 두면 기존 암호를 사용합니다.",
                                        labelText: "유저의 암호를 설정합니다.",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    TextFormField(
                                      obscureText: false,
                                      controller: _settingsAssignedRolesInput,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText:
                                            "유효하지 않는 역할은 무효처리됩니다. 쉼표로 역할이 구분되며 공백과 쌍따옴표는 삭제됩니다.",
                                        labelText:
                                            "해당 유저에게 할당 될 역할 목록을 수정합니다. 쉼표로 역할이 구분되며 공백과 쌍따옴표는 삭제됩니다.",
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  new TextButton(
                                    onPressed: () {
                                      return Navigator.pop(context);
                                    },
                                    child: Text("취소"),
                                  ),
                                  new TextButton(
                                    onPressed: () {
                                      if (_settingsNameInput.text.trim() ==
                                              "" ||
                                          _settingsAssignedRolesInput.text
                                                  .trim() ==
                                              "") {
                                        return createSmoothDialog(
                                            context,
                                            "추가할 수 없음",
                                            Text("모든 항목을 채워주세요."),
                                            new TextButton(
                                              child: new Text("확인"),
                                              onPressed: () async {
                                                return Navigator.pop(context);
                                              },
                                            ),
                                            Icon(Icons.warning),
                                            false);
                                      } else if (_settingsPasswordInput.text
                                                  .trim() !=
                                              "" &&
                                          _settingsPasswordInput.text.length <
                                              8) {
                                        return createSmoothDialog(
                                            context,
                                            "유저 암호 변경 실패",
                                            Text("유저 암호는 적어도 8자 이상이어야 합니다."),
                                            new TextButton(
                                              child: new Text("확인"),
                                              onPressed: () async {
                                                return Navigator.pop(context);
                                              },
                                            ),
                                            Icon(Icons.lock),
                                            false);
                                      }
                                      setState(() {
                                        e.name = _settingsNameInput.text;
                                        _settingsPasswordInput.text.trim() == ""
                                            ? e.password = e.password
                                            : e.password = DBCrypt().hashpw(
                                                _settingsPasswordInput.text,
                                                DBCrypt().gensaltWithRounds(4));
                                        print(e.password);
                                        e.role = _settingsAssignedRolesInput
                                                .text
                                                .trim()
                                                .endsWith(",")
                                            ? replaceLast(
                                                    _settingsAssignedRolesInput
                                                        .text
                                                        .trim(),
                                                    ",",
                                                    "")
                                                .replaceAll(" ", "")
                                                .replaceAll('"', "")
                                                .split(",")
                                            : _settingsAssignedRolesInput.text
                                                .trim()
                                                .replaceAll(" ", "")
                                                .replaceAll('"', "")
                                                .split(",");
                                        settingsUserModified = true;
                                      });
                                      return Navigator.pop(context);
                                    },
                                    child: Text("확인"),
                                  )
                                ],
                              ),
                              Icon(Icons.check),
                              false,
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _settingsNameInput.text = "";
          _settingsPasswordInput.text = "";
          _settingsAssignedRolesInput.text = "";
          createSmoothDialog(
            context,
            "유저 수정하기",
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    obscureText: false,
                    controller: _settingsNameInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "유저 목록에 이 이름이 표시됩니다.",
                      labelText: "유저의 이름을 변경합니다.",
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(
                          r'[\w\d\s!@#$%^&*()_+\-=\[\]{};:\\|,.<>\/?]*$')),
                      FilteringTextInputFormatter.deny(' '),
                    ],
                    obscureText: true,
                    controller: _settingsPasswordInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "입력한 암호는 해시형태로 저장됩니다.",
                      labelText: "유저의 암호를 설정합니다.",
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    obscureText: false,
                    controller: _settingsAssignedRolesInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:
                          "유효하지 않는 역할은 무효처리됩니다. 쉼표로 역할이 구분되며 공백과 쌍따옴표는 삭제됩니다.",
                      labelText:
                          "해당 유저에게 할당 될 역할 목록을 수정합니다. 쉼표로 역할이 구분되며 공백과 쌍따옴표는 삭제됩니다.",
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                new TextButton(
                  onPressed: () {
                    return Navigator.pop(context);
                  },
                  child: Text("취소"),
                ),
                new TextButton(
                  onPressed: () {
                    if (_settingsNameInput.text.trim() == "" ||
                        _settingsPasswordInput.text.trim() == "" ||
                        _settingsAssignedRolesInput.text.trim() == "") {
                      return createSmoothDialog(
                          context,
                          "추가할 수 없음",
                          Text("모든 항목을 채워주세요."),
                          new TextButton(
                            child: new Text("확인"),
                            onPressed: () async {
                              return Navigator.pop(context);
                            },
                          ),
                          Icon(Icons.warning),
                          false);
                    } else if (_settingsPasswordInput.text != "" &&
                        _settingsPasswordInput.text.trim().length < 8) {
                      return createSmoothDialog(
                          context,
                          "추가할 수 없음",
                          Text("유저 암호는 적어도 8자 이상이어야 합니다."),
                          new TextButton(
                            child: new Text("확인"),
                            onPressed: () async {
                              return Navigator.pop(context);
                            },
                          ),
                          Icon(Icons.lock),
                          false);
                    }
                    setState(() {
                      settingsUser.add(new SettingUserModel(
                          name: _settingsNameInput.text,
                          password: DBCrypt().hashpw(
                              _settingsPasswordInput.text,
                              DBCrypt().gensaltWithRounds(4)),
                          role: _settingsAssignedRolesInput.text
                                  .trim()
                                  .endsWith(",")
                              ? replaceLast(
                                      _settingsAssignedRolesInput.text.trim(),
                                      ",",
                                      "")
                                  .replaceAll(" ", "")
                                  .replaceAll('"', "")
                                  .split(",")
                              : _settingsAssignedRolesInput.text
                                  .trim()
                                  .replaceAll(" ", "")
                                  .replaceAll('"', "")
                                  .split(",")));
                      settingsUserModified = true;
                    });
                    return Navigator.pop(context);
                  },
                  child: Text("확인"),
                )
              ],
            ),
            Icon(Icons.check),
            false,
          );
        },
        tooltip: "유저 추가",
      ),
    );
  }
}
