library compiler;

import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:yaml/yaml.dart';

part 'watcher.dart';
part 'file_compilable.dart';
part 'file_list.dart';



main(){
  new Watcher(new Directory('.'),(Compiler compiler) => new FileList(compiler)).start();
}


typedef FileList FileListFactory(Compiler compiler);
FileList _fileListFactory(Compiler compiler) => new FileList(compiler);

class Compiler{
  static final String CONFIG_FILE_NAME = 'build.yml';
  
  final Directory _directory;
  final Directory _srcDirectory;
  final Directory _outDirectory;
  
  FileList _fileList;
  YamlMap _config;
  
  Compiler(Directory directory, FileListFactory fileListFactory): 
    _directory = directory.absolute, 
    _srcDirectory = new Directory(directory.path+'/src'),
    _outDirectory = new Directory(directory.path+'/out'){
    _fileList = fileListFactory(this);
  }

  String get srcPath => _srcDirectory.path;
  String get outPath => _outDirectory.path;
  FileList get fileList => _fileList;
  Map get config => _config;
  
  Future _loadConfig(){
    Completer completer = new Completer();
    File configFile = new File(_directory.path + '/' + CONFIG_FILE_NAME);
    configFile.exists().then((bool exists){
      if(!exists) throw new Exception('no ' + CONFIG_FILE_NAME);
      return configFile.readAsString();
    }).then((String content){
      _config = loadYaml(content);
      completer.complete();
    });
    return completer.future;
  }
  
  Future start(){
    return _srcDirectory.exists().then((bool exists){
      if(!exists) throw new Exception('No src directory...');
      return this._loadConfig();
    })
      .then((_) => _outDirectory.create())
      .then((_) => this.process());
  }
  
  Future process(){
    _srcDirectory.list(recursive: true).forEach((FileSystemEntity entity){
      if(entity is File) _fileList.appendFile(entity);
    });
  }
  
  
  void stop(){
    _fileList.clear();
  }
}