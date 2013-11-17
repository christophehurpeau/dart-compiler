part of compiler;

class FileCompilable{
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
  
  FileCompilable(this.fileList, this._srcFile, String srcPath, this.extension)
    : basename = Path.basename(srcPath), this.srcPath = srcPath
    {
      _outFile = new File(fileList.outPath + '/' + srcPath);
    }
  
  bool get isProcessing => _processing;
  
  Future prepareThenProcess(){
    prepare().then((_) => process());
  }
  
  Future prepare(){
    return _outFile.parent.create(recursive: true);
  }
  
  Future process(){
    _processing = true;
    return compile().then((_) => _processing = false);
  }
  
  Future compile(){
    return this.copy();
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