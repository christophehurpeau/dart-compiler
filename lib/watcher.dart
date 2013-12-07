part of compiler;

class Watcher{
  final Compiler compiler;
  
  final List<StreamSubscription<FileSystemEvent>> _watchers = new List();
  
  Watcher(Directory directory, FileListFactory fileListFactory)
      : this.fromCompiler( new Compiler(directory, fileListFactory) );
  
  Watcher.fromCompiler(Compiler this.compiler){
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
                if(event.path.endsWith('/' + Compiler.CONFIG_FILE_NAME)){
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
  
  void _fileSystemEvent(FileSystemEvent event){
    switch(event.type){
      case FileSystemEvent.CREATE:
        fileList.appendPath(event.path);
        break;
      case FileSystemEvent.MODIFY:
        if((event as FileSystemModifyEvent).contentChanged){
          fileList.fileChanged(event.path);
        }
        break;
      case FileSystemEvent.MOVE:
        //event.destination
        throw new Exception('Unsupported yet');
        break;
      case FileSystemEvent.DELETE:
        fileList.removePath(event.path);
        break;
    }
  }

  void stop() => compiler.stop();
}

