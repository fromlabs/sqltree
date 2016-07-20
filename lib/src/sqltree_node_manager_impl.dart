// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_node_impl.dart";
import "sqltree_statement_impl.dart";
import "sqltree_node_manager.dart";
import "sqltree_formatter_impl.dart";

class SqlNodeManagerImpl implements SqlNodeManager {
  static final Set<String> customNodeTypes = new Set<String>();

  final Set<String> nodeTypes = new Set<String>();
  final Map<String, SqlNodeCheck> nodeChecks = new Map<String, SqlNodeCheck>();

  SqlNodeManagerImpl() {
    _registerTypes();
  }

  void _registerTypes() {
    registerNodeType(BaseSqlNodeTypes.types.RAW, (node) => node.isRawNode);
    registerNodeType(BaseSqlNodeTypes.types.SELECT_STATEMENT,
        (node) => node is SqlSelectStatementImpl);
    registerNodeType(BaseSqlNodeTypes.types.UPDATE_STATEMENT,
        (node) => node is SqlUpdateStatementImpl);
    registerNodeType(BaseSqlNodeTypes.types.DELETE_STATEMENT,
        (node) => node is SqlDeleteStatementImpl);
    registerNodeType(BaseSqlNodeTypes.types.INSERT_STATEMENT,
        (node) => node is SqlInsertStatementImpl);
    registerNodeType(BaseSqlNodeTypes.types.SELECT_CLAUSE,
        (node) => node is SqlSelectClauseImpl);
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
    registerNodeType(
        BaseSqlNodeTypes.types.JOINS, (node) => node is SqlJoinsImpl);
    registerNodeType(
        BaseSqlNodeTypes.types.INNER_JOIN, (node) => node is SqlJoinImpl);
    registerNodeType(
        BaseSqlNodeTypes.types.LEFT_JOIN, (node) => node is SqlJoinImpl);
    registerNodeType(BaseSqlNodeTypes.types.JOIN_FROM);
    registerNodeType(BaseSqlNodeTypes.types.JOIN_ON);
    registerNodeType(BaseSqlNodeTypes.types.FORMATTED,
        (node) => node is SqlFormattedNodeImpl);
  }

  @override
  registerNode(SqlNode node) {
    if (node is RegistrableSqlNode) {
      if (!nodeTypes.contains(node.type)) {
        throw new StateError("Node type not registered: ${node.type}");
      }

      var typeTest = nodeChecks[node.type] ?? (node) => node is SqlNodeImpl;
      if (!typeTest(node)) {
        throw new StateError("Node not valid");
      }

      (node as RegistrableSqlNode).registerNode(this);

      return node;
    } else {
      throw new ArgumentError("Node not registrable: ${node.type}");
    }
  }

  void registerNodeType(String type, [SqlNodeCheck typeTest]) {
    if (!nodeTypes.contains(type)) {
      nodeTypes.add(type);
      nodeChecks[type] = typeTest;
    } else {
      throw new StateError("Node type already registered: $type");
    }
  }

  void registerCustomNodeType(String type, [SqlNodeCheck typeTest]) {
    if (!customNodeTypes.contains(type)) {
      registerNodeType(type, typeTest);

      customNodeTypes.add(type);
    }
  }

  @override
  SqlNodeIterable<SqlNode> normalize(node0,
          [node1, node2, node3, node4, node5, node6, node7, node8, node9]) =>
      new DelegatingSqlNodeIterable<SqlNode>([
        node0,
        node1,
        node2,
        node3,
        node4,
        node5,
        node6,
        node7,
        node8,
        node9
      ]
          .where((node) => node != null)
          .expand((nodes) => _normalizeInternal(nodes)));

  Iterable<SqlNode> _normalizeInternal(nodes) sync* {
    if (nodes != null) {
      var previous;
      while (nodes != previous && nodes is SqlNodeProvider) {
        previous = nodes;
        nodes = nodes.createNode();
      }
      if (nodes is Iterable) {
        yield* nodes.expand(normalize);
      } else if (nodes is SqlNode) {
        yield nodes;
      } else {
        yield registerNode(new SqlNodeImpl.raw(nodes));
      }
    }
  }
}

abstract class RegistrableSqlNode {
  bool get isRegistered;

  void registerNode(SqlNodeManager nodeManager);
}
