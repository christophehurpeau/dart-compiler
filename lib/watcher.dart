part of compiler;

class Watcher extends Compiler{
  final List<StreamSubscription<FileSystemEvent>> _watchers = new List();
  
  Watcher(Directory directory, Function FileList) : super(directory, FileList);
  
  @override
  Future start(){
    if(this._watchers.isNotEmpty) this.stop();
    
    super.start().then((_){
      this._watchers.add(this._directory
          .watch(events: FileSystemEvent.MODIFY, recursive: false)
            .listen((FileSystemEvent event){
              if((event as FileSystemModifyEvent).contentChanged){
                if(event.path.endsWith('/springbokwatcher.yml')){
                  this.stop();
                  this._loadConfig().then((_) => this.start());
                }
              }
            }));

      this._watchers.add(_srcDirectory
          .watch(events: FileSystemEvent.ALL, recursive: true)
            .listen(_fileSystemEvent));
    });
  }
  
  void _fileSystemEvent(FileSystemEvent event){
    switch(event.type){
      case FileSystemEvent.CREATE:
        _fileList.appendPath(event.path);
        break;
      case FileSystemEvent.MODIFY:
        if((event as FileSystemModifyEvent).contentChanged){
          _fileList.fileChanged(event.path);
        }
        break;
      case FileSystemEvent.MOVE:
        //event.destination
        throw new Exception('Unsupported yet');
        break;
      case FileSystemEvent.DELETE:
        _fileList.removePath(event.path);
        break;
    }
  }

  @override
  void stop(){
    super.stop();
    this._watchers.forEach((w) => w.cancel());
    this._watchers.clear();
  }
}

