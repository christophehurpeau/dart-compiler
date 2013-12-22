import 'dart:async';
main(){
  new Future.value('test1')
    .then((String test1){
      assert(test1 == 'test1');
      return new Future.value('test2');
    })
    .then((String test3){
      return test3+'3';
    })
    .then((String test2){
      assert(test2 == 'test23');
      print(test2);
    });
}