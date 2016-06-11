// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_node_impl.dart";

class CustomSqlNodeList<T extends SqlNode> extends SqlNodeListImpl<T> {
  CustomSqlNodeList();

  CustomSqlNodeList.from(Iterable<T> elements, {bool growable: true})
      : super.from(elements, growable: growable);
}

class CustomSqlNode extends SqlNodeImpl {
  CustomSqlNode(String type, int maxChildrenLength, bool isFreezed)
      : super(type, maxChildrenLength, isFreezed);

  @override
  SqlNode createSqlNodeClone(bool isFreezed) =>
      new CustomSqlNode(type, maxChildrenLength, isFreezed);
}

class CustomSqlFunction extends SqlFunctionImpl {
  CustomSqlFunction(String type, int maxChildrenLength, bool isFreezed)
      : super(type, maxChildrenLength, isFreezed);

  @override
  SqlNode createSqlNodeClone(bool isFreezed) =>
      new CustomSqlFunction(type, maxChildrenLength, isFreezed);
}

class CustomSqlOperator extends SqlOperatorImpl {
  CustomSqlOperator(String type, int maxChildrenLength, bool isFreezed)
      : super(type, maxChildrenLength, isFreezed);

  @override
  SqlNode createSqlNodeClone(bool isFreezed) =>
      new CustomSqlOperator(type, maxChildrenLength, isFreezed);
}
