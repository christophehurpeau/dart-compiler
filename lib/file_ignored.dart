part of compiler;

class FileIgnored implements FileCompilable {
  final FileList fileList;
  
  /// The path after the src/ directory
  final String srcPath;
  
  /// The source file. This can change is the file is moved.
  File _srcFile;
  
  // outFile is always null
  File get outFile => null;
  
  bool get isProcessing => false;

  final String extension;
  
  final String basename;

  FileIgnored(this.fileList, this._srcFile, String srcPath, this.extension)
    : basename = Path.basename(srcPath), this.srcPath = srcPath;

  Future prepareThenProcess() {
    return new Future.value();
  }

  Future prepare() {
    return new Future.value();
  }

  Future process() {
    return new Future.value();
  }

  Future compile() {
    return new Future.value();
  }


  Future read() {
    return new Future.value();
  }

  Future write(String content) {
    return new Future.value();
  }

  Future copy() {
    return new Future.value();
  }

  Future delete() {
    return new Future.value();
  }


  File get _outFile => null; // TODO implement this getter

  void set _outFile(File __outFile) {
    // TODO implement this setter
  }

  void set _processing(bool __processing) {
    // TODO implement this setter
  }

  bool get _processing => null; // TODO implement this getter
}