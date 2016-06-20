import "dart:collection";

abstract class MyListMixin<E> implements Iterable<E> {
  int get value;

  void function1() {
    print("$value from function1");
  }
}

class MyList<E> extends ListBase<E> with MyListMixin<E> {
  int value;

  List<E> _backed = [];

  MyList();

  @override
  int get length => _backed.length;

  @override
  void set length(int length) {
    _backed.length = length;
  }

  @override
  E operator [](int index) {
    return _backed[index];
  }

  @override
  void operator []=(int index, E value) {
    _backed[index] = value;
  }
}

main() {

  var list = new MyList();
  list.value = 10;
  list.function1();
}
