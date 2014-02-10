library compiler_module_preprocessor;

import 'package:compiler/module.dart';
import 'package:preprocessor/preprocessor.dart';

class PreprocessorModule extends Module {
  FileModule getFileModuleForFile(FileCompilable file) {
    if(Preprocessor.types.contains(file.extension))
      return new PreprocessorFileModule(file);
  }
}

class PreprocessorFileModule extends FileModule {
  Preprocessor preprocessor;
  
  PreprocessorFileModule(FileCompilable file) : super(file),
      preprocessor = new Preprocessor(file.extension);
  

  @override
  Future<String> compile(String content){
    assert(content != null);
    return this.preprocessor.process(file.fileList.config['consts'], content);
  }
}