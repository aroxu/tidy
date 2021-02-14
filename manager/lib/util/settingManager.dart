import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';
import 'package:tidy_manager/model/settingConfigModel.dart';
import 'package:tidy_manager/model/settingFolderModel.dart';
import 'package:tidy_manager/model/settingUserModel.dart';
import 'package:tidy_manager/util/replaceLast.dart';

import '../global.dart';

Future<List<dynamic>> getSettings() async {
  await Future.delayed(Duration(milliseconds: 500));
  String _homeDir;
  Directory _configDir;
  File _generalSettingFile;
  File _userSettingFile;
  File _folderSettingFile;

  SettingConfigModel _generalSetting;
  List<SettingUserModel> _userSetting;
  List<SettingFolderModel> _folderSetting;
  String _startUpSetting;

  if (Platform.isMacOS || Platform.isLinux) {
    _homeDir = Platform.environment['HOME'];
    _configDir = Directory("$_homeDir/tidy/data");
    _generalSettingFile = File("${_configDir.path}/config.json");
    _userSettingFile = File("${_configDir.path}/user.json");
    _folderSettingFile = File("${_configDir.path}/folder.json");
  } else if (Platform.isWindows) {
    _homeDir = Platform.environment['USERPROFILE'];
    _configDir = Directory("$_homeDir\\tidy\\data");
    _generalSettingFile = File("${_configDir.path}\\config.json");
    _userSettingFile = File("${_configDir.path}\\user.json");
    _folderSettingFile = File("${_configDir.path}\\folder.json");
  } else {
    return ["OS_NOT_SUPPORTED"];
  }
  if (!_generalSettingFile.existsSync() ||
      !_userSettingFile.existsSync() ||
      !_folderSettingFile.existsSync()) {
    return ["ERR_CONFIG_MISSING", _homeDir];
  }
  _generalSetting = await _getGeneralSetting(_generalSettingFile);
  _userSetting = await _getUserSetting(_userSettingFile);
  _folderSetting = await _getFolderSetting(_folderSettingFile);
  _startUpSetting = await _getStartOnBootSetting();
  return [_generalSetting, _userSetting, _folderSetting, _startUpSetting];
}

Future<SettingConfigModel> _getGeneralSetting(File generalSettingFile) async {
  return SettingConfigModel.fromJson(
      jsonDecode(await generalSettingFile.readAsString()));
}

Future<List<SettingUserModel>> _getUserSetting(File userSettingFile) async {
  Iterable _userSettingData = jsonDecode(await userSettingFile.readAsString());
  return List<SettingUserModel>.from(_userSettingData
      .map((userSetting) => SettingUserModel.fromJson(userSetting)));
}

Future<List<SettingFolderModel>> _getFolderSetting(
    File folderSettingFile) async {
  Iterable _folderSettingData =
      jsonDecode(await folderSettingFile.readAsString());

  return List<SettingFolderModel>.from(_folderSettingData
      .map((folderSetting) => SettingFolderModel.fromJson(folderSetting)));
}

Future<String> _getStartOnBootSetting() async {
  var _shell = Shell(runInShell: false, verbose: false);
  String _result;
  if (Platform.isMacOS) {
    await _shell
        .run('sh -c "cat /Library/LaunchDaemons/TidyEngine.plist"')
        .then(
      (result) {
        var _resultAsString = result.outText;
        if (_resultAsString.contains("""    <key>RunAtLoad</key>
    <true/>""")) {
          _result = "true";
        } else if (_resultAsString.contains("""    <key>RunAtLoad</key>
    <false/>""")) {
          _result = "false";
        } else {
          _result = "NULL";
        }
      },
    ).catchError(
      (onError) {
        _result = "NULL";
      },
    );
  } else if (Platform.isWindows) {
    final File _elevator = File("elevator.exe");
    ByteData _elevatorByteData =
        await PlatformAssetBundle().load('assets/elevator.exe');
    List<int> _elevatorBytes = _elevatorByteData.buffer.asUint8List(
        _elevatorByteData.offsetInBytes, _elevatorByteData.lengthInBytes);
    await _elevator.writeAsBytes(_elevatorBytes);
    await _shell.run('${_elevator.path} sc.exe qc TidyEngine').then(
      (result) {
        var _resultAsString = result.outText.toString();
        if (_resultAsString.contains("AUTO_START")) {
          _result = "true";
        } else if (_resultAsString.contains("DEMAND_START")) {
          _result = "false";
        } else {
          _result = "NULL";
        }
      },
    ).catchError(
      (onError) {
        _result = "NULL";
      },
    );
  } else {
    _result = "NOT_SUPPORTED";
  }
  return _result;
}

