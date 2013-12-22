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
  
  var compiler = new DirectoryCompiler(directory, modules, fileListFactory,
      srcName:'web.src', outName:'web');
  compiler.start().then((_){
  
    if(opts.clean) compiler.clean();
    
    if (opts.full || args.length == 0) {
      compiler.processAll();
    } else {
      Function map = (String folderName, Function callback){
        return (String filePath){
          if (!filePath.startsWith('${folderName}${Path.separator}')) return;
          if (filePath.startsWith('${folderName}${Path.separator}packages${Path.separator}')) return;
          callback(new File('${compiler.basePath}/$filePath'));
        };
      };
      
      ;
      opts.changed.forEach(map('web.src',compiler.processFile));
      opts.removed.forEach(map('web.src',compiler.removeFile));
    }
    
    final result = new BuildResult();
    
    /*result.addError('foo.html', 23,'no ID found');
  result.addWarning('foo.html', 24,'no ID found', charStart: 123, charEnd: 130);
  result.addInfo('foo.html', 25,'no ID found');
  result.addMapping('foo.html', 'out/foo.html');
  */
    print(result);
  });
}
