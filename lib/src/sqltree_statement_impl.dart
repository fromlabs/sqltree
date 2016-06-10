// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_statement.dart";
import "sqltree_node.dart";
import "sqltree_node_impl.dart";
import "sqltree_node_manager.dart";

class SqlSelectStatementImpl extends SqlAbstractStatementImpl
    implements SqlSelectStatement {
  SqlSelectStatementImpl() : super(BaseSqlNodeTypes.types.SELECT_STATEMENT, 8);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.registerAndAddInternal(new SqlSelectClauseImpl());
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.FROM_CLAUSE, null));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.WHERE_CLAUSE, null));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.GROUP_BY_CLAUSE, null));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.HAVING_CLAUSE, null));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.ORDER_BY_CLAUSE, null));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.LIMIT_CLAUSE, 1));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.OFFSET_CLAUSE, 1));
  }

  @override
  void clearFrom() {
    fromClause.clear();
  }

  @override
  void clearGroupBy() {
    groupByClause.clear();
  }

  @override
  void clearHaving() {
    havingClause.clear();
  }

  @override
  void clearLimit() {
    limitClause.clear();
  }

  @override
  void clearOffset() {
    offsetClause.clear();
  }

  @override
  void clearOrderBy() {
    orderByClause.clear();
  }

  @override
  void clearSelect() {
    selectClause.clear();
  }

  @override
  void clearWhere() {
    whereClause.clear();
  }

  @override
  void distinct([bool isDistinct = true]) {
    selectClause.isDistinct = isDistinct;
  }

  @override
  void from(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    fromClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get fromClause => getChild(1);

  @override
  void groupBy(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    groupByClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get groupByClause => getChild(3);

  @override
  void having(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    havingClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get havingClause => getChild(4);

  @override
  bool get isDistinct => selectClause.isDistinct;

  @override
  void limit(node) {
    limitClause.addChildren(node);
  }

  @override
  SqlNode get limitClause => getChild(6);

  @override
  void offset(node) {
    offsetClause.addChildren(node);
  }

  @override
  SqlNode get offsetClause => getChild(7);

  @override
  void orderBy(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    orderByClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get orderByClause => getChild(5);

  @override
  void select(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    selectClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlSelectClause get selectClause => getChild(0);

  @override
  SqlSelectStatement toCountStatement() {
    return this.clone()
      ..clearHaving()
      ..clearLimit()
      ..clearOffset()
      ..clearSelect()
      ..select(nodeManager
          .registerNode(new SqlNodeImpl(BaseSqlNodeTypes.types.COUNT, 1)));
  }

  @override
  void where(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    whereClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get whereClause => getChild(2);

  @override
  SqlSelectStatementImpl createSqlNodeClone() => new SqlSelectStatementImpl();

  @override
  SqlSelectStatementImpl clone() => super.clone();
}

class SqlInsertStatementImpl extends SqlAbstractStatementImpl
    implements SqlInsertStatement {
  SqlInsertStatementImpl() : super(BaseSqlNodeTypes.types.INSERT_STATEMENT, 3);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.INSERT_CLAUSE, 1));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.COLUMNS_CLAUSE, null));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.VALUES_CLAUSE, null));
  }

  @override
  void clearColumns() {
    columnsClause.clear();
  }

  @override
  void clearInsert() {
    insertClause.clear();
  }

  @override
  void clearValues() {
    valuesClause.clear();
  }

  @override
  void columns([bool isDistinct]) {
    columnsClause.clear();
  }

  @override
  SqlNode get columnsClause => getChild(1);

  @override
  void insert(node) {
    insertClause.addChildren(node);
  }

  @override
  SqlNode get insertClause => getChild(0);

  @override
  void values(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    valuesClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get valuesClause => getChild(2);

  @override
  SqlInsertStatementImpl createSqlNodeClone() => new SqlInsertStatementImpl();

  @override
  SqlInsertStatementImpl clone() => super.clone();
}

