import 'package:compiler/compiler.dart';
import 'package:compiler/preprocessor_compiler.dart';
import 'package:editor_build/editor_build.dart';
import 'dart:io';


build(List<String> args, [FileListFactory fileListFactory]){
  final opts = BuildOptions.parse(args);
  
  if (fileListFactory == null) {
    fileListFactory = (Compiler compiler) => new PreprocessorFileList(compiler);
  }
  
  var compiler = new Compiler(new Directory('.'), fileListFactory, srcName:'web.src', outName:'web');
  compiler.start().then((_){
  
    if(opts.clean) compiler.clean();
    
    if (opts.full) {
      compiler.processAll();
    } else {
      Function map = (String folderName, Function callback){
        return (String filePath){
          if (!filePath.startsWith('$folderName/')) return;
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
