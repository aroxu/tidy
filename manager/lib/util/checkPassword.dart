import 'package:process_run/shell.dart';

import '../global.dart';

Future<List<dynamic>> checkPassword(String password) async {
  List<dynamic> _result;

  if (isCheckingPassword) {
    _result = [false, "IGNORE"];
  } else {
    isCheckingPassword = true;
    await run('sh -c "echo \'$password\' | sudo -S whoami"').then(
      (result) {
        var out = result.outLines.toString();
        if (out.contains("root")) {
          _result = [true];
        } else
          _result = [false, "WRONG_PASS"];
      },
    ).catchError(
      (_) {
        _result = [false, "WRONG_PASS"];
      },
    );
    isCheckingPassword = false;
  }
  return _result;
}
