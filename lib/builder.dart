import 'package:compiler/compiler.dart';
import 'dart:io';


build(List<String> args){
  new Compiler(new Directory('.'),(Compiler compiler) => new FileList(compiler)).start();
}
