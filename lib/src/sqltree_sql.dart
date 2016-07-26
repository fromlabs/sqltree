// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_node_impl.dart";
import "sqltree_statement.dart";
import "sqltree_statement_impl.dart";
import "sqltree_custom_impl.dart";
import "sqltree_parameter.dart";
import "sqltree_parameter_impl.dart";
import "sqltree_node_manager.dart";
import "sqltree_node_manager_impl.dart";
import "sqltree_formatter.dart";
import "sqltree_formatter_impl.dart";
import "sqltree_prettifier.dart";
import "sqltree_prettifier_impl.dart";
import "sqltree_util.dart";

final SqlNodeTypes types = new SqlNodeTypes();

class SqlNodeTypes extends BaseSqlNodeTypes {
  final String TEXT = "'";
  final String BLOCK = "()";
  final String TUPLE = "n()";
  final String INDEXED_PARAMETER = "?";
  final String NAMED_PARAMETER = r"$";
  final String LIKE = "LIKE";
  final String UPPER = "UPPER";
  final String LOWER = "LOWER";
  final String COALESCE = "COALESCE";
  final String NOT = "NOT";
  final String EQUAL = "=";
  final String NOT_EQUAL = "<>";
  final String GREATER = ">";
  final String GREATER_OR_EQUAL = ">=";
  final String LESS = "<";
  final String LESS_OR_EQUAL = "<=";
  final String AS = "AS";
  final String QUALIFIER = ".";
  final String AND = "AND";
  final String OR = "OR";
  final String ASC = "ASC";
  final String DESC = "DESC";
  final String IS_NULL = "IS NULL";
  final String IS_NOT_NULL = "IS NOT NULL";
  final String IN = "IN";
  final String NULL = "NULL";

  SqlNodeTypes() {
    _registerTypes(this);

    // TODO use a callback
    _initialize(this);
  }

  void _registerTypes(SqlNodeTypes types) {
    registerNodeType(types.TEXT);
    registerNodeType(types.BLOCK);
    registerNodeType(types.TUPLE);
    registerNodeType(types.INDEXED_PARAMETER);
    registerNodeType(types.NAMED_PARAMETER);
    registerNodeType(types.COUNT, (node) => node is SqlFunctionImpl);
    registerNodeType(types.COALESCE, (node) => node is SqlFunctionImpl);
    registerNodeType(types.LIKE, (node) => node is SqlOperatorImpl);
    registerNodeType(types.UPPER, (node) => node is SqlFunctionImpl);
    registerNodeType(types.LOWER, (node) => node is SqlFunctionImpl);
    registerNodeType(types.NOT, (node) => node is SqlOperatorImpl);
    registerNodeType(types.EQUAL, (node) => node is SqlOperatorImpl);
    registerNodeType(types.NOT_EQUAL, (node) => node is SqlOperatorImpl);
    registerNodeType(types.GREATER, (node) => node is SqlOperatorImpl);
    registerNodeType(types.GREATER_OR_EQUAL, (node) => node is SqlOperatorImpl);
    registerNodeType(types.LESS, (node) => node is SqlOperatorImpl);
    registerNodeType(types.LESS_OR_EQUAL, (node) => node is SqlOperatorImpl);
    registerNodeType(types.AND, (node) => node is SqlOperatorImpl);
    registerNodeType(types.OR, (node) => node is SqlOperatorImpl);
    registerNodeType(types.ASC);
    registerNodeType(types.DESC);
    registerNodeType(types.IS_NULL);
    registerNodeType(types.IS_NOT_NULL);
    registerNodeType(types.NULL);
    registerNodeType(types.IN, (node) => node is SqlOperatorImpl);
    registerNodeType(types.AS, (node) => node is SqlOperatorImpl);
    registerNodeType(types.QUALIFIER);
  }
}

/* CONFIGURATION */

void registerNodeType(String type, [bool checkNode(SqlNode node)]) {
  _NODE_MANAGER.registerNodeType(type, checkNode);
}

registerNode(SqlNode node) => _NODE_MANAGER.registerNode(node);

