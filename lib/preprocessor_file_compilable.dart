part of preprocessor_compiler;

class PreprocessorFileCompilable extends FileCompilable{
  final Preprocessor preprocessor;
  
  PreprocessorFileCompilable(FileList _fileList, File _srcFile, String _srcPath, String extension)
      : super(_fileList,_srcFile,_srcPath), preprocessor = new Preprocessor(extension);
  

  Future compile(){
    return this.preprocessor == null ? super.compile()
        : this.read().then((String content) => this.preprocessor.process(this.fileList.config['consts'], content))
          .then((String content) => this.write(content));
  }
}
