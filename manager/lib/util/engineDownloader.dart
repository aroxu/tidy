import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart' as http;
import 'package:process_run/shell.dart';
import 'package:tidy_manager/ui/smoothDialog.dart';

import '../global.dart';

var shell = Shell(runInShell: false, verbose: false);

Future<void> engineDownloader(dynamic context, String url) async {
  final request = http.Request('GET', Uri.parse(url));
  final http.StreamedResponse response = await http.Client().send(request);

  List<int> bytes = [];

  final file = File('engine_data.zip');
  if (file.existsSync()) {
    await file.delete(recursive: true);
  }
  response.stream.listen(
    (List<int> newBytes) {
      bytes.addAll(newBytes);
    },
    onDone: () async {
      await file.writeAsBytes(bytes);
      final _archivedEngineBytesWithZipDecoder =
          ZipDecoder().decodeBytes(await file.readAsBytes());
      String _homeDir;
      File _tidyEngine;
      if (Platform.isMacOS || Platform.isLinux) {
        _homeDir = Platform.environment['HOME'];
        _tidyEngine = File("$_homeDir/tidy/engine");

        for (final file in _archivedEngineBytesWithZipDecoder) {
          if (file.isFile) {
            final data = file.content as List<int>;
            var asdf = File(_tidyEngine.path);
            await asdf.create(recursive: true);
            await asdf.writeAsBytes(data);
          }
        }
        await shell
            .run('''chmod a+x ${_tidyEngine.path}''')
            .then((_) => print("Made tidy engine as executable."))
            .catchError((_) => {
                  print("An error occured during making tidy engine executable")
                });
        await shell
            .run(
                '''sh -c "echo "$userPasswordForSudo" | sudo -S sh -c '${_tidyEngine.path} uninstall'"''')
            .then((_) => print("Uninstalled previous service..."))
            .catchError((_) =>
                {print("Previous version of service is not installed.")});
        await shell.run(
            // """echo "$userPasswordForSudo" | sudo -S osascript -e 'do shell script "chmod a+x ${_tidyEngine.path} && ${_tidyEngine.path} init && ${_tidyEngine.path} install" with administrator privileges'""").then(
            '''sh -c "echo "$userPasswordForSudo" | sudo -S sh -c '${_tidyEngine.path} init && ${_tidyEngine.path} install && chmod -R a+rwx $_homeDir/tidy'"''').then(
          (_) {
            createSmoothDialog(
              context,
              "엔진 준비됨",
              Text(
                  "엔진이 성공적으로 다운로드 및 설치 되었습니다.\n확인 버튼을 누르고 5초 이내에 리로드 되지 않는다면 수동으로 재시작해주세요."),
              new TextButton(
                child: new Text("확인"),
                onPressed: () async {
                  try {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  } catch (e) {}
                  installingEngine = false;
                  Navigator.pop(context);
                  return Phoenix.rebirth(context);
                },
              ),
              Icon(Icons.check),
              false,
            );
          },
        ).catchError(
          (e) {
            createSmoothDialog(
              context,
              "다운로드 실패",
              Expanded(
                child: Text(
                    "엔진을 설치 하는 중 오류가 발생하였습니다.\nGitHub Issue를 생성하여 아래 내용을 개발자에게 알려주세요.\n${e.toString()}"),
              ),
              new TextButton(
                child: new Text("확인"),
                onPressed: () async {
                  try {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  } catch (e) {}
                  installingEngine = false;
                  Navigator.pop(context);
                  return SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop');
                },
              ),
              Icon(Icons.warning),
              false,
            );
          },
        );
        if (file.existsSync()) {
          await file.delete(recursive: true);
        }
      } else if (Platform.isWindows) {
        _homeDir = Platform.environment['USERPROFILE'];
        _tidyEngine = File("$_homeDir\\tidy\\engine.exe");

        final File _elevator = File("elevator.exe");
        ByteData _elevatorByteData =
            await PlatformAssetBundle().load('assets/elevator.exe');
        List<int> _elevatorBytes = _elevatorByteData.buffer.asUint8List(
            _elevatorByteData.offsetInBytes, _elevatorByteData.lengthInBytes);
        await _elevator.writeAsBytes(_elevatorBytes);

        for (final file in _archivedEngineBytesWithZipDecoder) {
          if (file.isFile) {
            final data = file.content as List<int>;
            var asdf = File(_tidyEngine.path);
            await asdf.create(recursive: true);
            await asdf.writeAsBytes(data);
          }
        }

        await shell
            .run('''${_elevator.path} ${_tidyEngine.path} uninstall'"''')
            .then((_) => print("Uninstalled previous service..."))
            .catchError((_) =>
                {print("Previous version of service is not installed.")});
        await shell.run('${_elevator.path} ${_tidyEngine.path} init');
        await shell.run('${_elevator.path} ${_tidyEngine.path} install').then(
          (_) {
            createSmoothDialog(
              context,
              "엔진 준비됨",
              Text("엔진이 성공적으로 다운로드 및 설치 되었습니다."),
              new TextButton(
                child: new Text("확인"),
                onPressed: () async {
                  try {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  } catch (e) {}
                  installingEngine = false;
                  Navigator.pop(context);
                  return Phoenix.rebirth(context);
                },
              ),
              Icon(Icons.check),
              false,
            );
          },
        ).catchError(
          (e) {
            createSmoothDialog(
              context,
              "다운로드 실패",
              Expanded(
                child: Text(
                    "엔진을 설치 하는 중 오류가 발생하였습니다.\nGitHub Issue를 생성하여 아래 내용을 개발자에게 알려주세요.\n${e.toString()}"),
              ),
              new TextButton(
                child: new Text("확인"),
                onPressed: () async {
                  try {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  } catch (e) {}
                  installingEngine = false;
                  Navigator.pop(context);
                  return SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop');
                },
              ),
              Icon(Icons.warning),
              false,
            );
          },
        );
        await _elevator.delete();
        if (file.existsSync()) {
          await file.delete(recursive: true);
        }
      }
    },
    onError: (e) async {
      createSmoothDialog(
        context,
        "다운로드 실패",
        Text(
            "엔진을 다운로드 하는 중 오류가 발생하였습니다.\nGitHub Issue를 생성하여 아래 내용을 개발자에게 알려주세요.\n${e.toString()}"),
        new TextButton(
          child: new Text("확인"),
          onPressed: () async {
            try {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            } catch (e) {}
            installingEngine = false;
            Navigator.pop(context);
            return SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          },
        ),
        Icon(Icons.warning),
        false,
      );
      if (file.existsSync()) {
        await file.delete(recursive: true);
      }
    },
    cancelOnError: true,
  );
}
