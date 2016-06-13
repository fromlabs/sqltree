// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;

import "ordersheet_sql.dart";

class GroupConcatNodeImpl extends sql.CustomSqlNodeBase
    implements GroupConcatNode, sql.ChildrenLockingSupport {
  GroupConcatNodeImpl()
      : super(types.GROUP_CONCAT_STATEMENT, maxChildrenLength: 3);

  GroupConcatNodeImpl.cloneFrom(GroupConcatNodeImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.addInternalNode(new GroupConcatClauseImpl());
    this.addInternalNode(new sql.CustomSqlNode(types.ORDER_BY_CLAUSE));
    this.addInternalNode(new sql.CustomSqlNode(types.SEPARATOR_CLAUSE));
  }

  void clearGroupConcat() {
    groupConcatClause.children.clear();
  }

  @override
  void clearOrderBy() {
    orderByClause.children.clear();
  }

  @override
  void clearSeparator() {
    separatorClause.child = null;
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
  GroupConcatClause get groupConcatClause => children[0];

  @override
  bool get isDistinct => groupConcatClause.isDistinct;

  @override
  void orderBy(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    orderByClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  sql.SqlNode get orderByClause => children[1];

  @override
  void separator(node) {
    separatorClause.addChildren(node);
  }

  @override
  sql.SqlNode get separatorClause => children[2];

  @override
  sql.SqlNode createClone(bool freeze) =>
      new GroupConcatNodeImpl.cloneFrom(this, freeze);
}

class GroupConcatClauseImpl extends sql.CustomSqlNodeBase
    implements GroupConcatClause {
  @override
  bool isDistinct;

  GroupConcatClauseImpl()
      : this.isDistinct = false,
        super(types.GROUP_CONCAT_CLAUSE);

  GroupConcatClauseImpl.cloneFrom(GroupConcatClauseImpl targetNode, bool freeze)
      : this.isDistinct = targetNode.isDistinct,
        super.cloneFrom(targetNode, freeze);

  @override
  sql.SqlNode createClone(bool freeze) =>
      new GroupConcatClauseImpl.cloneFrom(this, freeze);
}
