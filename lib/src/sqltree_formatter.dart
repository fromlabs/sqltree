// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";

typedef String SqlNodeFormatterFunction(SqlNode node);

typedef SqlFormatRule SqlFormatRuleProvider(SqlNode node);

abstract class SqlNodeFormatter {
  String format(SqlNode node);
}

class SqlNodeFormatterFunctionWrapper implements SqlNodeFormatter {
  final SqlNodeFormatterFunction formatter;

  SqlNodeFormatterFunctionWrapper(this.formatter);

  @override
  String format(SqlNode node) => formatter(node);
}

class SqlFormatRule {
  final String prefix;

  final bool isFormatEmptyChildrenEnabled;

  final String separator;

  final String postfix;

  SqlFormatRule(
      {this.prefix,
      this.separator,
      this.postfix,
      this.isFormatEmptyChildrenEnabled: false});
}

abstract class SqlFormattedNode implements SqlNode {
  SqlFormatRule get rule;
}
