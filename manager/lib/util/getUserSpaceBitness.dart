import 'dart:io';

import 'fluent.dart';

int getUserSpaceBitness() {
  final String _os = Platform.operatingSystem;
  final Map<String, String> _environment = Platform.environment;

  switch (_os) {
    case 'macos':
      if (Platform.version.contains('macos_ia32')) {
        return 32;
      } else if (Platform.version.contains('macos_x64')) {
        return 64;
      } else {
        return _getKernelBitness();
      }

      break;
    case 'windows':
      final wow64 = fluent(_environment['PROCESSOR_ARCHITEW6432']).stringValue;
      if (wow64.isNotEmpty) {
        return 32;
      }
      switch (_environment['PROCESSOR_ARCHITECTURE']) {
        case 'AMD64':
        case 'IA64':
          return 64;
      }
      return 32;
      break;
    case 'linux':
      return fluent(_exec('getconf', ['LONG_BIT'])).trim().parseInt().intValue;
  }
}

int _getKernelBitness() {
  final String _os = Platform.operatingSystem;
  final Map<String, String> _environment = Platform.environment;
  switch (_os) {
    case 'macos':
      if (fluent(_exec('uname', ['-m'])).trim().stringValue == 'x86_64') {
        return 64;
      }
      return 32;

    case 'windows':
      final wow64 = fluent(_environment['PROCESSOR_ARCHITEW6432']).stringValue;
      if (wow64.isNotEmpty) {
        return 64;
      }
      switch (_environment['PROCESSOR_ARCHITECTURE']) {
        case 'AMD64':
        case 'IA64':
          return 64;
      }
      return 32;
  }
  return null;
}

String _exec(String executable, List<String> arguments,
    {bool runInShell = false}) {
  try {
    final result =
        Process.runSync(executable, arguments, runInShell: runInShell);
    if (result.exitCode == 0) {
      return result.stdout.toString();
    }
  } catch (e) {}
  return null;
}
