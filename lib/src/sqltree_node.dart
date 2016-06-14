// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

typedef SqlNode NodeWrapper(SqlNode node);

abstract class SqlNodeList<T extends SqlNode> implements List<T> {
  bool get isFreezed;

  SqlNode get singleOrNull;

  SqlNodeList<T> clone({bool freeze});

  void setReference(String reference);

  void setEnabled(bool isEnabled);

  void setDisabled(bool isDisabled);

  void enable();

  void disable();

  bool containsReference(String reference);

  SqlNode getSingleNodeByReference(String reference);

  SqlNodeList getNodeListByReference(String reference);

  SqlNodeList wrap(NodeWrapper wrapper);
}

abstract class SqlNode {
  bool get isFreezed;

  String get type;

  SqlNode clone({bool freeze});

  String reference;

  bool isEnabled;

  bool get isDisabled;

  void set isDisabled(bool isDisabled);

  void enable();

  void disable();

  /* RAW NODE */

  bool get isRawExpression;

  String get rawExpression;

  /* COMPOSITE NODE */

  bool get isComposite;

  bool get isSingleComposite;

  bool get isMultiComposite;

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

  SqlNode getSingleNodeByReference(String reference);

  SqlNodeList getNodeListByReference(String reference);
}

abstract class SqlFunction implements SqlNode {}

abstract class SqlOperator implements SqlNode {
  bool get isUnary;
}

abstract class ChildrenLockingSupport {}

abstract class SqlNodeProvider {
  createNode();
}
