part of compiler;

class FileList{
  final Map<String,FileCompilable> files = new HashMap();
  final DirectoryCompiler compiler;
  
  FileList(DirectoryCompiler this.compiler);

  String get srcPath => compiler.srcPath;
  String get outPath => compiler.outPath;
  Map get config => compiler.config;
  
  String filePath(String path){
    return path.substring(srcPath.length).replaceAll(Path.separator, r'/');
  }

  FileCompilable createFile(File file,String filePath){
    String extension = Path.extension(file.path);
    if (this.isIgnored(file, filePath, extension)) {
      return new FileIgnored(this, file, filePath, extension);
    }
    
    if (extension.isEmpty) {
      return new FileCompilable(this, file, filePath, extension);
    } else {
      return createFileByExtension(file, filePath, extension.substring(1));
    }
  }
  
  bool isIgnored(File file, String filePath, String extension){
    String basename = Path.basename(filePath);
    String firstLetter = basename[0];
    if (firstLetter == '.' || firstLetter == '#') {
      return true;
    }
    
    if (basename.endsWith('~')) {
      return true;
    }

    if (filePath.contains('${Path.separator}packages${Path.separator}')) {
      return true;
    }
    
    return false;
  }
  
  FileCompilable get(File file){
    String fPath = filePath(file.path);
    return files.putIfAbsent(fPath,() => createFile(file,fPath));
  }
  
  Future appendFile(File file){
    FileCompilable fc = get(file);
    return fc.prepareThenCompile();
  }
  
  FileCompilable createFileByExtension(File file,String filePath,String extension){
    return new FileCompilable(this, file, filePath, extension);
  }
  
  Future appendPath(String path){
    String fPath = filePath(path);
    return files.putIfAbsent(fPath,() => createFile(new File(path),fPath)).prepareThenCompile();
  }
  
  Future fileChanged(String path){
    String fPath = filePath(path);
    return files[fPath].compile();
  }

  Future removePath(String path){
    String fPath = filePath(path);
    return files.remove(fPath).delete();
  }
  
  void clear(){
    files.clear();
  }
}