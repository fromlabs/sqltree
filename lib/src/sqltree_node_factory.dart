// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_statement.dart";

// TODO capire se possibile togliere tutti i varargs e lasciarli solo dentro a sql

class BaseSqlNodeTypes {
  final String RAW = "#";
  final String GROUP = "@";

  final String SELECT_STATEMENT = "SELECT_STATEMENT";
  final String UPDATE_STATEMENT = "UPDATE_STATEMENT";
  final String INSERT_STATEMENT = "INSERT_STATEMENT";
  final String DELETE_STATEMENT = "DELETE_STATEMENT";

  final String SELECT_CLAUSE = "SELECT";
  final String UPDATE_CLAUSE = "UPDATE";
  final String INSERT_CLAUSE = "INSERT INTO";
  final String DELETE_CLAUSE = "DELETE";
  final String SET_CLAUSE = "SET";
  final String COLUMNS_CLAUSE = "COLUMNS";
  final String VALUES_CLAUSE = "VALUES";
  final String FROM_CLAUSE = "FROM";
  final String WHERE_CLAUSE = "WHERE";
  final String GROUP_BY_CLAUSE = "GROUP BY";
  final String HAVING_CLAUSE = "HAVING";
  final String ORDER_BY_CLAUSE = "ORDER BY";
  final String LIMIT_CLAUSE = "LIMIT";
  final String OFFSET_CLAUSE = "OFFSET";

  final String JOINS = "JOINS";
  final String INNER_JOIN = "JOIN";
  final String LEFT_JOIN = "LEFT JOIN";
  final String JOIN_FROM = "JOIN_FROM";
  final String JOIN_ON = "ON";
  final String COUNT = "COUNT";

  final String FORMATTED = "FORMATTED";

  static final BaseSqlNodeTypes types = new BaseSqlNodeTypes();
}

abstract class SqlNodeFactory {
  SqlSelectStatement createSelectStatement(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlInsertStatement createInsertStatement(node);

  SqlUpdateStatement createUpdateStatement(node);

  SqlDeleteStatement createDeleteStatement(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlSelectClause createSelectClause();

  SqlJoins createSqlJoin(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlJoin createInnerJoin(fromNode,
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

  SqlJoin createLeftJoin(fromNode,
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

  SqlFunction createCount([node]);

  SqlGroup createGroup(String reference, [node]);

  SqlOperator createCustomOperator(String operator, int maxChildrenLength,
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlFunction createCustomFunction(String function, int maxChildrenLength,
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlOperator createOperator(String operator, int maxChildrenLength,
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlFunction createFunction(String function, int maxChildrenLength,
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlNode createNode(String type, int maxChildrenLength,
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  // TODO trovare un nome diverso per la funzione che normalizza un array di oggetti

  SqlNodeList createWrapperNodeList(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  SqlNodeList createTypedWrapperNodeList(String type,
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void registerNode(RegistrableSqlNode node);
}

abstract class RegistrableSqlNode implements SqlNode {
  void registerNode(SqlNodeFactory nodeFactory);
}