Future<void> _setStartOnBootSetting(bool enable) async {
  var _shell = Shell(runInShell: false, verbose: false);
  if (Platform.isMacOS) {
    String _job = enable ? "false/true" : "true/false";
    await _shell
        .run(
            '''sh -c "echo \'$userPasswordForSudo\' | sudo -S sed -i '' '/<key>RunAtLoad</{n;s/$_job/;}' /Library/LaunchDaemons/TidyEngine.plist"''')
        .then(
          (_) {},
        )
        .catchError(
          (onError) {
            print(onError.toString());
          },
        );
  } else if (Platform.isWindows) {
    String _job = enable ? "auto" : "manual";
    final File _elevator = File("elevator.exe");
    ByteData _elevatorByteData =
        await PlatformAssetBundle().load('assets/elevator.exe');
    List<int> _elevatorBytes = _elevatorByteData.buffer.asUint8List(
        _elevatorByteData.offsetInBytes, _elevatorByteData.lengthInBytes);
    await _elevator.writeAsBytes(_elevatorBytes);
    await _shell
        .run('${_elevator.path} sc.exe config TidyEngine start=$_job')
        .then(
          (_) {},
        )
        .catchError(
      (onError) {
        print(onError.toString());
      },
    );
  }
}

Future<bool> saveSettings() async {
  await Future.delayed(Duration(milliseconds: 500));
  String _homeDir;
  Directory _configDir;
  File _generalSettingFile;
  File _userSettingFile;
  File _folderSettingFile;

  if (Platform.isMacOS || Platform.isLinux) {
    _homeDir = Platform.environment['HOME'];
    _configDir = Directory("$_homeDir/tidy/data");
    _generalSettingFile = File("${_configDir.path}/config.json");
    _userSettingFile = File("${_configDir.path}/user.json");
    _folderSettingFile = File("${_configDir.path}/folder.json");
  } else if (Platform.isWindows) {
    _homeDir = Platform.environment['USERPROFILE'];
    _configDir = Directory("$_homeDir\\tidy\\data");
    _generalSettingFile = File("${_configDir.path}\\config.json");
    _userSettingFile = File("${_configDir.path}\\user.json");
    _folderSettingFile = File("${_configDir.path}\\folder.json");
  } else {
    return false;
  }

  if (settingsGeneralNameModified ||
      settingsGeneralPortModified ||
      settingsGeneralEnableAuthModified ||
      settingsGeneralJwtSecretModified) {
    await _generalSettingFile.writeAsString(jsonEncode(SettingConfigModel(
            name: settingsGeneralName,
            port: settingsGeneralPort,
            enableAuth: settingsGeneralEnableAuth,
            jwtSecret: settingsGeneralJwtSecret)
        .toJson()));
  }
  if (settingsUserModified) {
    String _outputData = "[";
    settingsUser.forEach((element) {
      _outputData += jsonEncode(SettingUserModel(
                  name: element.name,
                  password: element.password,
                  role: element.role)
              .toJson()) +
          ",";
    });
    _outputData = replaceLast(_outputData, ",", "") + "]";
    await _userSettingFile.writeAsString(_outputData);
  }
  if (settingsFolderModified) {
    String _outputData = "[";
    settingsFolder.forEach((element) {
      _outputData += jsonEncode(SettingFolderModel(
                  id: element.id,
                  name: element.name,
                  description: element.description,
                  path: element.path,
                  accessRole: element.accessRole)
              .toJson()) +
          ",";
    });
    _outputData = replaceLast(_outputData, ",", "") + "]";
    await _folderSettingFile.writeAsString(_outputData);
  }
  if (settingsGeneralStartOnBootModified) {
    await _setStartOnBootSetting(
        settingsGeneralStartOnBoot == "true" ? true : false);
  }
  return true;
}
