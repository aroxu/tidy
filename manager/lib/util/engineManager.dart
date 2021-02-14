import 'dart:io';

import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';

import '../global.dart';

var shell = Shell(runInShell: false, verbose: false);

Future<List<dynamic>> getEngineStatus() async {
  if (!reCheckRequired) {
    return prevEngineData;
  }
  reCheckRequired = false;
  var data = await _getEngineStatus();
  prevEngineData = data;
  return data;
}

String _engineOutputToStatusCode(String message) {
  switch (message) {
    case "(Process is already started)":
      return "ERR_ALREADY_STARTED";
    case "(Process is already stopped)":
      return "ERR_ALREADY_STOPPED";
    case "(Stopping service before uninstall...)":
      return "STP_BEFORE_UNINSTALL";
    case "(Process is running)":
      return "PROCESS_RUNNING";
    case "(Process is stopped)":
      return "PROCESS_STOPPED";
    case "(Process is stopped or the service is not installed)":
      return "PROCESS_STOPPED_OR_NOT_INSTALLED";
    default:
      return message;
  }
}

Future<bool> isEngineRunning() async {
  var _engineStatus = await _getEngineStatus();
  switch (_engineStatus[1]) {
    case "PROCESS_RUNNING":
      return true;
    case "PROCESS_STOPPED":
      return false;
    case "PROCESS_STOPPED_OR_NOT_INSTALLED":
      return false;
      break;
    default:
      return false;
  }
}

Future<bool> toggleEngineStatus() async {
  bool _data;
  String _task = await isEngineRunning() ? "stop" : "start";

  if (Platform.isMacOS || Platform.isLinux) {
    final String homeDir = Platform.environment['HOME'];
    final File tidyEngine = File("$homeDir/tidy/engine");
    if (!tidyEngine.existsSync()) return false;
    await shell
        .run(
            'sh -c "echo \'$userPasswordForSudo\' | sudo -S ${tidyEngine.path} $_task"')
        .then(
      (result) {
        _data = true;
      },
    ).catchError(
      (onError) {
        _data = false;
      },
    );
  } else if (Platform.isWindows) {
    final String homeDir = Platform.environment['USERPROFILE'];
    final File tidyEngine = File("$homeDir\\tidy\\engine.exe");
    final File _elevator = File("elevator.exe");
    ByteData _elevatorByteData =
        await PlatformAssetBundle().load('assets/elevator.exe');
    List<int> _elevatorBytes = _elevatorByteData.buffer.asUint8List(
        _elevatorByteData.offsetInBytes, _elevatorByteData.lengthInBytes);
    await _elevator.writeAsBytes(_elevatorBytes);
    if (!tidyEngine.existsSync()) return false;
    await shell.run('${_elevator.path} ${tidyEngine.path} $_task').then(
      (result) {
        _data = true;
      },
    ).catchError(
      (onError) {
        _data = false;
      },
    );
    await _elevator.delete();
  } else {
    _data = false;
  }
  return _data;
}

Future<List<dynamic>> _getEngineStatus() async {
  var data = [];
  if (Platform.isMacOS || Platform.isLinux) {
    final String homeDir = Platform.environment['HOME'];
    final File tidyEngine = File("$homeDir/tidy/engine");
    if (!tidyEngine.existsSync()) return [false, "ERR_TIDY_ENGINE_NOT_EXIST"];
    await shell
        .run(
            'sh -c "echo \'$userPasswordForSudo\' | sudo -S ${tidyEngine.path} status"')
        .then(
      (result) {
        var out = result.outLines.toString();
        data = [true, _engineOutputToStatusCode(out)];
      },
    ).catchError(
      (onError) {
        var err = onError.toString();
        data = [false, err];
      },
    );
  } else if (Platform.isWindows) {
    final String homeDir = Platform.environment['USERPROFILE'];
    final File tidyEngine = File("$homeDir\\tidy\\engine.exe");
    final File _elevator = File("elevator.exe");
    ByteData _elevatorByteData =
        await PlatformAssetBundle().load('assets/elevator.exe');
    List<int> _elevatorBytes = _elevatorByteData.buffer.asUint8List(
        _elevatorByteData.offsetInBytes, _elevatorByteData.lengthInBytes);
    await _elevator.writeAsBytes(_elevatorBytes);
    if (!tidyEngine.existsSync()) return [false, "ERR_TIDY_ENGINE_NOT_EXIST"];
    await shell.run('${_elevator.path} ${tidyEngine.path} status').then(
      (result) {
        var out = result.outLines.toString();
        data = [true, _engineOutputToStatusCode(out)];
      },
    ).catchError(
      (onError) {
        var err = onError.toString();
        data = [false, err];
      },
    );
    await _elevator.delete();
  } else {
    data = [false, _engineOutputToStatusCode("This OS is Not Supported. :[")];
  }
  return data;
}
