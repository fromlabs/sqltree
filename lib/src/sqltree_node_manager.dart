// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";

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

abstract class SqlNodeManager {
  registerNode(SqlNode node);

  SqlNodeIterable<SqlNode> normalize(nodes);
}