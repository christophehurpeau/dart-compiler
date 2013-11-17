library compiler;

import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:yaml/yaml.dart';
import 'package:path/path.dart' as Path;

part 'watcher.dart';
part 'file_compilable.dart';
part 'file_ignored.dart';
part 'file_list.dart';



main(){
  new Watcher(new Directory('.'),(Compiler compiler) => new FileList(compiler)).start();
}


typedef FileList FileListFactory(Compiler compiler);
FileList _fileListFactory(Compiler compiler) => new FileList(compiler);

class Compiler{
  static final String CONFIG_FILE_NAME = 'build.yaml';
  
  final Directory _directory;
  final Directory _srcDirectory;
  final Directory _outDirectory;
  
  FileList _fileList;
  YamlMap _config;
  
  Compiler(Directory directory, FileListFactory fileListFactory,
      { String srcName: 'src', String outName: 'out' }): 
    _directory = new Directory(Path.normalize(directory.absolute.path)), // directory.absolute should be set in a var
    _srcDirectory = new Directory(Path.normalize(directory.absolute.path)+'/' + srcName),
    _outDirectory = new Directory(Path.normalize(directory.absolute.path)+'/' + outName){
    _fileList = fileListFactory(this);
  }
  
  String get basePath => _directory.path;
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
      .then((_) => _outDirectory.create());
  }
  
  Future processAll(){
    _srcDirectory.list(recursive: true).forEach((FileSystemEntity entity){
      if(entity is File) _fileList.appendFile(entity);
    });
  }
  
  Future processFile(File file){
    return _fileList.get(file).prepareThenProcess();
  }
  
  Future removeFile(File file){
    return _fileList.get(file).delete();
  }
  
  void clean(){
    _fileList.clear();
    _outDirectory.delete(recursive: true);
  }
  
  void stop(){
    _fileList.clear();
  }
}