void registerNodeFormatter(SqlNodeFormatterFunction formatter) {
  _NODE_FORMATTER.registerNodeFormatter(formatter);
}

/* UTILS */

String format(SqlNode node) => _NODE_FORMATTER.format(node);

String prettify(String sql) => _SQL_PRETTIFIER.prettify(sql);

SqlNamedParameterConversion convert(String sql) => _NODE_CONVERTER.convert(sql);

/* STATEMENT */

SqlSelectStatement select(
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  var parent = registerNode(new SqlSelectStatementImpl());

  parent.selectClause.children.addAll(node(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

  return parent;
}

SqlUpdateStatement update([node]) {
  var parent = registerNode(new SqlUpdateStatementImpl());

  parent.updateClause.child = node;

  return parent;
}

SqlInsertStatement insert([node]) {
  var parent = registerNode(new SqlInsertStatementImpl());

  parent.insertClause.child = node;

  return parent;
}

SqlDeleteStatement delete([node]) {
  var parent = registerNode(new SqlDeleteStatementImpl());

  parent.deleteClause.child = node;

  return parent;
}

SqlJoins joins(
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  var parent = registerNode(new SqlJoinsImpl());

  parent.children.addAll(node(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

  return parent;
}

SqlJoin leftJoin(fromNode,
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
  var parent = registerNode(new SqlJoinImpl(types.LEFT_JOIN));

  parent.fromClause.children.addAll(node(fromNode));
  parent.onClause.children.addAll(node(onNode0, onNode1, onNode2, onNode3,
      onNode4, onNode5, onNode6, onNode7, onNode8, onNode9));

  return parent;
}

SqlJoin join(fromNode,
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
  var parent = registerNode(new SqlJoinImpl(types.INNER_JOIN));

  parent.fromClause.children.addAll(node(fromNode));
  parent.onClause.children.addAll(node(onNode0, onNode1, onNode2, onNode3,
      onNode4, onNode5, onNode6, onNode7, onNode8, onNode9));

  return parent;
}

/* FUNCTION & OPERATOR */

SqlNode get NULL => _node(types.NULL, 0);

SqlNode block([node]) => _node(types.BLOCK, 1, node);

SqlNode tuple(
        [node0,
        node1,
        node2,
        node3,
        node4,
        node5,
        node6,
        node7,
        node8,
        node9]) =>
    _node(types.TUPLE, null, node0, node1, node2, node3, node4, node5, node6,
        node7, node8, node9);

SqlNode parameter([String name]) => name != null
    ? _node(types.NAMED_PARAMETER, 1, name)
    : _node(types.INDEXED_PARAMETER, 0);

SqlNode asc(node) => _node(types.ASC, 1, node);

SqlNode desc(node) => _node(types.DESC, 1, node);

SqlNode isNull(node) => _node(types.IS_NULL, 1, node);

SqlNode isNotNull(node) => _node(types.IS_NOT_NULL, 1, node);

SqlNode not(node) => _unaryOperator(types.NOT, node);

SqlNode count(node) => _function(types.COUNT, 1, node);

SqlNode coalesce(node0, node1) => _function(types.COALESCE, 2, node0, node1);

SqlNode as(node, alias) => _binaryOperator(types.AS, node, alias);

SqlNode equal(node0, node1) => _binaryOperator(types.EQUAL, node0, node1);

SqlNode notEqual(node0, node1) =>
    _binaryOperator(types.NOT_EQUAL, node0, node1);

SqlNode greater(node0, node1) => _binaryOperator(types.GREATER, node0, node1);

SqlNode greaterOrEqual(node0, node1) =>
    _binaryOperator(types.GREATER_OR_EQUAL, node0, node1);

SqlNode less(node0, node1) => _binaryOperator(types.LESS, node0, node1);

SqlNode lessOrEqual(node0, node1) =>
    _binaryOperator(types.LESS_OR_EQUAL, node0, node1);

SqlNode and(
        [node0,
        node1,
        node2,
        node3,
        node4,
        node5,
        node6,
        node7,
        node8,
        node9]) =>
    _operator(types.AND, null, node0, node1, node2, node3, node4, node5, node6,
        node7, node8, node9);

SqlNode or(
        [node0,
        node1,
        node2,
        node3,
        node4,
        node5,
        node6,
        node7,
        node8,
        node9]) =>
    _operator(types.OR, null, node0, node1, node2, node3, node4, node5, node6,
        node7, node8, node9);

SqlNode sqlIn(node0, node1) => _binaryOperator(types.IN, node0, node1);

SqlNode sqlInBlock(node, [node0]) => sqlIn(node, block(node0));

SqlNode sqlInTuple(node,
        [node0,
        node1,
        node2,
        node3,
        node4,
        node5,
        node6,
        node7,
        node8,
        node9]) =>
    sqlIn(
        node,
        tuple(node0, node1, node2, node3, node4, node5, node6, node7, node8,
            node9));

SqlNode like(node0, node1) => _binaryOperator(types.LIKE, node0, node1);

SqlNode upper(node) => _function(types.UPPER, 1, node);

SqlNode lower(node) => _function(types.LOWER, 1, node);

/* DECORATORS */

SqlNodeIterable<SqlNode> setReference(String reference, node0,
        [node1, node2, node3, node4, node5, node6, node7, node8, node9]) =>
    node(node0, node1, node2, node3, node4, node5, node6, node7, node8, node9)
        .mapNodes((node) => node..reference = reference);

SqlNodeIterable<SqlNode> setEnabled(bool isEnabled, node0,
        [node1, node2, node3, node4, node5, node6, node7, node8, node9]) =>
    node(node0, node1, node2, node3, node4, node5, node6, node7, node8, node9)
        .mapNodes((node) => node..isEnabled = isEnabled);

SqlNodeIterable<SqlNode> setDisabled(bool isDisabled, node0,
        [node1, node2, node3, node4, node5, node6, node7, node8, node9]) =>
    node(node0, node1, node2, node3, node4, node5, node6, node7, node8, node9)
        .mapNodes((node) => node..isDisabled = isDisabled);

SqlNodeIterable<SqlNode> enable(node0,
        [node1, node2, node3, node4, node5, node6, node7, node8, node9]) =>
    node(node0, node1, node2, node3, node4, node5, node6, node7, node8, node9)
        .mapNodes((node) => node..enable());

SqlNodeIterable<SqlNode> disable(node0,
        [node1, node2, node3, node4, node5, node6, node7, node8, node9]) =>
    node(node0, node1, node2, node3, node4, node5, node6, node7, node8, node9)
        .mapNodes((node) => node..disable());

SqlNodeIterable<SqlNode> text(node0,
        [node1, node2, node3, node4, node5, node6, node7, node8, node9]) =>
    node(node0, node1, node2, node3, node4, node5, node6, node7, node8, node9)
        .mapNodes((node) => _node(types.TEXT, 1, node));

SqlNodeIterable<SqlNode> qualify(String qualifier, node0,
        [node1, node2, node3, node4, node5, node6, node7, node8, node9]) =>
    node(node0, node1, node2, node3, node4, node5, node6, node7, node8, node9)
        .mapNodes((node) => _node(types.QUALIFIER, 2, qualifier, node));

SqlNodeIterable<SqlNode> node(node0,
        [node1, node2, node3, node4, node5, node6, node7, node8, node9]) =>
    _NODE_MANAGER.normalize(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);

/* CUSTOMS */

SqlNode custom(String type,
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  _NODE_MANAGER.registerCustomNodeType(
      type, (node) => node is SqlCustomNodeImpl);

  var parent = registerNode(new SqlCustomNodeImpl(type));

  parent.children.addAll(node(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

  return parent;
}

SqlFunction function(String function,
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  _NODE_MANAGER.registerCustomNodeType(
      function, (node) => node is SqlCustomFunctionImpl);

  var parent = registerNode(new SqlCustomFunctionImpl(function));

  parent.children.addAll(node(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

  return parent;
}

SqlOperator operator(String operator,
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  _NODE_MANAGER.registerCustomNodeType(
      operator, (node) => node is SqlCustomOperatorImpl);

  var parent = registerNode(new SqlCustomOperatorImpl(operator));

  parent.children.addAll(node(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

  return parent;
}

SqlOperator unaryOperator(String operator, node) {
  _NODE_MANAGER.registerCustomNodeType(
      operator, (node) => node is SqlCustomOperatorImpl);

  var parent =
      registerNode(new SqlCustomOperatorImpl(operator, maxChildrenLength: 1));

  parent.children.addAll(node(node));

  return parent;
}

SqlOperator binaryOperator(String operator, node0, node1) {
  _NODE_MANAGER.registerCustomNodeType(
      operator, (node) => node is SqlCustomOperatorImpl);

  var parent =
      registerNode(new SqlCustomOperatorImpl(operator, maxChildrenLength: 2));

  parent.children.addAll(node(node0, node1));

  return parent;
}

SqlFormattedNode formatted(String prefix, String separator, String postfix,
    bool formatEmptyChildrenEnabled, int maxChildrenLength,
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  var parent = registerNode(new SqlFormattedNodeImpl(
      (node, formattedChildren) => formatByRule(formattedChildren,
          prefix: prefix,
          separator: separator,
          postfix: postfix,
          isFormatEmptyChildrenEnabled: formatEmptyChildrenEnabled),
      maxChildrenLength: maxChildrenLength));

  parent.children.addAll(node(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

  return parent;
}

SqlOperator _unaryOperator(String operator, node) =>
    _operator(operator, 1, node);

SqlOperator _binaryOperator(String operator, node0, node1) =>
    _operator(operator, 2, node0, node1);

SqlFunction _function(String function, int maxChildrenLength,
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  var parent = registerNode(
      new SqlFunctionImpl(function, maxChildrenLength: maxChildrenLength));

  parent.children.addAll(node(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

  return parent;
}

SqlOperator _operator(String operator, int maxChildrenLength,
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  var parent = registerNode(
      new SqlOperatorImpl(operator, maxChildrenLength: maxChildrenLength));

  parent.children.addAll(node(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

  return parent;
}

SqlNode _node(String type, int maxChildrenLength,
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  var parent =
      registerNode(new SqlNodeImpl(type, maxChildrenLength: maxChildrenLength));

  parent.children.addAll(node(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

  return parent;
}

SqlNodeManagerImpl _NODE_MANAGER = new SqlNodeManagerImpl();

SqlNodeFormatterImpl _NODE_FORMATTER = new SqlNodeFormatterImpl();

SqlPrettifier _SQL_PRETTIFIER = new SqlPrettifierImpl();

SqlNamedParameterConverter _NODE_CONVERTER =
    new SqlNamedParameterConverterImpl();

final Set<String> _blockNodes = new Set.from([types.BLOCK, types.TUPLE]);

final Set<String> _postNodes =
    new Set.from([types.IS_NOT_NULL, types.IS_NULL, types.ASC, types.DESC]);

final Set<String> _prefixNodes =
    new Set.from([types.INDEXED_PARAMETER, types.NULL]);

void _initialize(SqlNodeTypes types) {
  _registerFormatters();
}

void _registerFormatters() {
  registerNodeFormatter((node, formattedChildren) {
    if (types.NAMED_PARAMETER == node.type) {
      return formatByRule(formattedChildren, prefix: r"${", postfix: "}");
    } else if (types.TEXT == node.type) {
      return formatByRule(
          formattedChildren.map((formatted) =>
              formatted.replaceAll("'", "''").replaceAll(r"\", r"\\")),
          prefix: "'",
          postfix: "'",
          isFormatEmptyChildrenEnabled: true);
    } else if (_blockNodes.contains(node.type)) {
      return formatByRule(formattedChildren,
          prefix: "(", separator: ", ", postfix: ")");
    } else if (types.QUALIFIER == node.type) {
      return formatByRule(formattedChildren, separator: node.type);
    } else if (_postNodes.contains(node.type)) {
      return formatByRule(formattedChildren, postfix: " ${node.type}");
    } else if (_prefixNodes.contains(node.type)) {
      return formatByRule(formattedChildren,
          prefix: node.type, isFormatEmptyChildrenEnabled: true);
    }

    return null;
  });
}
