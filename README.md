The compiler can watch your source code and compile it.


Create and modify your files in `web.src/`, the compiler will put the compiled files in `web/`


## Integration in Dart Editor

Create a new file `build.dart`


```
import 'package:springbok/builder.dart';
        
main(args) {
  build(args);
}

```