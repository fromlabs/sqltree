// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";

abstract class SqlStatement implements SqlNode {
  SqlStatement clone();
}

abstract class SqlSelectStatement implements SqlStatement {
  void select(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void distinct([bool isDistinct = true]);

  void from(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void where(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void groupBy(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void having(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void orderBy(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void offset(node);

  void limit(node);

  bool get isDistinct;

  SqlSelectClause get selectClause;

  SqlNode get fromClause;

  SqlNode get whereClause;

  SqlNode get groupByClause;

  SqlNode get havingClause;

  SqlNode get orderByClause;

  SqlNode get offsetClause;

  SqlNode get limitClause;

  void clearSelect();

  void clearFrom();

  void clearWhere();

  void clearGroupBy();

  void clearHaving();

  void clearOrderBy();

  void clearOffset();

  void clearLimit();

  SqlSelectStatement toCountStatement();

  SqlSelectStatement clone();
}

abstract class SqlInsertStatement implements SqlStatement {
  void insert(node);

  void columns(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void values(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlNode get insertClause;

  SqlNode get columnsClause;

  SqlNode get valuesClause;

  void clearInsert();

  void clearColumns();

  void clearValues();

  SqlInsertStatement clone();
}

abstract class SqlUpdateStatement implements SqlStatement {
  void update(node);

  void set(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void where(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlNode get updateClause;

  SqlNode get setClause;

  SqlNode get whereClause;

  void clearUpdate();

  void clearSet();

  void clearWhere();

  SqlUpdateStatement clone();
}

abstract class SqlDeleteStatement implements SqlStatement {
  void delete(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void from(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void where(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlNode get deleteClause;

  SqlNode get fromClause;

  SqlNode get whereClause;

  void clearDelete();

  void clearFrom();

  void clearWhere();

  SqlDeleteStatement clone();
}

abstract class SqlSelectClause implements SqlNode {
  bool get isDistinct;

  void set isDistinct(bool isDistinct);

  SqlSelectClause clone();
}

abstract class SqlJoins implements SqlNode {
  void leftJoin(fromNode,
      [onNode0,
      onNode1,
      onNode2,
      onNode3,
      onNode4,
      onNode5,
      onNode6,
      onNode7,
      onNode8,
      onNode9]);

  void join(fromNode,
      [onNode0,
      onNode1,
      onNode2,
      onNode3,
      onNode4,
      onNode5,
      onNode6,
      onNode7,
      onNode8,
      onNode9]);

  SqlJoins clone();
}

abstract class SqlJoin implements SqlNode {
  void from(node);

  void on(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlNode get fromClause;

  SqlNode get onClause;

  void clearFrom();

  void clearOn();

  SqlJoin clone();
}
