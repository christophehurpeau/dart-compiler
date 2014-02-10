import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:compiler/compiler.dart';
import 'package:compiler/module.dart';



main(List<String> args){
  print('Start watching');
  Directory path = args.length > 0 ? new Directory(args[0]) : Directory.current;
  var fileListFactory = (DirectoryCompiler compiler) => new FileList(compiler);
  var compiler = new DirectoryCompiler(path, new ModuleList(),
      fileListFactory, srcName:'web.src', outName:'web');
  var watcher = new DirectoryWatcher.fromCompiler(compiler).start();

  var server = new Server(path.path);
  if (server.exists()) {
    compiler.on('processing', server.stop);
    compiler.on('completed', server.start);
  }
}


class Server{
  final File serverStartFile;

  Server(String path) : serverStartFile = new File('$path/bin/server.dart');

  bool exists() => serverStartFile.existsSync();


  Process _process;
  Future _future;

  void start(){
    print('Start server');
    stop();

    _future = Process.start('dart', [serverStartFile.absolute.path])
        .then((Process process){
          _process = process;

          process.stdout.transform(new Utf8Decoder())
            .transform(new LineSplitter())
            .listen((String line) => print('[server] $line'));
          process.stderr.transform(new Utf8Decoder())
            .transform(new LineSplitter())
            .listen((String line) => print('[server] [err] $line'));

          process.exitCode.then((exitCode) {
            print('[server] exit code: $exitCode');
          });
        });
  }

  void stop(){
    print('Stop server');
    if (_future != null) {
      //_future.cancel();
      _future.then((_) => stop());
    }
    if (_process != null) {
      _process.kill();
    }
  }
}
