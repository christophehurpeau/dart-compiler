part of compiler;

class FileList{
  final Map<String,FileCompilable> files = new HashMap();
  final Compiler compiler;
  
  FileList(Compiler this.compiler);

  String get srcPath => compiler.srcPath;
  String get outPath => compiler.outPath;
  Map get config => compiler.config;
  
  String filePath(String path){
    return path.substring(srcPath.length);
  }
  
  
  FileList appendFile(File file){
    String fPath = filePath(file.path);
    print('appendFile: $fPath');
    files.putIfAbsent(fPath,() => createFile(file,fPath)).prepareThenProcess();
    return this;
  }
  
  FileCompilable createFile(File file,String filePath){
    int lastDot = file.path.lastIndexOf('.');
    if(lastDot != -1){
      String extension = file.path.substring(lastDot +1);
      return createFileByExtension(file,filePath,extension);
    }
    return new FileCompilable(this,file,filePath);
  }
  
  FileCompilable createFileByExtension(File file,String filePath,String extension){
    return new FileCompilable(this,file,filePath);
  }
  
  FileList appendPath(String path){
    String fPath = filePath(path);
    print('appendFile: $fPath');
    files.putIfAbsent(fPath,() => createFile(new File(path),fPath)).prepareThenProcess();
  }
  
  FileList fileChanged(String path){
    String fPath = filePath(path);
    print('changedFile: $fPath');
    files[fPath].process();
  }

  FileList removePath(String path){
    String fPath = filePath(path);
    files.remove(fPath).delete();
  }
  
  void clear(){
    files.clear();
  }
}