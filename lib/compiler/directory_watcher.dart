part of compiler;

class DirectoryWatcher{
  final DirectoryCompiler compiler;
  
  final List<StreamSubscription<FileSystemEvent>> _watchers = new List();
  
  DirectoryWatcher(Directory directory, FileListFactory fileListFactory)
      : this.fromCompiler( new DirectoryCompiler(directory, fileListFactory) );
  
  DirectoryWatcher.fromCompiler(DirectoryCompiler this.compiler){
    compiler.on('beforeStop',(_){
      _watchers.forEach((w) => w.cancel());
      _watchers.clear();
    });
  }
  
  

  String get basePath => compiler.basePath;
  String get srcPath => compiler.srcPath;
  String get outPath => compiler.outPath;
  FileList get fileList => compiler.fileList;
  Map get config => compiler.config;
  
  Future start(){
    if(this._watchers.isNotEmpty) this.stop();
    
    compiler.start().then((_){
      this._watchers.add(compiler.rootDirectory
          .watch(events: FileSystemEvent.MODIFY, recursive: false)
            .listen((FileSystemEvent event){
              if((event as FileSystemModifyEvent).contentChanged){
                if(event.path.endsWith('/' + DirectoryCompiler.CONFIG_FILE_NAME)){
                  this.stop();
                  compiler._loadConfig().then((_) => this.start());
                }
              }
            }));

      this._watchers.add(compiler.srcDirectory
          .watch(events: FileSystemEvent.ALL, recursive: true)
            .listen(_fileSystemEvent));
    });
  }
  

  Timer _completedTimer;
  
  void deferredCompleted(_) {
    if (_completedTimer == null || !_completedTimer.isActive) {
      _completedTimer = new Timer(const Duration(milliseconds: 400),(){
        compiler.emit('completed', null);
        _completedTimer = null;
      });
    }
  }
  
  void cancelCompletedTimer(){
    if (_completedTimer != null) {
      _completedTimer.cancel();
    }
  }
  
  
  void _fileSystemEvent(FileSystemEvent event){
    switch(event.type){
      case FileSystemEvent.CREATE:
        cancelCompletedTimer();
        fileList.appendPath(event.path)
          .then(deferredCompleted);
        
        break;
      case FileSystemEvent.MODIFY:
        cancelCompletedTimer();
        if((event as FileSystemModifyEvent).contentChanged){
          fileList.fileChanged(event.path)
            .then(deferredCompleted);
        }
        break;
      case FileSystemEvent.MOVE:
        cancelCompletedTimer();
        //event.destination
        throw new Exception('Unsupported yet');
        break;
      case FileSystemEvent.DELETE:
        cancelCompletedTimer();
        fileList.removePath(event.path)
          .then(deferredCompleted);
        break;
    }
  }

  void stop() => compiler.stop();
}

