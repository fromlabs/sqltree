// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_statement.dart";
import "sqltree_parameter.dart";
import "sqltree_node_factory.dart";
import "sqltree_node_factory_impl.dart";
import "sqltree_formatter.dart";
import "sqltree_formatter_impl.dart";
import "sqltree_prettifier.dart";
import "sqltree_util.dart";

class SqlNodeTypes extends BaseSqlNodeTypes {
  final String TEXT = "'";
  final String BLOCK = "()";
  final String TUPLE = "n()";
  final String INDEXED_PARAMETER = "?";
  final String NAMED_PARAMETER = r"$";
  final String LIKE = "LIKE";
  final String UPPER = "UPPER";
  final String LOWER = "LOWER";
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

    _initialize(this);
  }

  void _registerTypes(SqlNodeTypes types) {
    registerNodeType(types.TEXT);
    registerNodeType(types.BLOCK);
    registerNodeType(types.TUPLE);
    registerNodeType(types.INDEXED_PARAMETER);
    registerNodeType(types.NAMED_PARAMETER);
    registerNodeType(types.COUNT);
    registerNodeType(types.LIKE);
    registerNodeType(types.UPPER);
    registerNodeType(types.LOWER);
    registerNodeType(types.NOT);
    registerNodeType(types.EQUAL);
    registerNodeType(types.NOT_EQUAL);
    registerNodeType(types.GREATER);
    registerNodeType(types.GREATER_OR_EQUAL);
    registerNodeType(types.LESS);
    registerNodeType(types.LESS_OR_EQUAL);
    registerNodeType(types.AND);
    registerNodeType(types.OR);
    registerNodeType(types.ASC);
    registerNodeType(types.DESC);
    registerNodeType(types.IS_NULL);
    registerNodeType(types.IS_NOT_NULL);
    registerNodeType(types.NULL);
    registerNodeType(types.IN);
    registerNodeType(types.AS);
    registerNodeType(types.QUALIFIER);
  }
}

final SqlNodeTypes types = new SqlNodeTypes();

SqlNodeFactoryImpl _NODE_FACTORY = new SqlNodeFactoryImpl();

SqlNodeFormatterImpl _NODE_FORMATTER = new SqlNodeFormatterImpl();

SqlPrettifier _SQL_PRETTIFIER = new SqlPrettifier();

SqlNode _NULL;

SqlNamedParameterConverter _NODE_CONVERTER = new SqlNamedParameterConverter();

final SqlFormatRule _namedParameterRule =
    new SqlFormatRule(prefix: r"${", postfix: "}");

// TODO attenzione agli escape
final SqlFormatRule _textRule = new SqlFormatRule(
    prefix: "'", postfix: "'", isFormatEmptyChildrenEnabled: true);

final SqlFormatRule _tupleRule =
    new SqlFormatRule(prefix: "(", separator: ", ", postfix: ")");

final Set<String> _blockNodes = new Set.from([types.BLOCK, types.TUPLE]);

final Set<String> _postNodes =
    new Set.from([types.IS_NOT_NULL, types.IS_NULL, types.ASC, types.DESC]);

final Set<String> _prefixNodes =
    new Set.from([types.INDEXED_PARAMETER, types.NULL]);

void _initialize(SqlNodeTypes types) {
  _registerFormatters();

  _registerFormatRuleProviders();

  _NULL = _NODE_FACTORY.createNode(types.NULL, 0);
}

void _registerFormatters() {
  // è solo un esempio di utilizzo che in realtà non fa niente
  registerNodeFormatter(new SqlNodeFormatterFunctionWrapper((node) {}));
}

void _registerFormatRuleProviders() {
  registerFormatRuleProvider((node) {
    if (types.NAMED_PARAMETER == node.type) {
      return _namedParameterRule;
    } else if (types.TEXT == node.type) {
      return _textRule;
    } else if (_blockNodes.contains(node.type)) {
      return _tupleRule;
    } else if (types.QUALIFIER == node.type) {
      return new SqlFormatRule(separator: node.type);
    } else if (_postNodes.contains(node.type)) {
      return new SqlFormatRule(postfix: " ${node.type}");
    } else if (_prefixNodes.contains(node.type)) {
      return new SqlFormatRule(
          prefix: node.type, isFormatEmptyChildrenEnabled: true);
    }
  });
}

void registerNodeType(String type) {
  _NODE_FACTORY.registerNodeType(type);
}

void registerNode(SqlNode node) {
  _NODE_FACTORY.registerNode(node);
}

void registerNodeFormatter(SqlNodeFormatter formatter) {
  _NODE_FORMATTER.registerNodeFormatter(formatter);
}

void registerFormatRuleProvider(SqlFormatRuleProvider provider) {
  _NODE_FORMATTER.registerFormatRuleProvider(provider);
}

/* EXTENSIONS */

String format(SqlNode node) => _NODE_FORMATTER.format(node);

String prettify(String sql) => _SQL_PRETTIFIER.prettify(sql);

SqlNamedParameterConversion convert(String sql) => _NODE_CONVERTER.convert(sql);

