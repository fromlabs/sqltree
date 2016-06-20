import "dart:collection";

abstract class MyIterableMixin<E> implements Iterable<E> {
  void function1() {}
}

abstract class MyListMixin<E> extends MyIterableMixin<E> implements List<E> {
  void function2() {}
}

class MyList<E> extends ListBase<E> with MyListMixin<E> {
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

  @override
  void function1() {
    // TODO: WARNING: Missing concrete implementation of 'MyIterableMixin.function1'
  }
}

main() {}
