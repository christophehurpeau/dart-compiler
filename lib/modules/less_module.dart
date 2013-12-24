library compiler_module_less;

import 'dart:io';
import 'dart:math';
import 'package:compiler/module.dart';
import 'package:path/path.dart' as Path;

class LessModule extends Module {
  FileModule getFileModuleForFile(FileCompilable file) {
    if (file.extension == 'less')
      return new LessFileModule(file);
  }
}

final random = new Random();
final lessParseErrorRegExp = new RegExp(r'ParseError: (.*) in (.*) on line (\d+), column (\d+):', multiLine: false);

class LessFileModule extends FileModule {
  @override
  final String outputExtension = 'css';
  
  LessFileModule(FileCompilable file): super(file);
  
  @override
  Future<String> compile(String content){
    //C:\Users\Christophe\AppData\Roaming\npm\lessc
    return Process.run('lessc',
        ['--no-color', '--clean-css',// '--source-map',
                file.srcFile.path, file.outFile.path], runInShell: true)
          .then((ProcessResult result){
            if (result.exitCode != 0){
              var match = lessParseErrorRegExp.firstMatch(result.stderr);
              if (match != null) {
                var error = new CompileError(file, message: match[1],
                    lineStart: int.parse(match[3]), columnStart: int.parse(match[4]));
                file.errors.add(error);
                throw error;
              } else {
                throw new Exception("STDOUT\n${result.stdout}\n\nSTDERR\n${result.stderr}");
              }
            }
            return file.outFile.readAsString();
          });
  }
}