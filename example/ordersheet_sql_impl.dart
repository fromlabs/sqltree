// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;

import "ordersheet_sql.dart";

class GroupConcatNodeImpl extends sql.CustomSqlNode
    implements GroupConcatNode, sql.ChildrenLockedSqlNode {
  @override
  GroupConcatNodeImpl()
      : super(types.GROUP_CONCAT_STATEMENT, maxChildrenLength: 3);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    var clause = new GroupConcatClauseImpl();

    nodeFactory.registerNode(clause);

    this.addInternal(clause);
    this.addInternal(nodeFactory.createNode(types.ORDER_BY_CLAUSE, null));
    this.addInternal(nodeFactory.createNode(types.SEPARATOR_CLAUSE, 1));
  }

  void clearGroupConcat() {
    groupConcatClause.clear();
  }

  @override
  void clearOrderBy() {
    orderByClause.clear();
  }

  @override
  void clearSeparator() {
    separatorClause.clear();
  }

  @override
  void distinct([bool isDistinct = true]) {
    groupConcatClause.isDistinct = isDistinct;
  }

  @override
  void groupConcat(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    groupConcatClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  GroupConcatClause get groupConcatClause => getChild(0);

  @override
  bool get isDistinct => groupConcatClause.isDistinct;

  @override
  void orderBy(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    orderByClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  sql.SqlNode get orderByClause => getChild(1);

  @override
  void separator(node) {
    separatorClause.addChildren(node);
  }

  @override
  sql.SqlNode get separatorClause => getChild(2);
}

class GroupConcatClauseImpl extends sql.CustomSqlNode
    implements GroupConcatClause {
  @override
  bool isDistinct;

  GroupConcatClauseImpl()
      : this.isDistinct = false,
        super(types.GROUP_CONCAT_CLAUSE);

  @override
  GroupConcatClauseImpl clone() {
    return super.clone();
  }

  @override
  GroupConcatClauseImpl createSqlNodeClone() {
    return new GroupConcatClauseImpl();
  }

  @override
  GroupConcatClauseImpl completeClone(GroupConcatClauseImpl targetNode) {
    GroupConcatClauseImpl node = super.completeClone(targetNode);
    node.isDistinct = targetNode.isDistinct;
    return node;
  }
}
