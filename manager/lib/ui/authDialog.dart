import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:tidy_manager/ui/smoothDialog.dart';
import 'package:tidy_manager/util/checkPassword.dart';
import 'package:tidy_manager/util/statusCodeToMessage.dart';

import '../global.dart';

void authDialog(dynamic context, TextEditingController _sudoPasswordInputCtrl) {
  createSmoothDialog(
    context,
    "인증 필요",
    TextField(
      obscureText: true,
      controller: _sudoPasswordInputCtrl,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: "사용자의 암호 또는 sudo 암호를 입력해주세요.",
        labelText: "엔진 상태를 가져오려면 인증이 필요합니다.",
      ),
    ),
    Row(
      children: [
        new TextButton(
          child: new Text("도움말"),
          onPressed: () async {
            return createSmoothDialog(
              context,
              "도움말",
              RichText(
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(fontSize: 15),
                  children: <TextSpan>[
                    TextSpan(
                      text: "Q. 왜 macOS나 Linux 에서만 암호를 요구하나요?\n",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          "A. 윈도우에서는 UAC(User Account Control, 사용자 계정 컨트롤) 창을 띄워서 관리자 권한을 요청할 수 있습니다. 하지만 macOS나 Linux 에서는 그런 방법을 이용하기 힘듭니다.\n\n",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    TextSpan(
                      text: "Q. 입력한 암호가 다른곳으로 전송되나요?\n",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          "A. 입력한 암호는 어떠한 곳으로도 전송되지 않습니다. 오직 앱 내부에서만 종료되기 전까지 기억되며, 종료되면 소멸합니다.\n\n",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    TextSpan(
                      text: "Q. 암호를 제대로 입력했는데 왜 틀렸다고 하나요?\n",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          "A. 해당 계정에 관리자 권한 또는 sudo 명령어를 사용할 수 있는 권한이 없는 것 같습니다. 관리자 권한 또는 sudo 명령어를 사용할 수 있는 권한이 있는 계정으로 로그인 한 뒤, 다시 시도해주세요.",
                      style: TextStyle(fontWeight: FontWeight.normal),
                    )
                  ],
                ),
              ),
              new TextButton(
                child: new Text("닫기"),
                onPressed: () async {
                  return Navigator.pop(context);
                },
              ),
              Icon(Icons.error),
              false,
            );
          },
        ),
        new TextButton(
          child: new Text("확인"),
          onPressed: () async {
            if (_sudoPasswordInputCtrl.text.trim() == "") {
              return createSmoothDialog(
                context,
                "인증 실패",
                Text("암호를 입력해주세요."),
                new TextButton(
                  child: new Text("확인"),
                  onPressed: () async {
                    return Navigator.pop(context);
                  },
                ),
                Icon(Icons.error),
                false,
              );
            }
            var _result = await checkPassword(_sudoPasswordInputCtrl.text);
            if (!_result[0] && _result[1] == "IGNORE") {
              return createSmoothDialog(
                context,
                "잠시만요!",
                Text("진정하세요! 암호를 체크하고 있어요!"),
                new TextButton(
                  child: new Text("확인"),
                  onPressed: () async {
                    return Navigator.pop(context);
                  },
                ),
                Icon(Icons.error),
                false,
              );
            }
            if (!_result[0] && _result[1] != "IGNORE") {
              return createSmoothDialog(
                context,
                "인증 실패",
                Text(statusCodeToMessage(_result[1])),
                new TextButton(
                  child: new Text("확인"),
                  onPressed: () async {
                    return Navigator.pop(context);
                  },
                ),
                Icon(Icons.error),
                false,
              );
            } else {
              userPasswordForSudo = _sudoPasswordInputCtrl.text;
              Navigator.pop(context);
              return Phoenix.rebirth(context);
            }
          },
        ),
      ],
    ),
    Icon(Icons.vpn_key),
    false,
  );
}
