library compiler_module_stylus;

import 'dart:io';
import 'dart:convert';
import 'package:compiler/module.dart';

class StylusModule extends Module {
  FileModule getFileModuleForFile(FileCompilable file) {
    if (file.extension == 'styl')
      return new StylusFileModule(file);
  }
}

final stylusParseErrorRegExp = new RegExp(r'ParseError: (.*) in (.*) on line (\d+), column (\d+):', multiLine: false);

class StylusFileModule extends FileModule {
  @override
  final String outputExtension = 'css';
  
  StylusFileModule(FileCompilable file): super(file);
  
  @override
  Future<String> compile(String content){
    return Process.start('stylus',
        [//'--compress',// '--source-map',
                ], runInShell: true)
          .then((Process process){
            process.stdin.write(content);
            var stderr = '';
            process.stderr.transform(new Utf8Decoder()).listen((data) => stderr += data);
            var stdout = '';
            process.stdout.transform(new Utf8Decoder()).listen((data) => stdout += data);
            return process.exitCode.then((exitCode){
              if (exitCode != 0) {
                var match = stylusParseErrorRegExp.firstMatch(stderr);
                if (match != null) {
                  var error = new CompileError(file, message: match[1],
                      lineStart: int.parse(match[3]), columnStart: int.parse(match[4]));
                  file.errors.add(error);
                  throw error;
                } else {
                  throw new Exception("ExitCode = $exitCode\nSTDOUT\n${stdout}\n\nSTDERR\n${stderr}\n\nCONTENT\n$content");
                }
              }
              return stdout;
            });
          });
  }
}