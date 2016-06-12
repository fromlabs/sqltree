// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;

import "ordersheet_sql_impl.dart";

final ExtTypes types = new ExtTypes();

class ExtTypes {
  final String IF = "IF";
  final String REPLACE = "REPLACE";
  final String GROUP_CONCAT_STATEMENT = "GROUP_CONCAT";
  final String GROUP_CONCAT_CLAUSE = "GROUP_CONCAT_CLAUSE";
  final String SEPARATOR_CLAUSE = "SEPARATOR";
  // sfruttiamo un tipo esistente
  final String ORDER_BY_CLAUSE = sql.types.ORDER_BY_CLAUSE;

  ExtTypes() {
    _registerTypes(this);

    _initialize(this);
  }

  void _registerTypes(ExtTypes types) {
    sql.registerNodeType(types.IF);
    sql.registerNodeType(types.REPLACE);
    sql.registerNodeType(types.GROUP_CONCAT_STATEMENT);
    sql.registerNodeType(types.GROUP_CONCAT_CLAUSE);
    sql.registerNodeType(types.SEPARATOR_CLAUSE);
    // già registrato
    // sql.registerNodeType(types.ORDER_BY_CLAUSE);
  }
}

void _initialize(ExtTypes types) {
  _registerFormatters(types);

  _registerFormatRuleProviders(types);
}

void _registerFormatters(ExtTypes types) {
  // è solo un esempio di utilizzo che in realtà non fa niente
  sql.registerNodeFormatter(new sql.SqlNodeFormatterFunctionWrapper((node) {}));
}

void _registerFormatRuleProviders(ExtTypes types) {
  sql.registerFormatRuleProvider((node) {
    if (types.GROUP_CONCAT_STATEMENT == node.type) {
      return new sql.SqlFormatRule(
          prefix: "${node.type}(", separator: " ", postfix: ")");
    } else if (node is GroupConcatClause) {
      return new sql.SqlFormatRule(
          prefix: node.isDistinct ? "DISTINCT " : null, separator: ", ");
    } else if (types.SEPARATOR_CLAUSE == node.type) {
      return new sql.SqlFormatRule(prefix: "${node.type} ", separator: " ");
    }
  });
}

sql.SqlNode ifThen(condition, nodeIf, nodeThen) {
  var parent = sql.registerNode(new sql.CustomSqlFunction(types.IF, 3, false));

  parent.addChildren(condition, nodeIf, nodeThen);

  return parent;
}

sql.SqlNode replace(node, from, to) {
  var parent =
      sql.registerNode(new sql.CustomSqlFunction(types.REPLACE, 3, false));

  parent.addChildren(node, from, to);

  return parent;
}

GroupConcatNode groupConcat(
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  var parent = sql.registerNode(new GroupConcatNodeImpl(false));

  parent.groupConcat(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);

  return parent;
}

abstract class GroupConcatNode implements sql.SqlNode {
  void distinct([bool isDistinct = true]);

  void groupConcat(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void orderBy(
      [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]);

  void separator(node);

  bool get isDistinct;

  GroupConcatClause get groupConcatClause;

  sql.SqlNode get orderByClause;

  sql.SqlNode get separatorClause;

  void clearGroupConcat();

  void clearOrderBy();

  void clearSeparator();

  GroupConcatNode clone({bool freeze});
}

abstract class GroupConcatClause implements sql.SqlNode {
  bool get isDistinct;

  void set isDistinct(bool isDistinct);

  GroupConcatClause clone({bool freeze});
}
