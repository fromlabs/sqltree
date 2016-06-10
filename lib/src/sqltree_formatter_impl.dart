// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_formatter.dart";
import "sqltree_node_factory.dart";
import "sqltree_node.dart";
import "sqltree_node_impl.dart";
import "sqltree_statement.dart";
import "sqltree_util.dart";

// TODO studiare un motore di regole più snello e veloce che crei meno oggetti

class SqlNodeFormatterImpl implements SqlNodeFormatter {
  static const String _EMPTY = "";

  final List<SqlNodeFormatter> _formatters = [];

  final List<SqlFormatRuleProvider> _ruleProviders = [];

  static final SqlFormatRule _joinsRule = new SqlFormatRule(separator: " ");

  static final SqlFormatRule _columnsRule =
      new SqlFormatRule(prefix: "(", separator: ", ", postfix: ")");

  static final SqlFormatRule _emptyRule = new SqlFormatRule();

  static final SqlFormatRule _onRule =
      new SqlFormatRule(prefix: "ON ", separator: " AND ");

  static final Set<String> _clauseNodes = new Set.from([
    BaseSqlNodeTypes.types.INSERT_CLAUSE,
    BaseSqlNodeTypes.types.VALUES_CLAUSE,
    BaseSqlNodeTypes.types.UPDATE_CLAUSE,
    BaseSqlNodeTypes.types.SET_CLAUSE,
    BaseSqlNodeTypes.types.FROM_CLAUSE,
    BaseSqlNodeTypes.types.GROUP_BY_CLAUSE,
    BaseSqlNodeTypes.types.HAVING_CLAUSE,
    BaseSqlNodeTypes.types.ORDER_BY_CLAUSE,
    BaseSqlNodeTypes.types.LIMIT_CLAUSE,
    BaseSqlNodeTypes.types.OFFSET_CLAUSE
  ]);

  static final Set<String> _whereNodes = new Set.from(
      [BaseSqlNodeTypes.types.WHERE_CLAUSE, BaseSqlNodeTypes.types.JOIN_ON]);

  static final Set<String> _emptyNodes = new Set.from(
      [BaseSqlNodeTypes.types.JOIN_FROM, BaseSqlNodeTypes.types.GROUP]);

  @override
  String format(SqlNode node) {
    if (node == null || node.isDisabled) {
      return _EMPTY;
    } else if (node.isComposite) {
      String formatted;

      for (SqlNodeFormatter formatter in _formatters) {
        formatted = formatter.format(node);
        if (formatted != null) {
          return formatted;
        }
      }

      return _defaultFormat(node);
    } else {
      return node.rawExpression;
    }
  }

  void registerNodeFormatter(SqlNodeFormatter formatter) {
    _formatters.add(formatter);
  }

  void registerFormatRuleProvider(SqlFormatRuleProvider provider) {
    _ruleProviders.add(provider);
  }

  String _defaultFormat(SqlNode node) {
    List<String> formattedChildren = _getFormattedChildren(node);

    SqlFormatRule rule = _getSupportedRule(node);

    if (rule == null) {
      for (SqlFormatRuleProvider provider in _ruleProviders) {
        rule = provider(node);
        if (rule != null) {
          break;
        }
      }
    }

    if (rule == null) {
      rule = _getDefaultRule(node);
    }

    if (formattedChildren.isNotEmpty || rule.isFormatEmptyChildrenEnabled) {
      StringBuffer buffer = new StringBuffer();

      if (isNotEmptyString(rule.prefix)) {
        buffer.write(rule.prefix);
      }

      buffer.write(formattedChildren.join(rule.separator ?? _EMPTY));

      if (isNotEmptyString(rule.postfix)) {
        buffer.write(rule.postfix);
      }

      return buffer.toString();
    } else {
      return _EMPTY;
    }
  }

  SqlFormatRule _getSupportedRule(SqlNode node) {
    if (node is SqlStatement) {
      return new SqlFormatRule(separator: " ");
    } else if (node is SqlSelectClause) {
      return new SqlFormatRule(
          prefix: "${node.type} ${node.isDistinct ? "DISTINCT " : ""}",
          separator: ", ");
    } else if (node is SqlFormattedNode) {
      return node.rule;
    } else if (node is SqlFunction) {
      return new SqlFormatRule(
          prefix: "${node.type}(",
          separator: ", ",
          postfix: ")",
          isFormatEmptyChildrenEnabled: true);
    } else if (node is SqlOperator) {
      if (node.isUnary) {
        return new SqlFormatRule(prefix: "${node.type} ", separator: ", ");
      } else {
        return new SqlFormatRule(separator: " ${node.type} ");
      }
    } else if (node is SqlJoins) {
      return _joinsRule;
    } else if (node is SqlJoin) {
      return new SqlFormatRule(prefix: "${node.type} ", separator: " ");
    } else if (_clauseNodes.contains(node.type)) {
      return new SqlFormatRule(prefix: "${node.type} ", separator: ", ");
    } else if (BaseSqlNodeTypes.types.DELETE_CLAUSE == node.type) {
      return new SqlFormatRule(
          prefix: "${node.type} ",
          separator: ", ",
          isFormatEmptyChildrenEnabled: true);
    } else if (_whereNodes.contains(node.type)) {
      return new SqlFormatRule(prefix: "${node.type} ", separator: " AND ");
    } else if (BaseSqlNodeTypes.types.COLUMNS_CLAUSE == node.type) {
      return _columnsRule;
    } else if (_emptyNodes.contains(node.type)) {
      return _emptyRule;
    } else if (BaseSqlNodeTypes.types.JOIN_ON == node.type) {
      return _onRule;
    }

    return null;
  }

  SqlFormatRule _getDefaultRule(SqlNode node) {
    print(
        "WARNING: undefined rule for node of type ${node.type} [${node.runtimeType}]");

    return new SqlFormatRule(
        prefix: "${node.type}(",
        separator: ", ",
        postfix: ")",
        isFormatEmptyChildrenEnabled: true);
  }

  List<String> _getFormattedChildren(SqlNode node) => node.children
      .map((childNode) => this.format(childNode))
      .where((formatted) => isNotEmptyString(formatted))
      .toList(growable: false);
}

class SqlFormattedNodeImpl extends SqlAbstractNodeImpl
    implements SqlFormattedNode {
  final SqlFormatRule rule;

  SqlFormattedNodeImpl(this.rule, {int maxChildrenLength})
      : super(BaseSqlNodeTypes.types.FORMATTED, maxChildrenLength);

  @override
  SqlFormattedNode clone() => super.clone();

  @override
  SqlAbstractNodeImpl createSqlNodeClone() =>
      new SqlFormattedNodeImpl(rule, maxChildrenLength: maxChildrenLength);
}
