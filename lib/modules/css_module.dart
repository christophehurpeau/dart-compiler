library compiler_module_css;

import 'package:compiler/module.dart';
import 'package:source_maps/source_maps.dart';
import 'package:csslib/parser.dart' as CssParser;
import 'package:csslib/visitor.dart' as CssVisitor;


class CssModule extends Module {
  FileModule getFileModuleForFile(FileCompilable file) {
    if (file.extension == 'css' || file.extension == 'scss')
      return new CssFileModule(file);
  }
}

class CssFileModule extends FileModule {
  @override
  final String outputExtension = 'css';
  
  CssFileModule(FileCompilable file): super(file);
  
  @override
  Future<String> compile(String content){
    var file = new SourceFile.text(super.file.srcPath, content);
    
    // Parse the CSS.
    // var tree = CssParser.parse(contents);
    // CssParser.analyze([tree]);
    var tree = CssParser.compile(content, nested:true, polyfill: true);

    // Emit the processed CSS.
    var emitter = new CssVisitor.CssPrinter();
    emitter.visitTree(tree, pretty: false);

    var compiledCss = emitter.toString();
    
    return new Future.value(compiledCss);
  }
}