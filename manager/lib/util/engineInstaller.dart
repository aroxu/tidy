import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tidy_manager/model/githubReleaseDataMode.dart';
import 'package:tidy_manager/ui/smoothDialog.dart';
import 'package:tidy_manager/util/engineDownloader.dart';
import 'package:tidy_manager/util/getUserSpaceBitness.dart';

import '../global.dart';

Future<void> engineInstaller(dynamic context) async {
  http.Response getLatestReleaseFromGitHub;
  await _showSnackBar(
    context,
    Row(
      children: [
        Icon(
          Icons.cloud_download,
          color: Colors.black,
        ),
        SizedBox(width: 4),
        Flexible(
          child: Text('엔진 다운로드 및 설치중...'),
        ),
      ],
    ),
    Duration(days: 365),
  );
  try {
    getLatestReleaseFromGitHub = await http
        .get("https://api.github.com/repos/aroxu/tidy/releases/latest");
  } catch (_) {
    createSmoothDialog(
      context,
      "연결 할 수 없음",
      Text("네트워크 연결을 확인한 후 다시 시도해주세요.\nManager를 종료합니다."),
      new TextButton(
        child: new Text("확인"),
        onPressed: () async {
          Navigator.pop(context);
          return SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
      ),
      Icon(Icons.warning),
      false,
    );
  }
  final String latestReleaseData = getLatestReleaseFromGitHub.body;
  if (getLatestReleaseFromGitHub.statusCode == 200) {
    var fetchedReleaseData =
        GithubReleaseDataModel.fromJson(jsonDecode(latestReleaseData));
    String _engineDownloadURL;
    if (Platform.isMacOS) {
      if (getUserSpaceBitness() == 64) {
        fetchedReleaseData.assets.forEach((element) {
          if (element.name.contains("engine_darwin_x64")) {
            _engineDownloadURL = element.browserDownloadUrl;
          }
        });
      } else {
        return createSmoothDialog(
          context,
          "엔진을 찾을 수 없음",
          Text("이 디바이스와 호환되는 엔진을 찾을 수 없습니다.\nManager를 종료합니다."),
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
      }
    } else if (Platform.isWindows) {
      if (getUserSpaceBitness() == 64) {
        fetchedReleaseData.assets.forEach((element) {
          if (element.name.contains("engine_win_x64")) {
            _engineDownloadURL = element.browserDownloadUrl;
          }
        });
      } else if (getUserSpaceBitness() == 32) {
        fetchedReleaseData.assets.forEach((element) {
          if (element.name.contains("engine_win_x32")) {
            _engineDownloadURL = element.browserDownloadUrl;
          }
        });
      } else {
        return createSmoothDialog(
          context,
          "엔진을 찾을 수 없음",
          Text("이 디바이스와 호환되는 엔진을 찾을 수 없습니다.\nManager를 종료합니다."),
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
      }
    } else if (Platform.isLinux) {
      if (getUserSpaceBitness() == 64) {
        fetchedReleaseData.assets.forEach((element) {
          if (element.name.contains("engine_linux_x64")) {
            _engineDownloadURL = element.browserDownloadUrl;
          }
        });
      } else if (getUserSpaceBitness() == 32) {
        fetchedReleaseData.assets.forEach((element) {
          if (element.name.contains("engine_linux_x32")) {
            _engineDownloadURL = element.browserDownloadUrl;
          }
        });
      } else {
        return createSmoothDialog(
          context,
          "엔진을 찾을 수 없음",
          Text("이 디바이스와 호환되는 엔진을 찾을 수 없습니다.\nManager를 종료합니다."),
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
      }
    } else {
      return createSmoothDialog(
        context,
        "자동 설치 불가",
        Text("이 OS는 자동설치를 지원하지 않습니다.\n대신 수동설치 해주세요."),
        new TextButton(
          child: new Text("확인"),
          onPressed: () async {
            try {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            } catch (e) {}
            installingEngine = false;
            return Navigator.pop(context);
          },
        ),
        Icon(Icons.warning),
        false,
      );
    }
    await engineDownloader(context, _engineDownloadURL);
  } else {
    createSmoothDialog(
      context,
      "연결 할 수 없음",
      Text("업데이트 서버와 연결할 수 없습니다.\nGitHub Issue를 생성하여 개발자에게 알려주세요."),
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
  }
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
