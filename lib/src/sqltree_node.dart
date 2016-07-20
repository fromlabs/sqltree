// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

abstract class Cloneable {
  Cloneable clone();
}

abstract class Freezable implements Cloneable {
  bool get isFreezed;

  Freezable clone({bool freeze});
}

abstract class SqlNodeIterable<E extends SqlNode> implements Iterable<E> {
  void setReference(String reference);

  void setEnabled(bool isEnabled);

  void setDisabled(bool isDisabled);

  void enable();

  void disable();

  E get firstOrNull;

  E get singleOrNull;

  bool containsReference(String reference);

  SqlNodeIterable<E> whereReference(String reference);

  SqlNodeIterable<E> whereDeep(bool test(E element));

  /* FROM ITERABLE */

  SqlNodeIterable<E> expandNodes(Iterable<E> f(E element));

  SqlNodeIterable<E> mapNodes(E f(E element));

  SqlNodeIterable<E> skip(int n);

  SqlNodeIterable<E> skipWhile(bool test(E value));

  SqlNodeIterable<E> take(int n);

  SqlNodeIterable<E> takeWhile(bool test(E value));

  SqlNodeList<E> toList({bool growable: true});

  SqlNodeIterable<E> where(bool test(E element));
}

abstract class SqlNodeList<E extends SqlNode>
    implements SqlNodeIterable<E>, List<E>, Freezable {
  @override
  SqlNodeList<E> clone({bool freeze});

  /* FROM LIST */

  SqlNodeIterable<E> getRange(int start, int end);

  SqlNodeIterable<E> get reversed;

  SqlNodeList<E> sublist(int start, [int end]);

  /* FROM SQLNODEITERABLE */

  SqlNodeIterable<E> skip(int n);

  SqlNodeIterable<E> skipWhile(bool test(E value));

  SqlNodeIterable<E> take(int n);

  SqlNodeIterable<E> takeWhile(bool test(E value));

  SqlNodeList<E> toList({bool growable: true});

  SqlNodeIterable<E> where(bool test(E element));
}

abstract class SqlNode implements Freezable {
  String get type;

  @override
  SqlNode clone({bool freeze});

  String reference;

  bool isEnabled;

  bool get isDisabled;

  void set isDisabled(bool isDisabled);

  void enable();

  void disable();

  /* RAW NODE */

  bool get isRawNode;

  String get rawExpression;

  /* COMPOSITE NODE */

  bool get isCompositeNode;

  bool get isEmptyComposite;

  bool get isSingleCompositeNode;

  bool get isMultiCompositeNode;

  /* SINGLE COMPOSITE NODE */

  SqlNode get child;

  void set child(SqlNode singleChild);

  /* MULTI COMPOSITE NODE */

  SqlNodeList<SqlNode> get children;

  bool containsReference(String reference);

  SqlNodeIterable<SqlNode> whereReference(String reference);

  SqlNodeIterable<SqlNode> /*<T>*/ whereDeep/*<T extends SqlNode>*/(
      bool test(/*=T*/ node));
}

abstract class SqlFunction implements SqlNode {}

abstract class SqlOperator implements SqlNode {
  bool get isUnary;
}

abstract class ChildrenLockingSupport {}

abstract class SqlNodeProvider {
  createNode();
}
