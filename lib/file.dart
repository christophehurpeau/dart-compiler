import 'dart:async';
import 'dart:io' hide File;
import 'dart:io' as Io show File;
import 'dart:convert';
import 'package:path/path.dart' show separator;

class File implements Io.File{
  final Io.File _file;

  File(String path): _file = new Io.File(separator == '/' ? path : path.replaceAll('/',separator));
  File.fromIoFile(Io.File this._file);
  
  Io.File get absolute => _file.absolute;

  Future<Io.File> create({bool recursive: false}) => _file.create(recursive: recursive);

  void createSync({bool recursive: false}) => _file.createSync(recursive: recursive);

  Future<FileSystemEntity> delete({bool recursive: false}) => _file.delete(recursive: recursive);

  void deleteSync({bool recursive: false}) => _file.deleteSync(recursive: recursive);

  Future<bool> exists() => _file.exists();

  bool existsSync() => _file.existsSync();

  bool get isAbsolute => _file.isAbsolute;
  
  Future<DateTime> lastModified() => _file.lastModified();

  DateTime lastModifiedSync() => _file.lastModifiedSync();

  Future<int> length() => _file.length();

  int lengthSync() => _file.lengthSync();

  Future<RandomAccessFile> open({FileMode mode: FileMode.READ})
    => _file.open(mode: mode);

  Stream<List<int>> openRead([int start, int end])
    => _file.openRead(start, end);

  RandomAccessFile openSync({FileMode mode: FileMode.READ})
    => _file.openSync(mode: mode);

  IOSink openWrite({FileMode mode: FileMode.WRITE, Encoding encoding: UTF8})
    => _file.openWrite(mode: mode, encoding: encoding);

  Directory get parent => _file.parent;

  String get path => _file.path;

  Future<List<int>> readAsBytes() => _file.readAsBytes();

  List<int> readAsBytesSync() => _file.readAsBytesSync();

  Future<List<String>> readAsLines({Encoding encoding: UTF8})
    => _file.readAsLines(encoding: encoding);

  List<String> readAsLinesSync({Encoding encoding: UTF8})
    => _file.readAsLinesSync(encoding: encoding);

  Future<String> readAsString({Encoding encoding: UTF8})
    => _file.readAsString(encoding: encoding);

  String readAsStringSync({Encoding encoding: UTF8})
    => _file.readAsStringSync(encoding: encoding);

  Future<Io.File> rename(String newPath) => _file.rename(newPath);

  Io.File renameSync(String newPath) => _file.renameSync(newPath);

  Future<String> resolveSymbolicLinks() => _file.resolveSymbolicLinks();

  String resolveSymbolicLinksSync() => _file.resolveSymbolicLinksSync();

  Future<FileStat> stat() => _file.stat();

  FileStat statSync() => _file.statSync();

  Stream<FileSystemEvent> watch({int events: FileSystemEvent.ALL, bool recursive: false})
    => _file.watch(events: events, recursive: recursive);

  Future<Io.File> writeAsBytes(List<int> bytes, {FileMode mode: FileMode.WRITE})
    => _file.writeAsBytes(bytes, mode:mode);

  void writeAsBytesSync(List<int> bytes, {FileMode mode: FileMode.WRITE}) 
    => _file.writeAsBytesSync(bytes, mode: mode);

  Future<Io.File> writeAsString(String contents, {FileMode mode: FileMode.WRITE, Encoding encoding: UTF8})
    => _file.writeAsString(contents, mode: mode, encoding: encoding);

  void writeAsStringSync(String contents, {FileMode mode: FileMode.WRITE, Encoding encoding: UTF8})
    => _file.writeAsStringSync(contents, mode: mode, encoding: encoding);
}