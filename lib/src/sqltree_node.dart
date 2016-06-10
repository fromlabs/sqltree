// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

abstract class SqlNodeList<T extends SqlNode> implements List<T> {
  SqlNode get singleOrNull;

  SqlNodeList<T> clone();

  void set isEnabled(bool isEnabled);

  void set isDisabled(bool isDisabled);

  void enable();

  void disable();

  SqlNode getSingleNodeByReference(String reference);

  SqlNodeList getNodeListByReference(String reference);
}

abstract class SqlNode {
  String get type;

  SqlNode clone();

  String get reference;

  bool get isEnabled;

  void set isEnabled(bool isEnabled);

  bool get isDisabled;

  void set isDisabled(bool isDisabled);

  void enable();

  void disable();

  /* RAW NODE */

  bool get isRawExpression;

  String get rawExpression;

  /* COMPOSITE NODE */

  bool get isComposite;

  /* SINGLE COMPOSITE NODE */

  SqlNode get child;

  void set child(SqlNode singleChild);

  /* MULTI COMPOSITE NODE */

  SqlNodeList get children;

  SqlNode getChild(int index);

  void addChildren(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void setChildren(int index, node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void insertChildren(int index, node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlNode getSingleNodeByReference(String reference);

  SqlNodeList getNodeListByReference(String reference);

  void clear();
}

abstract class SqlGroup implements SqlNode {
  String get reference;

  bool get isEnabled;

  bool get isDisabled;
}

abstract class SqlFunction implements SqlNode {}

abstract class SqlOperator implements SqlNode {
  bool get isUnary;
}

// TODO rinominare diversamente
abstract class ChildrenLockedSqlNode implements SqlNode {}

abstract class SqlNodeConvertable {
  toNode();
}
