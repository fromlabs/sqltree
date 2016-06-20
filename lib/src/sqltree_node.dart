// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// TODO queste classi devono essere facilmente estendibili per SqlColumnList, SQCOlumnSet, SqlColumnIterable

abstract class Clonable {
  Clonable clone();
}

abstract class Freezable implements Clonable {
  bool get isFreezed;

  Freezable clone({bool freeze});
}

abstract class SqlNodeIterable<E extends SqlNode> implements Iterable<E> {
  void setReference(String reference);

  void setEnabled(bool isEnabled);

  void setDisabled(bool isDisabled);

  void enable();

  void disable();

  // TODO rinominare firstOrNull
  E get firstOrNull;

  // TODO rinominare singleOrNull
  E get singleOrNull;

  bool containsReference(String reference);

  SqlNodeIterable<E> whereReference(String reference);

  SqlNodeIterable<E> whereDeep(bool test(E element));

  /* FROM ITERABLE */

  SqlNodeIterable<E> expand(Iterable f(E element));

  SqlNodeIterable<E> map(f(E element));

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

  bool get isSingleCompositeNode;

  bool get isMultiCompositeNode;

  /* SINGLE COMPOSITE NODE */

  SqlNode get child;

  void set child(SqlNode singleChild);

  /* MULTI COMPOSITE NODE */

  SqlNodeList get children;

  void addChildren(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void setChildren(int index, node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void insertChildren(int index, node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  bool containsReference(String reference);

  SqlNodeIterable<SqlNode> whereReference(String reference);

  SqlNodeIterable<SqlNode> whereDeep(bool test(SqlNode node));
}

abstract class SqlFunction implements SqlNode {}

abstract class SqlOperator implements SqlNode {
  bool get isUnary;
}

abstract class ChildrenLockingSupport {}

abstract class SqlNodeProvider {
  createNode();
}
