import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:tidy_manager/global.dart';
import 'package:tidy_manager/model/settingFolderModel.dart';
import 'package:tidy_manager/ui/smoothDialog.dart';
import 'package:tidy_manager/util/forEachIndex.dart';
import 'package:file_chooser/file_chooser.dart' as file_chooser;
import 'package:file_chooser/file_chooser.dart';

import 'util/replaceLast.dart';

class FolderSetting extends StatefulWidget {
  final List<SettingFolderModel> listOriginFolderSetting;

  FolderSetting({Key key, @required this.listOriginFolderSetting})
      : super(key: key);

  @override
  _FolderSettingState createState() => _FolderSettingState();
}

class _FolderSettingState extends State<FolderSetting> {
  final _settingsIDInput = TextEditingController();
  final _settingsNameInput = TextEditingController();
  final _settingsDescriptionInput = TextEditingController();
  final _settingsGrantedRolesInput = TextEditingController();
  String _settingsPath;

  @override
  Widget build(BuildContext context) {
    settingsFolder = widget.listOriginFolderSetting;
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
        title: Text("폴더 관리"),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: SettingsSection(
                  tiles: settingsFolder
                      .map<SettingsTile>(
                        (e) => SettingsTile(
                          title: e.name,
                          subtitle: e.description,
                          subtitleMaxLines: 3,
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              createSmoothDialog(
                                  context,
                                  "삭제 확인",
                                  Text(
                                      "정말 폴더 '${e.name}'을(를) 삭제할까요?\n실제로 폴더가 삭제되지는 않습니다."),
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
                                          List<SettingFolderModel>.from(
                                                  settingsFolder)
                                              .forEachIndex((element, i) {
                                            if (element.id == e.id) {
                                              settingsFolder.removeAt(i);
                                            }
                                          });
                                          settingsFolderModified = true;
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
                            _settingsIDInput.text = e.id;
                            _settingsNameInput.text = e.name;
                            _settingsDescriptionInput.text = e.description;
                            _settingsPath = e.path;
                            _settingsGrantedRolesInput.text =
                                e.accessRole.join(',');
                            createSmoothDialog(
                              context,
                              "폴더 수정하기",
                              Container(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      obscureText: false,
                                      controller: _settingsIDInput,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "다른 폴더 항목과 겹치지 않는 ID가 필요합니다.",
                                        labelText: "폴더의 진입 지점 및 ID를 변경합니다.",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    TextFormField(
                                      obscureText: false,
                                      controller: _settingsNameInput,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "폴더 목록에 이 이름이 표시됩니다.",
                                        labelText: "폴더의 이름을 변경합니다.",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    TextFormField(
                                      obscureText: false,
                                      controller: _settingsDescriptionInput,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "보통 폴더의 요약 또는 설명을 입력합니다.",
                                        labelText: "폴더의 설명을 변경합니다.",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    TextFormField(
                                      obscureText: false,
                                      controller: _settingsGrantedRolesInput,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText:
                                            "유효하지 않는 역할은 무효처리됩니다. 쉼표로 역할이 구분되며 공백과 쌍따옴표는 삭제됩니다.",
                                        labelText:
                                            "폴더에 접근할 수 있는 역할들을 수정합니다. 쉼표로 역할이 구분되며 공백과 쌍따옴표는 삭제됩니다.",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            final FileChooserResult _folder =
                                                await file_chooser
                                                    .showOpenPanel(
                                              canSelectDirectories: true,
                                              initialDirectory: _settingsPath,
                                              allowsMultipleSelection: false,
                                            );
                                            if (!_folder.canceled) {
                                              _settingsPath = _folder.paths[0];
                                            }
                                          },
                                          child: Text("경로 확인 / 설정"),
                                        ),
                                      ],
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
                                      if (_settingsIDInput.text.trim() == "" ||
                                          _settingsNameInput.text.trim() ==
                                              "" ||
                                          _settingsDescriptionInput.text
                                                  .trim() ==
                                              "" ||
                                          _settingsGrantedRolesInput.text
                                                  .trim() ==
                                              "" ||
                                          _settingsPath.trim() == "") {
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
                                      }
                                      setState(() {
                                        e.id = _settingsIDInput.text;
                                        e.name = _settingsNameInput.text;
                                        e.description =
                                            _settingsDescriptionInput.text;
                                        e.accessRole = _settingsGrantedRolesInput
                                                .text
                                                .trim()
                                                .endsWith(",")
                                            ? replaceLast(
                                                    _settingsGrantedRolesInput
                                                        .text
                                                        .trim(),
                                                    ",",
                                                    "")
                                                .replaceAll(" ", "")
                                                .replaceAll('"', "")
                                                .split(",")
                                            : _settingsGrantedRolesInput.text
                                                .trim()
                                                .replaceAll(" ", "")
                                                .replaceAll('"', "")
                                                .split(",");
                                        e.path = _settingsPath;
                                        settingsFolderModified = true;
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
          _settingsIDInput.text = "";
          _settingsNameInput.text = "";
          _settingsDescriptionInput.text = "";
          _settingsGrantedRolesInput.text = "";
          _settingsPath = "";

          createSmoothDialog(
            context,
            "폴더 추가하기",
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    obscureText: false,
                    controller: _settingsIDInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "다른 폴더 항목과 겹치지 않는 ID가 필요합니다.",
                      labelText: "폴더의 진입 지점 및 ID를 변경합니다.",
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    obscureText: false,
                    controller: _settingsNameInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "폴더 목록에 이 이름이 표시됩니다.",
                      labelText: "폴더의 이름을 변경합니다.",
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    obscureText: false,
                    controller: _settingsDescriptionInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "보통 폴더의 요약 또는 설명을 입력합니다.",
                      labelText: "폴더의 설명을 변경합니다.",
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    obscureText: false,
                    controller: _settingsGrantedRolesInput,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:
                          "유효하지 않는 역할은 무효처리됩니다. 쉼표로 역할이 구분되며 공백과 쌍따옴표는 삭제됩니다.",
                      labelText:
                          "폴더에 접근할 수 있는 역할들을 수정합니다. 쉼표로 역할이 구분되며 공백과 쌍따옴표는 삭제됩니다.",
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final FileChooserResult _folder =
                              await file_chooser.showOpenPanel(
                            canSelectDirectories: true,
                            allowsMultipleSelection: false,
                          );
                          if (!_folder.canceled) {
                            _settingsPath = _folder.paths[0];
                          }
                        },
                        child: Text("경로 확인 / 설정"),
                      ),
                    ],
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
                    if (_settingsIDInput.text.trim() == "" ||
                        _settingsNameInput.text.trim() == "" ||
                        _settingsDescriptionInput.text.trim() == "" ||
                        _settingsGrantedRolesInput.text.trim() == "" ||
                        _settingsPath.trim() == "") {
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
                    }
                    setState(() {
                      settingsFolder.add(new SettingFolderModel(
                          id: _settingsIDInput.text,
                          name: _settingsNameInput.text,
                          description: _settingsDescriptionInput.text,
                          accessRole: _settingsGrantedRolesInput.text
                                  .trim()
                                  .endsWith(",")
                              ? replaceLast(
                                      _settingsGrantedRolesInput.text.trim(),
                                      ",",
                                      "")
                                  .replaceAll(" ", "")
                                  .replaceAll('"', "")
                                  .split(",")
                              : _settingsGrantedRolesInput.text
                                  .trim()
                                  .replaceAll(" ", "")
                                  .replaceAll('"', "")
                                  .split(","),
                          path: _settingsPath));

                      settingsFolderModified = true;
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
        tooltip: "폴더 추가",
      ),
    );
  }
}
