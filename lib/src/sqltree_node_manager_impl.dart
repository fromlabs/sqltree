// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_node_impl.dart";
import "sqltree_node_manager.dart";
import "sqltree_util.dart";

class SqlNodeManagerImpl implements SqlNodeManager {
  static final Set<String> customNodeTypes = new Set<String>();

  final Set<String> nodeTypes = new Set<String>();

  SqlNodeManagerImpl() {
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
  registerNode(RegistrableSqlNode node) {
    if (!nodeTypes.contains(node.type)) {
      throw new StateError("Node type not registered: ${node.type}");
    }

    node.registerNode(this);

    return node;
  }

  void registerNodeType(String type) {
    if (!nodeTypes.contains(type)) {
      nodeTypes.add(type);
    } else {
      throw new StateError("Node type already registered: $type");
    }
  }

  void registerCustomNodeType(String type) {
    if (!customNodeTypes.contains(type)) {
      registerNodeType(type);

      customNodeTypes.add(type);
    }
  }

  @override
  SqlNodeList normalize(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    var result = new SqlNodeListImpl();

    for (var node in getVargsList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9)) {
      if (node is SqlNodeConvertable) {
        node = node.toNode();
      }

      if (node is Iterable) {
        for (var child in node) {
          result.addAll(normalize(child));
        }
      } else if (node is SqlNode) {
        result.add(node);
      } else {
        result.add(registerNode(new SqlNodeImpl.raw(node)));
      }
    }
    return result;
  }
}
