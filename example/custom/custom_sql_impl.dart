// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;

import "custom_sql.dart";

class GroupConcatStatementImpl extends sql.ExtensionSqlNodeBase
    implements GroupConcatStatement, sql.ChildrenLockingSupport {
  GroupConcatStatementImpl()
      : super(types.GROUP_CONCAT_STATEMENT, maxChildrenLength: 3);

  GroupConcatStatementImpl.cloneFrom(
      GroupConcatStatementImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.addInternalNode(new GroupConcatClauseImpl());
    this.addInternalNode(
        new sql.ExtensionSqlNode(types.GROUP_CONCAT_ORDER_BY_CLAUSE));
    this.addInternalNode(new sql.ExtensionSqlNode(types.SEPARATOR_CLAUSE));
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
  void groupConcat(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    groupConcatClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  GroupConcatClause get groupConcatClause => children[0];

  @override
  bool get isDistinct => groupConcatClause.isDistinct;

  @override
  void orderBy(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    orderByClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  sql.SqlNode get orderByClause => children[1];

  @override
  void separator(node) {
    separatorClause.children.addAll(nodeManager.normalize(node));
  }

  @override
  sql.SqlNode get separatorClause => children[2];

  @override
  GroupConcatStatementImpl clone({bool freeze}) => super.clone(freeze: freeze);

  @override
  GroupConcatStatementImpl createClone(bool freeze) =>
      new GroupConcatStatementImpl.cloneFrom(this, freeze);
}

class GroupConcatClauseImpl extends sql.ExtensionSqlNodeBase
    implements GroupConcatClause {
  bool _isDistinct;

  GroupConcatClauseImpl()
      : this._isDistinct = false,
        super(types.GROUP_CONCAT_CLAUSE);

  GroupConcatClauseImpl.cloneFrom(GroupConcatClauseImpl targetNode, bool freeze)
      : this._isDistinct = targetNode.isDistinct,
        super.cloneFrom(targetNode, freeze);

  @override
  bool get isDistinct => _isDistinct;

  @override
  void set isDistinct(bool isDistinct) {
    checkNotFreezed();

    _isDistinct = isDistinct;
  }

  @override
  GroupConcatClauseImpl clone({bool freeze}) => super.clone(freeze: freeze);

  @override
  GroupConcatClauseImpl createClone(bool freeze) =>
      new GroupConcatClauseImpl.cloneFrom(this, freeze);
}
