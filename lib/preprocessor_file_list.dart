part of preprocessor_compiler;

class PreprocessorFileList extends FileList{
  PreprocessorFileList(Compiler compiler) : super(compiler);
  
  @override
  FileCompilable createFileByExtension(File file,String filePath,String extension){
    if(Preprocessor.types.contains(extension))
      return new PreprocessorFileCompilable(this,file,filePath,extension);
    return new FileCompilable(this,file,filePath);
  }
  
}