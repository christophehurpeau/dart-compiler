part of compiler;

class FileCompilable{
  final DirectoryCompiler compiler;
  final FileList fileList;
  
  /// The path after the src/ directory
  final String srcPath;
  
  /// The source file. This can change is the file is moved.
  File _srcFile;
  
  /// The destination file.
  File _outFile;
  
  /// Modules
  FileModuleList _modules;
  
  bool _processing = false;
  
  final String extension;
  
  final String basename;
  
  String _outExtension;
  
  final List<CompileError> errors = [];

  File get srcFile => _srcFile;
  File get outFile => _outFile;
  
  FileCompilable(FileList fileList, this._srcFile, String srcPath, this.extension)
      : basename = Path.basename(srcPath),
        this.srcPath = srcPath,
        this.compiler = fileList.compiler,
        this.fileList = fileList
      {
    
    _modules = new FileModuleList(this);
    
    _outExtension = _modules.outputExtension(extension);
    
    _outFile = new File(fileList.outPath + (_outExtension == null ? srcPath 
              : srcPath.substring(0, srcPath.length - extension.length) + _outExtension)); 
  }
  
  bool get isProcessing => _processing;
  
  
  Future prepareThenCompile(){
    errors.clear();
    return prepare().then((_) => compile());
  }
  
  Future prepare(){
    return _modules.beforePrepare()
      .then((_) => _modules.prepare())
      .then((_) => _outFile.parent.create(recursive: true))
      .then((_) => _modules.afterPrepare());
  }

  Future compile(){
    _processing = true;
    if (_modules.isEmpty) {
      return this.copy()
          .then((_) => _processing = false);
    } else {
        return _modules.beforeRead()
          .then((_) => _modules.read())
          .then((result) => result != null ? result : this.read())
          .then((result) => _modules.afterRead(result))
//          .then((String result){
//            if(extension == 'scss' || extension == 'css')
//              print('afterRead = $result');
//            return result;
//          })
          .then((result) => _modules.beforeCompile(result))
//          .then((String result){
//            if(extension == 'scss' || extension == 'css')
//              print('beforeCompile = $result');
//            return result;
//          })
          .then((result) => _modules.compile(result))
//          .then((String result){
//            if(extension == 'scss' || extension == 'css')
//              print('compile = $result');
//            return result;
//          })
          .then((result) => _modules.afterCompile(result))
//          .then((String result){
//            if(extension == 'scss' || extension == 'css')
//              print('afterCompile = $result');
//            return result;
//          })
          .then((result) => _modules.beforeWrite(result))
//          .then((String result){
//            if(extension == 'scss' || extension == 'css')
//              print('beforeWrite = $result');
//            return result;
//          })
          .then((result) => write(result))
//          .then((String result){
//            throw new Exception('write = $result');
//            return result;
//          })
          .then((result) => _modules.afterWrite(result))
          //.catchError((e){}, test: (e) => e is CompileError);
          //we could catch the error and let the editor be aware of the error
          //but it doesn't work
          //so instead with an exception this is displayed in the console :)
          ;
    }
  }
  
  Future<String> read(){
    return _srcFile.readAsString();
  }
  
  Future<String> write(String content){
    //assert(content != null);
    IOSink ioSink = _outFile.openWrite();
    ioSink.write(content);
    return ioSink.close()
        .then((_) => content);
  }
  
  Future copy(){
    IOSink ioSink = _outFile.openWrite();
    return ioSink.addStream(_srcFile.openRead()).then((_) => ioSink.close());
  }
  
  Future delete(){
    return _outFile.delete();
  }
}