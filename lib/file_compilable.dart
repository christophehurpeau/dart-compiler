part of compiler;

class FileCompilable{
  final FileList fileList;
  
  /// The path after the src/ directory
  String _srcPath;
  
  /// The source file. This can change is the file is moved.
  File _srcFile;
  
  /// The destination file.
  File _outFile;
  
  bool processing = false;
  
  FileCompilable(FileList this.fileList, File this._srcFile, String this._srcPath){
    _outFile = new File(fileList.outPath + '/' + _srcPath); 
  }
  
  
  Future prepareThenProcess(){
    prepare().then((_) => process());
  }
  
  Future prepare(){
    return _outFile.parent.create(recursive: true);
  }
  
  Future process(){
    processing = true;
    return compile().then((_) => processing = false);
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