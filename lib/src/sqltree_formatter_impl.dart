// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_formatter.dart";
import "sqltree_node_manager.dart";
import "sqltree_node.dart";
import "sqltree_node_impl.dart";
import "sqltree_statement.dart";
import "sqltree_util.dart";

class SqlNodeFormatterImpl implements SqlNodeFormatter {
  static const String _EMPTY = "";

  final List<SqlNodeFormatterFunction> _formatters = [];

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

  void registerNodeFormatter(SqlNodeFormatterFunction formatter) {
    _formatters.add(formatter);
  }

  @override
  String format(SqlNode node) {
    if (node == null || node.isDisabled) {
      return _EMPTY;
    } else if (node.isCompositeNode) {
      String formatted;

      List<String> formattedChildren = _getFormattedChildren(node);

      formatted = _supportedFormat(node, formattedChildren);
      if (formatted != null) {
        return formatted;
      }

      for (SqlNodeFormatterFunction formatter in _formatters) {
        formatted = formatter(node, formattedChildren);
        if (formatted != null) {
          return formatted;
        }
      }

      return _defaultFormat(node, formattedChildren);
    } else {
      return node.rawExpression;
    }
  }

  List<String> _getFormattedChildren(SqlNode node) => node.children
      .map((childNode) => this.format(childNode))
      .where((formatted) => isNotEmptyString(formatted))
      .toList(growable: false);

  String _supportedFormat(SqlNode node, List<String> formattedChildren) {
    if (node is SqlStatement) {
      return formatByRule(formattedChildren, separator: " ");
    } else if (node is SqlSelectClause) {
      return formatByRule(formattedChildren,
          prefix: "${node.type} ${node.isDistinct ? "DISTINCT " : ""}",
          separator: ", ");
    } else if (node is SqlFormattedNode) {
      return node.formatter(node, formattedChildren);
    } else if (node is SqlFunction) {
      return formatByRule(formattedChildren,
          prefix: "${node.type}(",
          separator: ", ",
          postfix: ")",
          isFormatEmptyChildrenEnabled: true);
    } else if (node is SqlOperator) {
      if (node.isUnary) {
        return formatByRule(formattedChildren,
            prefix: "${node.type} ", separator: ", ");
      } else {
        return formatByRule(formattedChildren, separator: " ${node.type} ");
      }
    } else if (node is SqlJoins) {
      return formatByRule(formattedChildren, separator: " ");
    } else if (node is SqlJoin) {
      return formatByRule(formattedChildren,
          prefix: "${node.type} ", separator: " ");
    } else if (_clauseNodes.contains(node.type)) {
      return formatByRule(formattedChildren,
          prefix: "${node.type} ", separator: ", ");
    } else if (BaseSqlNodeTypes.types.DELETE_CLAUSE == node.type) {
      return formatByRule(formattedChildren,
          prefix: "${node.type} ",
          separator: ", ",
          isFormatEmptyChildrenEnabled: true);
    } else if (_whereNodes.contains(node.type)) {
      return formatByRule(formattedChildren,
          prefix: "${node.type} ", separator: " AND ");
    } else if (BaseSqlNodeTypes.types.COLUMNS_CLAUSE == node.type) {
      return formatByRule(formattedChildren,
          prefix: "(", separator: ", ", postfix: ")");
    } else if (_emptyNodes.contains(node.type)) {
      return formatByRule(formattedChildren);
    } else if (BaseSqlNodeTypes.types.JOIN_ON == node.type) {
      return formatByRule(formattedChildren, prefix: "ON ", separator: " AND ");
    }

    return null;
  }

  String _defaultFormat(SqlNode node, List<String> formattedChildren) {
    print(
        "WARNING: undefined rule for node of type ${node.type} [${node.runtimeType}]");

    return formatByRule(formattedChildren,
        prefix: "${node.type}(",
        separator: ", ",
        postfix: ")",
        isFormatEmptyChildrenEnabled: true);
  }
}

class SqlFormattedNodeImpl extends SqlAbstractNodeImpl
    implements SqlFormattedNode {
  final SqlNodeFormatterFunction formatter;

  SqlFormattedNodeImpl(this.formatter, {int maxChildrenLength})
      : super(BaseSqlNodeTypes.types.FORMATTED,
            maxChildrenLength: maxChildrenLength);

  SqlFormattedNodeImpl.cloneFrom(SqlFormattedNodeImpl targetNode, bool freeze)
      : this.formatter = targetNode.formatter,
        super.cloneFrom(targetNode, freeze);

  @override
  SqlNode createClone(bool freeze) =>
      new SqlFormattedNodeImpl.cloneFrom(this, freeze);
}
