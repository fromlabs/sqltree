// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;

import "custom_sql_impl.dart";

final ExtTypes types = new ExtTypes();

class ExtTypes {
  final String IF = "IF";
  final String REPLACE = "REPLACE";
  final String GROUP_CONCAT_STATEMENT = "GROUP_CONCAT";
  final String GROUP_CONCAT_CLAUSE = "GROUP_CONCAT_CLAUSE";
  final String SEPARATOR_CLAUSE = "SEPARATOR";
  final String GROUP_CONCAT_ORDER_BY_CLAUSE = "GROUP_CONCAT_ORDER_BY_CLAUSE";

  ExtTypes() {
    _registerTypes(this);

    // TODO use a callback
    _initialize(this);
  }

  void _registerTypes(ExtTypes types) {
    sql.registerNodeType(types.IF, (node) => node is sql.ExtensionSqlFunction);
    sql.registerNodeType(
        types.REPLACE, (node) => node is sql.ExtensionSqlFunction);
    sql.registerNodeType(types.GROUP_CONCAT_STATEMENT,
        (node) => node is GroupConcatStatementImpl);
    sql.registerNodeType(
        types.GROUP_CONCAT_CLAUSE, (node) => node is GroupConcatClauseImpl);
    sql.registerNodeType(
        types.SEPARATOR_CLAUSE, (node) => node is sql.ExtensionSqlNode);
    sql.registerNodeType(types.GROUP_CONCAT_ORDER_BY_CLAUSE,
        (node) => node is sql.ExtensionSqlNode);
  }
}

void _initialize(ExtTypes types) {
  _registerFormatters(types);
}

void _registerFormatters(ExtTypes types) {
  sql.registerNodeFormatter((node, formattedChildren) {
    if (types.GROUP_CONCAT_STATEMENT == node.type) {
      return sql.formatByRule(formattedChildren,
          prefix: "${node.type}(", separator: " ", postfix: ")");
    } else if (types.GROUP_CONCAT_ORDER_BY_CLAUSE == node.type) {
      return sql.formatByRule(formattedChildren,
          prefix: "ORDER BY ", separator: ", ");
    } else if (node is GroupConcatClause) {
      return sql.formatByRule(formattedChildren,
          prefix: node.isDistinct ? "DISTINCT " : null, separator: ", ");
    } else if (types.SEPARATOR_CLAUSE == node.type) {
      return sql.formatByRule(formattedChildren,
          prefix: "${node.type} ", separator: " ");
    }

    return null;
  });
}

sql.SqlNode ifThen(condition, nodeIf, nodeThen) {
  var parent = sql.registerNode(
      new sql.ExtensionSqlFunction(types.IF, maxChildrenLength: 3));

  parent.addChildren(condition, nodeIf, nodeThen);

  return parent;
}

sql.SqlNode replace(node, from, to) {
  var parent = sql.registerNode(
      new sql.ExtensionSqlFunction(types.REPLACE, maxChildrenLength: 3));

  parent.addChildren(node, from, to);

  return parent;
}

GroupConcatStatement groupConcat(
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  var parent = sql.registerNode(new GroupConcatStatementImpl());

  parent.groupConcat(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);

  return parent;
}

abstract class GroupConcatStatement implements sql.SqlNode {
  void distinct([bool isDistinct = true]);

  void groupConcat(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void orderBy(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void separator(node);

  bool get isDistinct;

  GroupConcatClause get groupConcatClause;

  sql.SqlNode get orderByClause;

  sql.SqlNode get separatorClause;

  void clearGroupConcat();

  void clearOrderBy();

  void clearSeparator();

  GroupConcatStatement clone({bool freeze});
}

abstract class GroupConcatClause implements sql.SqlNode {
  bool get isDistinct;

  void set isDistinct(bool isDistinct);

  GroupConcatClause clone({bool freeze});
}