class SqlUpdateStatementImpl extends SqlAbstractStatementImpl
    implements SqlUpdateStatement {
  SqlUpdateStatementImpl() : super(BaseSqlNodeTypes.types.UPDATE_STATEMENT, 3);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.UPDATE_CLAUSE, 1));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.SET_CLAUSE, null));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.WHERE_CLAUSE, null));
  }

  @override
  void clearSet() {
    setClause.clear();
  }

  @override
  void clearUpdate() {
    updateClause.clear();
  }

  @override
  void clearWhere() {
    whereClause.clear();
  }

  @override
  void set(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    setClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get setClause => getChild(1);

  @override
  void update(node) {
    updateClause.addChildren(node);
  }

  @override
  SqlNode get updateClause => getChild(0);

  @override
  void where(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    whereClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get whereClause => getChild(2);

  @override
  SqlUpdateStatementImpl createSqlNodeClone() => new SqlUpdateStatementImpl();

  @override
  SqlUpdateStatementImpl clone() => super.clone();
}

class SqlDeleteStatementImpl extends SqlAbstractStatementImpl
    implements SqlDeleteStatement {
  SqlDeleteStatementImpl() : super(BaseSqlNodeTypes.types.DELETE_STATEMENT, 3);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.DELETE_CLAUSE, 1));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.FROM_CLAUSE, null));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.WHERE_CLAUSE, null));
  }

  @override
  void clearDelete() {
    deleteClause.clear();
  }

  @override
  void clearFrom() {
    fromClause.clear();
  }

  @override
  void clearWhere() {
    whereClause.clear();
  }

  @override
  void delete(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    deleteClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get deleteClause => getChild(0);

  @override
  void from(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    fromClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get fromClause => getChild(1);

  @override
  void where(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    whereClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get whereClause => getChild(2);

  @override
  SqlDeleteStatementImpl createSqlNodeClone() => new SqlDeleteStatementImpl();

  @override
  SqlDeleteStatementImpl clone() => super.clone();
}

abstract class SqlAbstractStatementImpl extends SqlAbstractNodeImpl
    implements SqlStatement, ChildrenLockedSqlNode {
  SqlAbstractStatementImpl(String type, int maxChildrenLength)
      : super(type, maxChildrenLength);

  @override
  SqlAbstractStatementImpl clone() {
    return super.clone();
  }
}

class SqlSelectClauseImpl extends SqlAbstractNodeImpl
    implements SqlSelectClause {
  @override
  bool isDistinct;

  SqlSelectClauseImpl()
      : this.isDistinct = false,
        super(BaseSqlNodeTypes.types.SELECT_CLAUSE, null);

  @override
  SqlSelectClauseImpl createSqlNodeClone() => new SqlSelectClauseImpl();

  @override
  SqlSelectClauseImpl clone() => super.clone();

  @override
  SqlSelectClauseImpl completeClone(SqlSelectClauseImpl targetNode) {
    SqlSelectClauseImpl node = super.completeClone(targetNode);
    node.isDistinct = targetNode.isDistinct;
    return node;
  }
}

class SqlJoinsImpl extends SqlAbstractNodeImpl implements SqlJoins {
  SqlJoinsImpl() : super(BaseSqlNodeTypes.types.JOINS, null);

  @override
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
      onNode9]) {
    var join = nodeManager
        .registerNode(new SqlJoinImpl(BaseSqlNodeTypes.types.INNER_JOIN));

    join.addInternal(fromNode);

    join.addInternal(onNode0, onNode1, onNode2, onNode3, onNode4, onNode5,
        onNode6, onNode7, onNode8, onNode9);

    registerAndAddInternal(join);
  }

  @override
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
      onNode9]) {
    return registerAndAddInternal(
        new SqlJoinImpl(BaseSqlNodeTypes.types.LEFT_JOIN))
      ..addChildren(fromNode)
      ..addChildren(onNode0, onNode1, onNode2, onNode3, onNode4, onNode5,
          onNode6, onNode7, onNode8, onNode9);
  }

  @override
  SqlJoinsImpl createSqlNodeClone() => new SqlJoinsImpl();

  @override
  SqlJoinsImpl clone() => super.clone();
}

class SqlJoinImpl extends SqlAbstractNodeImpl
    implements SqlJoin, ChildrenLockedSqlNode {
  SqlJoinImpl(String type) : super(type, 2);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.JOIN_FROM, 1));
    this.registerAndAddInternal(
        new SqlNodeImpl(BaseSqlNodeTypes.types.JOIN_ON, null));
  }

  @override
  void clearFrom() {
    fromClause.clear();
  }

  @override
  void clearOn() {
    onClause.clear();
  }

  @override
  void from(node) {
    fromClause.addChildren(node);
  }

  @override
  SqlNode get fromClause => getChild(0);

  @override
  void on(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    onClause.addChildren(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  SqlNode get onClause => getChild(1);

  @override
  SqlJoinImpl createSqlNodeClone() => new SqlJoinImpl(type);

  @override
  SqlJoinImpl clone() => super.clone();
}
