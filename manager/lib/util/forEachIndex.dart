import 'dart:core';

extension IndexedIterable<E> on Iterable<E> {
  void forEachIndex(void f(E e, int i)) {
    var i = 0;
    this.forEach((e) => f(e, i++));
  }
}
