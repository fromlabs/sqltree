// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";

typedef String SqlNodeFormatterFunction(
    SqlNode node, Iterable<String> formattedChildren);

abstract class SqlNodeFormatter {
  String format(SqlNode node);
}

abstract class SqlFormattedNode implements SqlNode {
  SqlNodeFormatterFunction get formatter;
}
