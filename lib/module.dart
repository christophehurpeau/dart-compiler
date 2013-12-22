library compiler_module;

import 'dart:io';
import 'dart:async';
export 'dart:async';
import 'package:compiler/compiler.dart';
export 'package:compiler/compiler.dart';

import 'package:compiler/modules/preprocessor_module.dart';
import 'package:compiler/modules/css_module.dart';
import 'package:compiler/modules/less_module.dart';


import 'package:path/path.dart' as Path;

class ModuleList {
  final List<Module> modules = [];
  
  ModuleList() {
    modules.add(new PreprocessorModule());
    modules.add(new CssModule());
    //modules.add(new LessModule());
  }
  
  ModuleList.searchInPackages(Directory packageDirectory) {
    packageDirectory.list(recursive: false).forEach((Directory package){
      String packageName = Path.basename(package.path);
      if (packageName.startsWith('compiler_module_')) {
        // TODO inject in there ... modules.add()
        
      }
    });
    assert(modules.isNotEmpty);
  }

  List<FileModule> modulesForFile(FileCompilable file) {
    assert(modules.isNotEmpty);
    var list = [];
    for(Module module in modules) {
      var fileModule = module.getFileModuleForFile(file);
      if (fileModule != null) {
        list.add(fileModule);
      }
    }
    
    return list;
  }
}

typedef Future<String> FileModuleCallback(FileModule fileModule, String content);

class FileModuleList {
  final FileCompilable file;
  List<FileModule> _modules;
  
  bool get isEmpty => _modules.isEmpty;
  
  FileModuleList(this.file) {
    _modules = file.compiler.modules.modulesForFile(file);
  }
  

  String outputExtension(String srcFileExtension) {
    for (FileModule fileModule in _modules) {
      var outputExtension = fileModule.outputExtension;
      if (outputExtension != null) {
        return outputExtension;
      }
    }
  }
  
  Future beforePrepare()
    => Future.forEach(_modules, (fileModule) => fileModule.beforePrepare());

  Future prepare()
    => Future.forEach(_modules, (fileModule) => fileModule.prepare());

  Future afterPrepare()
    => Future.forEach(_modules, (fileModule) => fileModule.afterPrepare());
  

  Future beforeRead()
    => Future.forEach(_modules, (fileModule) => fileModule.beforeRead());

  Future<String> read() {
    for (FileModule fileModule in _modules) {
      if (fileModule.canRead) {
        return fileModule.read();
      }
    }
    return new Future.value(null);
  }
       
  Future<String> futureForEachAndKeepResult(String content, FileModuleCallback callback) {
    assert(content != null);
    var _done = new Future.value(content);
    for (FileModule fileModule in _modules) {
      _done = _done.then((String content){
        assert(content != null);
        return callback(fileModule, content);
      });
    }
    return _done;
  }
  

  Future<String> afterRead(String content)
    => futureForEachAndKeepResult(content, (fileModule, content) => fileModule.afterRead(content));

  
  Future<String> beforeCompile(String content)
    => futureForEachAndKeepResult(content, (fileModule, content) => fileModule.beforeCompile(content));

  Future<String> compile(String content)
    => futureForEachAndKeepResult(content, (fileModule, content) => fileModule.compile(content));

  Future<String> afterCompile(String content)
    => futureForEachAndKeepResult(content, (fileModule, content) => fileModule.afterCompile(content));

  
  Future<String> beforeWrite(String content)
    => futureForEachAndKeepResult(content, (fileModule, content) => fileModule.beforeWrite(content));

  Future afterWrite(String content)
    => Future.forEach(_modules, (fileModule) => fileModule.afterWrite(content));

}

abstract class Module {
  FileModule getFileModuleForFile(FileCompilable file);
}

abstract class FileModule {
  final FileCompilable file;
  
  FileModule(this.file);

  
  String get outputExtension => null;
  bool get canRead => false;
  
  
  Future beforePrepare() => new Future.value();

  Future prepare() => new Future.value();

  Future afterPrepare() => new Future.value();
  

  Future beforeRead() => new Future.value();
  
  Future read() => null;

  Future<String> afterRead(String content) => new Future.value(content);

  
  Future<String> beforeCompile(String content) => new Future.value(content);

  Future<String> compile(String content) => new Future.value(content);

  Future<String> afterCompile(String content) => new Future.value(content);

  
  Future<String> beforeWrite(String content) => new Future.value(content);

  Future afterWrite(String content) => new Future.value();

}