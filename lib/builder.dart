import 'dart:io' hide File;
import 'dart:io' as Io show File;
import './file.dart';

import 'package:compiler/compiler.dart';
import 'package:editor_build/editor_build.dart';
import 'package:path/path.dart' as Path;


build(List<String> args, [FileListFactory fileListFactory]){
  final opts = BuildOptions.parse(args);
  
  if (fileListFactory == null) {
    fileListFactory = (DirectoryCompiler compiler) => new FileList(compiler);//Preprocessor
  }
  
  final directory = new Directory('.');
//  final modules = new ModuleList.searchInPackages(
//      new Directory('${directory.path}${Path.separator}packages'));
  final modules = new ModuleList();
  
  //TODO : several compilers ?
  var compiler = new DirectoryCompiler(directory, modules, fileListFactory,
      srcName:'web.src', outName:'web');
  compiler.start().then((_){
  
    if(opts.clean) compiler.clean();
    
    Future _done;
    if (opts.full || args.length == 0) {
      _done = compiler.processAll();
    } else {
      Function map = (String folderName, Function callback){
        return (String filePath){
          if (!filePath.startsWith('${folderName}${Path.separator}')) return new Future.value();
          return callback(new File('${compiler.basePath}/${filePath}'));
        };
      };
      
      List<Future> futures = opts.changed.map(map('web.src',compiler.processFile));
      _done = Future.wait(futures)
        .then((_) => Future.wait(opts.removed.map(map('web.src',compiler.removeFile))));
    }
    
    _done.then((_){
      Iterable files = compiler.fileList.files.values;
      
      final result = new BuildResult();
      
      for(FileCompilable file in files){
        result.addInfo('web.src${file.srcPath}', 1, 'File compiled ' + (new DateTime.now()).toString());
        for (CompileError error in file.errors){
          if (error.type == COMPILE_ERROR) {
            result.addError('web.src${file.srcPath}', error.lineStart, error.message,
                charStart: error.columnStart, charEnd: error.columnEnd);
          } else if (error.type == COMPILE_WARNING) {
            result.addWarning('web.src${file.srcPath}', error.lineStart, error.message,
                charStart: error.columnStart, charEnd: error.columnEnd);
          } else if (error.type == COMPILE_INFO) {
            result.addInfo('web.src${file.srcPath}', error.lineStart, error.message,
                charStart: error.columnStart, charEnd: error.columnEnd);
          }
        }
      }
      /*result.addError('foo.html', 23,'no ID found');
      result.addWarning('foo.html', 24,'no ID found', charStart: 123, charEnd: 130);
      result.addInfo('foo.html', 25,'no ID found');
      result.addMapping('foo.html', 'out/foo.html');
       */
      //if (result.toString() != '[]') throw new Exception(result);
      print(result);
    });
  });
}
