// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_statement.dart";
import "sqltree_node.dart";
import "sqltree_node_impl.dart";
import "sqltree_node_manager.dart";

class SqlSelectStatementImpl extends SqlAbstractStatementImpl
    implements SqlSelectStatement {
  SqlSelectStatementImpl()
      : super(BaseSqlNodeTypes.types.SELECT_STATEMENT, maxChildrenLength: 8);

  SqlSelectStatementImpl.cloneFrom(
      SqlSelectStatementImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.addInternalNode(new SqlSelectClauseImpl());
    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.FROM_CLAUSE));
    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.WHERE_CLAUSE));
    this.addInternalNode(
        new SqlNodeImpl(BaseSqlNodeTypes.types.GROUP_BY_CLAUSE));
    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.HAVING_CLAUSE));
    this.addInternalNode(
        new SqlNodeImpl(BaseSqlNodeTypes.types.ORDER_BY_CLAUSE));
    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.LIMIT_CLAUSE,
        maxChildrenLength: 1));
    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.OFFSET_CLAUSE,
        maxChildrenLength: 1));
  }

  @override
  void clearFrom() {
    fromClause.children.clear();
  }

  @override
  void clearGroupBy() {
    groupByClause.children.clear();
  }

  @override
  void clearHaving() {
    havingClause.children.clear();
  }

  @override
  void clearLimit() {
    limitClause.child = null;
  }

  @override
  void clearOffset() {
    offsetClause.child = null;
  }

  @override
  void clearOrderBy() {
    orderByClause.children.clear();
  }

  @override
  void clearSelect() {
    selectClause.children.clear();
  }

  @override
  void clearWhere() {
    whereClause.children.clear();
  }

  @override
  void distinct([bool isDistinct = true]) {
    selectClause.isDistinct = isDistinct;
  }

  @override
  void from(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    fromClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get fromClause => children[1];

  @override
  void groupBy(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    groupByClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get groupByClause => children[3];

  @override
  void having(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    havingClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get havingClause => children[4];

  @override
  bool get isDistinct => selectClause.isDistinct;

  @override
  void limit(node) {
    limitClause.children.addAll(nodeManager.normalize(node));
  }

  @override
  SqlNode get limitClause => children[6];

  @override
  void offset(node) {
    offsetClause.children.addAll(nodeManager.normalize(node));
  }

  @override
  SqlNode get offsetClause => children[7];

  @override
  void orderBy(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    orderByClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get orderByClause => children[5];

  @override
  void select(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    selectClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlSelectClause get selectClause => children[0];

  @override
  SqlSelectStatement toCountStatement() => clone()
    ..clearHaving()
    ..clearLimit()
    ..clearOffset()
    ..clearSelect()
    ..select(nodeManager.registerNode(new SqlFunctionImpl(
        BaseSqlNodeTypes.types.COUNT,
        maxChildrenLength: 1)));

  @override
  void where(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    whereClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get whereClause => children[2];

  @override
  SqlSelectStatementImpl clone({bool freeze}) => super.clone(freeze: freeze);

  @override
  SqlSelectStatementImpl createClone(bool freeze) =>
      new SqlSelectStatementImpl.cloneFrom(this, freeze);
}

class SqlInsertStatementImpl extends SqlAbstractStatementImpl
    implements SqlInsertStatement {
  SqlInsertStatementImpl()
      : super(BaseSqlNodeTypes.types.INSERT_STATEMENT, maxChildrenLength: 3);

  SqlInsertStatementImpl.cloneFrom(
      SqlInsertStatementImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.INSERT_CLAUSE,
        maxChildrenLength: 1));
    this.addInternalNode(
        new SqlNodeImpl(BaseSqlNodeTypes.types.COLUMNS_CLAUSE));
    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.VALUES_CLAUSE));
  }

  @override
  void clearColumns() {
    columnsClause.children.clear();
  }

  @override
  void clearInsert() {
    insertClause.child = null;
  }

  @override
  void clearValues() {
    valuesClause.children.clear();
  }

  @override
  void columns(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    columnsClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get columnsClause => children[1];

  @override
  void insert([node]) {
    insertClause.children.addAll(nodeManager.normalize(node));
  }

  @override
  SqlNode get insertClause => children[0];

  @override
  void values(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    valuesClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get valuesClause => children[2];

  @override
  SqlInsertStatementImpl clone({bool freeze}) => super.clone(freeze: freeze);

  @override
  SqlInsertStatementImpl createClone(bool freeze) =>
      new SqlInsertStatementImpl.cloneFrom(this, freeze);
}

class SqlUpdateStatementImpl extends SqlAbstractStatementImpl
    implements SqlUpdateStatement {
  SqlUpdateStatementImpl()
      : super(BaseSqlNodeTypes.types.UPDATE_STATEMENT, maxChildrenLength: 3);

  SqlUpdateStatementImpl.cloneFrom(
      SqlUpdateStatementImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.UPDATE_CLAUSE,
        maxChildrenLength: 1));
    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.SET_CLAUSE));
    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.WHERE_CLAUSE));
  }

  @override
  void clearSet() {
    setClause.children.clear();
  }

  @override
  void clearUpdate() {
    updateClause.child = null;
  }

  @override
  void clearWhere() {
    whereClause.children.clear();
  }

  @override
  void set(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    setClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get setClause => children[1];

  @override
  void update([node]) {
    updateClause.children.addAll(nodeManager.normalize(node));
  }

  @override
  SqlNode get updateClause => children[0];

  @override
  void where(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    whereClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get whereClause => children[2];

  @override
  SqlUpdateStatementImpl clone({bool freeze}) => super.clone(freeze: freeze);

  @override
  SqlUpdateStatementImpl createClone(bool freeze) =>
      new SqlUpdateStatementImpl.cloneFrom(this, freeze);
}

class SqlDeleteStatementImpl extends SqlAbstractStatementImpl
    implements SqlDeleteStatement {
  SqlDeleteStatementImpl()
      : super(BaseSqlNodeTypes.types.DELETE_STATEMENT, maxChildrenLength: 3);

  SqlDeleteStatementImpl.cloneFrom(
      SqlDeleteStatementImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.DELETE_CLAUSE,
        maxChildrenLength: 1));
    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.FROM_CLAUSE));
    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.WHERE_CLAUSE));
  }

  @override
  void clearDelete() {
    deleteClause.children.clear();
  }

  @override
  void clearFrom() {
    fromClause.children.clear();
  }

  @override
  void clearWhere() {
    whereClause.children.clear();
  }

  @override
  void delete(node) {
    deleteClause.children.addAll(nodeManager.normalize(node));
  }

  @override
  SqlNode get deleteClause => children[0];

  @override
  void from(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    fromClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get fromClause => children[1];

  @override
  void where(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    whereClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get whereClause => children[2];

  @override
  SqlDeleteStatementImpl clone({bool freeze}) => super.clone(freeze: freeze);

  @override
  SqlDeleteStatementImpl createClone(bool freeze) =>
      new SqlDeleteStatementImpl.cloneFrom(this, freeze);
}

abstract class SqlAbstractStatementImpl extends SqlAbstractNodeImpl
    implements SqlStatement, ChildrenLockingSupport {
  SqlAbstractStatementImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  SqlAbstractStatementImpl.cloneFrom(
      SqlAbstractStatementImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlAbstractStatementImpl clone({bool freeze}) => super.clone(freeze: freeze);
}

class SqlSelectClauseImpl extends SqlAbstractNodeImpl
    implements SqlSelectClause {
  bool _isDistinct;

  SqlSelectClauseImpl()
      : this._isDistinct = false,
        super(BaseSqlNodeTypes.types.SELECT_CLAUSE);

  SqlSelectClauseImpl.cloneFrom(SqlSelectClauseImpl targetNode, bool freeze)
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
  SqlSelectClauseImpl clone({bool freeze}) => super.clone(freeze: freeze);

  @override
  SqlSelectClauseImpl createClone(bool freeze) =>
      new SqlSelectClauseImpl.cloneFrom(this, freeze);
}

class SqlJoinsImpl extends SqlAbstractNodeImpl implements SqlJoins {
  SqlJoinsImpl() : super(BaseSqlNodeTypes.types.JOINS);

  SqlJoinsImpl.cloneFrom(SqlJoinsImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

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
    var join =
        addInternalNode(new SqlJoinImpl(BaseSqlNodeTypes.types.INNER_JOIN));

    join.from(fromNode);

    join.on(onNode0, onNode1, onNode2, onNode3, onNode4, onNode5, onNode6,
        onNode7, onNode8, onNode9);
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
    SqlJoin join =
        addInternalNode(new SqlJoinImpl(BaseSqlNodeTypes.types.LEFT_JOIN));

    join.from(fromNode);

    join.on(onNode0, onNode1, onNode2, onNode3, onNode4, onNode5, onNode6,
        onNode7, onNode8, onNode9);
  }

  @override
  SqlJoinsImpl clone({bool freeze}) => super.clone(freeze: freeze);

  @override
  SqlJoinsImpl createClone(bool freeze) =>
      new SqlJoinsImpl.cloneFrom(this, freeze);
}

class SqlJoinImpl extends SqlAbstractNodeImpl
    implements SqlJoin, ChildrenLockingSupport {
  SqlJoinImpl(String type) : super(type, maxChildrenLength: 2);

  SqlJoinImpl.cloneFrom(SqlJoinImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  void onNodeRegistered() {
    super.onNodeRegistered();

    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.JOIN_FROM,
        maxChildrenLength: 1));
    this.addInternalNode(new SqlNodeImpl(BaseSqlNodeTypes.types.JOIN_ON));
  }

  @override
  void clearFrom() {
    fromClause.child = null;
  }

  @override
  void clearOn() {
    onClause.children.clear();
  }

  @override
  void from(node) {
    fromClause.children.add(node);
  }

  @override
  SqlNode get fromClause => children[0];

  @override
  void on(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    onClause.children.addAll(nodeManager.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));
  }

  @override
  SqlNode get onClause => children[1];

  @override
  SqlJoinImpl clone({bool freeze}) => super.clone(freeze: freeze);

  @override
  SqlJoinImpl createClone(bool freeze) =>
      new SqlJoinImpl.cloneFrom(this, freeze);
}
