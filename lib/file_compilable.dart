part of compiler;

class FileCompilable{
  final Compiler compiler;
  final FileList fileList;
  
  /// The path after the src/ directory
  final String srcPath;
  
  /// The source file. This can change is the file is moved.
  File _srcFile;
  
  /// The destination file.
  File _outFile;
  
  bool _processing = false;
  
  final String extension;
  
  final String basename;
  
  FileCompilable(FileList fileList, this._srcFile, String srcPath, this.extension)
      : basename = Path.basename(srcPath),
        this.srcPath = srcPath,
        this.compiler = fileList.compiler,
        this.fileList = fileList
      {
    _outFile = new File(fileList.outPath + '/' + srcPath); 
  }
  
  bool get isProcessing => _processing;
  
  
  Future prepareThenProcess(){
    return prepare().then((_) => process());
  }
  
  Future prepare(){
    compiler.emit('file.beforePrepare', [this]);
    compiler.emit('file.prepare', [this]);
    return _outFile.parent.create(recursive: true)
        .then((_) => compiler.emit('file.afterPrepare', [this]));
  }
  
  Future process(){
    compiler.emit('file.beforeProcess', [this]);
    _processing = true;
    compiler.emit('file.process', [this]);
    return compile().then((_){
      compiler.emit('file.afterProcess', [this]);
      _processing = false;
    });
  }
  
  Future compile(){
    compiler.emit('file.beforeCompile', [this]);
    compiler.emit('file.compile', [this]);
    return this.copy().then((_) => compiler.emit('file.afterCompile', [this]));
  }
  
  Future read(){
    return _srcFile.readAsString();
  }
  
  Future write(String content){
    IOSink ioSink = _outFile.openWrite();
    ioSink.write(content);
    return ioSink.close();
  }
  
  Future copy(){
    IOSink ioSink = _outFile.openWrite();
    return ioSink.addStream(_srcFile.openRead()).then((_) => ioSink.close());
  }
  
  Future delete(){
    return _outFile.delete();
  }
}