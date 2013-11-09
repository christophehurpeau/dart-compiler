library preprocessor_compiler;

import 'package:compiler/compiler.dart';
import 'package:preprocessor/preprocessor.dart';
import 'dart:io';
import 'dart:async';

part 'preprocessor_file_list.dart';
part 'preprocessor_file_compilable.dart';

main(){
  new Watcher(new Directory('.').absolute,(Compiler compiler)
      => new PreprocessorFileList(compiler)).start();
}

