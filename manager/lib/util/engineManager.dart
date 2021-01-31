import 'dart:io';

import 'package:flutter/services.dart';
import 'package:process_run/shell.dart';

var shell = Shell(runInShell: true);

Future<List<dynamic>> getEngineStatus() async {
  var data = [];
  var homeDir = "";
  if (Platform.isMacOS) {
    final String homeDir = Platform.environment['HOME'];
    final File tidyEngine = File("$homeDir/tidy/engine");
    if (!tidyEngine.existsSync()) return [false, "ERR_TIDY_ENGINE_NOT_EXIST"];
    await shell.run("${tidyEngine.path} status").then(
      (result) {
        print(result.outLines);
        var out = result.outLines.toString();
        data = [true, out];
      },
    ).catchError(
      (onError) {
        var err = onError.toString();
        print(err);
        data = [false, err];
      },
    );
  } else if (Platform.isWindows) {
    final String homeDir = Platform.environment['USERPROFILE'];
    final File tidyEngine = File("$homeDir\\tidy\\engine.exe");
    var _executor = File("elevator.exe");
    ByteData _executorByteData =
        await PlatformAssetBundle().load('assets/elevator.exe');
    List<int> _executorBytes = _executorByteData.buffer.asUint8List(
        _executorByteData.offsetInBytes, _executorByteData.lengthInBytes);
    await _executor.writeAsBytes(_executorBytes);
    if (!tidyEngine.existsSync()) return [false, "ERR_TIDY_ENGINE_NOT_EXIST"];
    await shell.run('${_executor.path} ${tidyEngine.path} status').then(
      (result) {
        print(result.outLines);
        var out = result.outLines.toString();
        data = [true, out];
      },
    ).catchError(
      (onError) {
        var err = onError.toString();
        print(err);
        data = [false, err];
      },
    );
    await _executor.delete();
  } else if (Platform.isLinux) {
    final String homeDir = Platform.environment['HOME'];
    final File tidyEngine = File("$homeDir\\tidy\\engine");
    if (!tidyEngine.existsSync()) return [false, "ERR_TIDY_ENGINE_NOT_EXIST"];
    await shell.run("${tidyEngine.path} status").then(
      (result) {
        print(result.outLines);
        var out = result.outLines.toString();
        data = [true, out];
      },
    ).catchError(
      (onError) {
        var err = onError.toString();
        print(err);
        data = [false, err];
      },
    );
  } else {
    data = [false, "This OS is Not Supported. :["];
  }
  return data;
}