SqlFormattedNode formatted(String prefix, String separator, String postfix,
    bool formatEmptyChildrenEnabled, int maxChildrenLength,
    [node0, node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
  var formatted = new SqlFormattedNodeImpl(
      new SqlFormatRule(
          prefix: prefix,
          separator: separator,
          postfix: postfix,
          isFormatEmptyChildrenEnabled: formatEmptyChildrenEnabled),
      maxChildrenLength: maxChildrenLength);

  registerNode(formatted);

  formatted.addChildren(
      node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);

  return formatted;
}

/* STATEMENT */

SqlSelectStatement select(
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
    _NODE_FACTORY.createSelectStatement(getVargsList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

SqlUpdateStatement update([node]) => _NODE_FACTORY.createUpdateStatement(node);

SqlInsertStatement insert([node]) => _NODE_FACTORY.createInsertStatement(node);

SqlDeleteStatement delete(
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
    _NODE_FACTORY.createDeleteStatement(getVargsList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

SqlJoins joins(
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
    _NODE_FACTORY.createSqlJoin(getVargsList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

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
        onNode9]) =>
    _NODE_FACTORY.createLeftJoin(
        fromNode,
        getVargsList(onNode0, onNode1, onNode2, onNode3, onNode4, onNode5, onNode6,
            onNode7, onNode8, onNode9));

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
        onNode9]) =>
    _NODE_FACTORY.createInnerJoin(
        fromNode,
        getVargsList(onNode0, onNode1, onNode2, onNode3, onNode4, onNode5, onNode6,
            onNode7, onNode8, onNode9));

/* DECORATORS */

SqlNodeList text(
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
    _NODE_FACTORY.createTypedWrapperNodeList(
        types.TEXT,
        getVargsList(node0, node1, node2, node3, node4, node5, node6, node7, node8,
            node9));

SqlNodeList node(
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
    _NODE_FACTORY.createWrapperNodeList(getVargsList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

SqlNodeList group(reference,
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
    _NODE_FACTORY.createWrapperNodeList(getVargsList(node0, node1, node2, node3,
            node4, node5, node6, node7, node8, node9)
        .map((node) => _NODE_FACTORY.createGroup(reference, node)));

SqlNodeList qualify(String qualifier,
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
    _NODE_FACTORY.createWrapperNodeList(getVargsList(node0, node1, node2, node3,
            node4, node5, node6, node7, node8, node9)
        .map((node) =>
            _NODE_FACTORY.createNode(types.QUALIFIER, 2, [qualifier, node])));

/* FUNCTION & OPERATOR */

SqlNode get NULL => _NULL;

SqlNode block([node]) => _NODE_FACTORY.createNode(types.BLOCK, 1, node);

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
    _NODE_FACTORY.createNode(
        types.TUPLE,
        null,
        getVargsList(node0, node1, node2, node3, node4, node5, node6, node7, node8,
            node9));

SqlNode parameter([String name]) => name != null
    ? _NODE_FACTORY.createNode(types.NAMED_PARAMETER, 1, name)
    : _NODE_FACTORY.createNode(types.INDEXED_PARAMETER, 0);

SqlNode asc(node) => _NODE_FACTORY.createNode(types.ASC, 1, node);

SqlNode desc(node) => _NODE_FACTORY.createNode(types.DESC, 1, node);

SqlNode isNull(node) => _NODE_FACTORY.createNode(types.IS_NULL, 1, node);

SqlNode isNotNull(node) => _NODE_FACTORY.createNode(types.IS_NOT_NULL, 1, node);

SqlOperator not(node) => _NODE_FACTORY.createOperator(types.NOT, 1, node);

SqlFunction count([node]) => _NODE_FACTORY.createCount(node);

SqlOperator as(node, String alias) =>
    _NODE_FACTORY.createOperator(types.AS, 2, [node, alias]);

SqlOperator equal(node0, node1) =>
    _NODE_FACTORY.createOperator(types.EQUAL, 2, [node0, node1]);

SqlOperator notEqual(node0, node1) =>
    _NODE_FACTORY.createOperator(types.NOT_EQUAL, 2, [node0, node1]);

SqlOperator greater(node0, node1) =>
    _NODE_FACTORY.createOperator(types.GREATER, 2, [node0, node1]);

SqlOperator greaterOrEqual(node0, node1) =>
    _NODE_FACTORY.createOperator(types.GREATER_OR_EQUAL, 2, [node0, node1]);

SqlOperator less(node0, node1) =>
    _NODE_FACTORY.createOperator(types.LESS, 2, [node0, node1]);

SqlOperator lessOrEqual(node0, node1) =>
    _NODE_FACTORY.createOperator(types.LESS_OR_EQUAL, 2, [node0, node1]);

SqlOperator and(
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
    _NODE_FACTORY.createOperator(
        types.AND,
        null,
        getVargsList(node0, node1, node2, node3, node4, node5, node6, node7, node8,
            node9));

SqlOperator or(
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
    _NODE_FACTORY.createOperator(
        types.OR,
        null,
        getVargsList(node0, node1, node2, node3, node4, node5, node6, node7, node8,
            node9));

SqlOperator sqlIn(node0, node1) =>
    _NODE_FACTORY.createOperator(types.IN, 2, [node0, node1]);

SqlOperator sqlInBlock(node, [node0]) => sqlIn(node, block(node0));

SqlOperator sqlInTuple(node,
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

SqlOperator like(node0, node1) =>
    _NODE_FACTORY.createOperator(types.LIKE, 2, [node0, node1]);

SqlFunction upper(node) => _NODE_FACTORY.createFunction(types.UPPER, 1, node);

SqlFunction lower(node) => _NODE_FACTORY.createFunction(types.LOWER, 1, node);

/* CUSTOMS */

SqlFunction function(String function,
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
    _NODE_FACTORY.createCustomFunction(
        function,
        null,
        getVargsList(node0, node1, node2, node3, node4, node5, node6, node7, node8,
            node9));

SqlOperator operator(String operator,
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
    _NODE_FACTORY.createCustomOperator(
        operator,
        null,
        getVargsList(node0, node1, node2, node3, node4, node5, node6, node7, node8,
            node9));

SqlOperator unaryOperator(String operator, node) =>
    _NODE_FACTORY.createCustomOperator(operator, 1, node);

SqlOperator binaryOperator(String operator, node0, node1) =>
    _NODE_FACTORY.createCustomOperator(operator, 2, [node0, node1]);
