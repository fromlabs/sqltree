// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_node_impl.dart";
import "sqltree_statement.dart";
import "sqltree_statement_impl.dart";
import "sqltree_node_factory.dart";
import "sqltree_util.dart";

class SqlNodeFactoryImpl implements SqlNodeFactory {
  static final Set<String> customNodeTypes = new Set<String>();

  final Set<String> nodeTypes = new Set<String>();

  SqlNodeFactoryImpl() {
    _registerTypes();
  }

  void _registerTypes() {
    registerNodeType(BaseSqlNodeTypes.types.RAW);
    registerNodeType(BaseSqlNodeTypes.types.GROUP);
    registerNodeType(BaseSqlNodeTypes.types.SELECT_STATEMENT);
    registerNodeType(BaseSqlNodeTypes.types.UPDATE_STATEMENT);
    registerNodeType(BaseSqlNodeTypes.types.DELETE_STATEMENT);
    registerNodeType(BaseSqlNodeTypes.types.INSERT_STATEMENT);
    registerNodeType(BaseSqlNodeTypes.types.SELECT_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.UPDATE_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.INSERT_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.DELETE_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.COLUMNS_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.VALUES_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.FROM_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.WHERE_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.GROUP_BY_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.HAVING_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.ORDER_BY_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.LIMIT_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.OFFSET_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.SET_CLAUSE);
    registerNodeType(BaseSqlNodeTypes.types.JOINS);
    registerNodeType(BaseSqlNodeTypes.types.INNER_JOIN);
    registerNodeType(BaseSqlNodeTypes.types.LEFT_JOIN);
    registerNodeType(BaseSqlNodeTypes.types.JOIN_FROM);
    registerNodeType(BaseSqlNodeTypes.types.JOIN_ON);
    registerNodeType(BaseSqlNodeTypes.types.FORMATTED);
  }

  @override
  SqlFunction createCustomFunction(
      String function, int maxChildrenLength, nodes) {
    _registerCustomNodeType(function);

    return createFunction(function, maxChildrenLength, nodes);
  }

  @override
  SqlOperator createCustomOperator(
      String operator, int maxChildrenLength, nodes) {
    _registerCustomNodeType(operator);

    return createOperator(operator, maxChildrenLength, nodes);
  }

  @override
  SqlDeleteStatement createDeleteStatement(nodes) {
    var statement = new SqlDeleteStatementImpl();

    registerNode(statement);

    statement.fromClause.addChildren(nodes);

    return statement;
  }

  @override
  SqlFunction createFunction(String function, int maxChildrenLength, nodes) {
    var custom = new SqlFunctionImpl(function, maxChildrenLength);

    registerNode(custom);

    custom.addChildren(nodes);

    return custom;
  }

  @override
  SqlJoin createInnerJoin(fromNode, onNodes) {
    var join = new SqlJoinImpl(BaseSqlNodeTypes.types.INNER_JOIN);

    registerNode(join);

    join
      ..from(fromNode)
      ..on(onNodes);

    return join;
  }

  @override
  SqlInsertStatement createInsertStatement(node) {
    var statement = new SqlInsertStatementImpl();

    registerNode(statement);

    statement.insertClause.child = node;

    return statement;
  }

  @override
  SqlJoin createLeftJoin(fromNode, onNodes) {
    var join = new SqlJoinImpl(BaseSqlNodeTypes.types.LEFT_JOIN);

    registerNode(join);

    join
      ..from(fromNode)
      ..on(onNodes);

    return join;
  }

  @override
  SqlNode createNode(String type, int maxChildrenLength, [nodes]) {
    var custom = new SqlNodeImpl(type, maxChildrenLength);

    registerNode(custom);

    custom.addChildren(nodes);

    return custom;
  }

  @override
  SqlOperator createOperator(String operator, int maxChildrenLength, nodes) {
    var custom = new SqlOperatorImpl(operator, maxChildrenLength);

    registerNode(custom);

    custom.addChildren(nodes);

    return custom;
  }

  @override
  SqlFunction createCount([node]) {
    return createFunction(BaseSqlNodeTypes.types.COUNT, 1, node ?? 1);
  }

  @override
  SqlSelectClause createSelectClause() {
    var clause = new SqlSelectClauseImpl();

    registerNode(clause);

    return clause;
  }

  @override
  SqlSelectStatement createSelectStatement(nodes) {
    var statement = new SqlSelectStatementImpl();

    registerNode(statement);

    statement.selectClause.addChildren(nodes);

    return statement;
  }

  @override
  SqlJoins createSqlJoin(nodes) {
    var join = new SqlJoinsImpl();

    registerNode(join);

    join.addChildren(nodes);

    return join;
  }

  @override
  SqlGroup createGroup(String reference, node) {
    var group = new SqlGroupImpl(reference);

    registerNode(group);

    group.addChildren(node);

    return group;
  }

  @override
  SqlNodeList createTypedWrapperNodeList(String type,
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    var result = new SqlNodeListImpl();

    for (var node in getVargsList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9)) {
      if (node is SqlNodeConvertable) {
        node = node.toNode();
      }

      if (node is Iterable) {
        for (var child in node) {
          result.addAll(createTypedWrapperNodeList(type, child));
        }
      } else if (type != null) {
        result.add(createNode(type, null, node));
      } else if (node is SqlNode) {
        result.add(node);
      } else {
        node = new SqlNodeImpl.raw(node);

        registerNode(node);

        result.add(node);
      }
    }
    return result;
  }

  @override
  SqlUpdateStatement createUpdateStatement(node) {
    var statement = new SqlUpdateStatementImpl();

    registerNode(statement);

    statement.updateClause.child = node;

    return statement;
  }

  @override
  SqlNodeList createWrapperNodeList(nodes) =>
      createTypedWrapperNodeList(null, nodes);

  @override
  void registerNode(RegistrableSqlNode node) {
    if (!nodeTypes.contains(node.type)) {
      throw new StateError("Node type not registered: ${node.type}");
    }

    node.registerNode(this);
  }

  void registerNodeType(String type) {
    if (!nodeTypes.contains(type)) {
      nodeTypes.add(type);
    } else {
      throw new StateError("Node type already registered: $type");
    }
  }

  void _registerCustomNodeType(String type) {
    if (!customNodeTypes.contains(type)) {
      registerNodeType(type);

      customNodeTypes.add(type);
    }
  }
}
