part of compiler;

class FileIgnored implements FileCompilable {
  final DirectoryCompiler compiler;
  final FileList fileList;
  final List<CompileError> errors = new UnmodifiableListView(const []);

  /// The path after the src/ directory
  final String srcPath;

  /// The source file. This can change is the file is moved.
  File _srcFile;
  /// The source file.
  File get srcFile => _srcFile;

  // outFile is always null
  File get outFile => null;
  File get _outFile => null;

  bool get isProcessing => false;

  final String extension;

  final String basename;

  FileIgnored(FileList fileList, this._srcFile, String srcPath, this.extension)
    : basename = Path.basename(srcPath),
      this.srcPath = srcPath,
      this.fileList = fileList,
      this.compiler = fileList.compiler;

  Future prepareThenCompile() {
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



  void set _outFile(File __outFile) {
    throw new UnsupportedError('');
  }

  void set _processing(bool __processing) {
    throw new UnsupportedError('');
  }

  bool get _processing => throw new UnsupportedError('');

  void set _modules(FileModuleList __modules) {
    throw new UnsupportedError('');
  }

  FileModuleList get _modules => throw new UnsupportedError('');

  void set _outExtension(String __outExtension) {
    throw new UnsupportedError('');
  }

  String get _outExtension => throw new UnsupportedError('');
}