library compiler;

import 'dart:io' hide File;
import 'dart:io' as Io show File;
import './file.dart';
import 'dart:async';
import 'dart:collection';
import 'package:yaml/yaml.dart';
import 'package:dart_events/dart_events.dart';
import 'package:path/path.dart' as Path;


part 'watcher.dart';
part 'file_compilable.dart';
part 'file_ignored.dart';
part 'file_list.dart';

typedef FileList FileListFactory(Compiler compiler);
FileList _fileListFactory(Compiler compiler) => new FileList(compiler);

class Compiler extends EventEmitter{
  static final String CONFIG_FILE_NAME = 'build.yaml';
  
  final Directory rootDirectory;
  final Directory srcDirectory;
  final Directory outDirectory;
  
  FileList _fileList;
  YamlMap _config;
  
  Compiler(Directory directory, FileListFactory fileListFactory,
      { String srcName: 'src', String outName: 'out' }): 
    rootDirectory = directory.absolute, // directory.absolute should be set in a var
    srcDirectory = new Directory(directory.absolute.path+'/' + srcName),
    outDirectory = new Directory(directory.absolute.path+'/' + outName){
    _fileList = fileListFactory(this);
  }
  
  String get basePath => rootDirectory.path;
  String get srcPath => srcDirectory.path;
  String get outPath => outDirectory.path;
  

  
  FileList get fileList => _fileList;
  Map get config => _config;
  
  Future _loadConfig() {
    assert(_config == null);
    Completer completer = new Completer();
    File configFile = new File(basePath + '/' + CONFIG_FILE_NAME);
    configFile.exists().then((bool exists){
      if(!exists) throw new Exception('no ' + CONFIG_FILE_NAME);
      return configFile.readAsString();
    }).then((String content){
      _config = loadYaml(content);
      completer.complete();
    });
    return completer.future;
  }
  
  Future start() {
    return srcDirectory.exists().then((bool exists){
      if(!exists) throw new Exception('No src directory...');
      return this._loadConfig();
    })
      .then((_) => outDirectory.create());
  }
  
  Future processAll() {
    emit('processing', null);
    emit('beforeProcess', null);
    srcDirectory.list(recursive: true).forEach((FileSystemEntity entity){
      if(entity is Io.File) _fileList.appendFile(new File.fromIoFile(entity));
      else if(entity is Directory) ;
      else throw new Exception(entity.toString());
    }).then((_){
      emit('afterProcess', null);
      emit('completed', null);
    });
  }
  
  Future processFile(File file) {
    emit('beforeProcess', null);
    return _fileList.get(file).prepareThenProcess()
        .then((_){
          emit('afterProcess', null);
          emit('completed', null);
        });
  }
  
  Future removeFile(File file) {
    return _fileList.get(file).delete();
  }
  
  void clean() {
    _fileList.clear();
    outDirectory.delete(recursive: true);
  }
  
  void stop() {
    emit('beforeStop', null);
    _fileList.clear();
    emit('afterStop', null);
  }
}