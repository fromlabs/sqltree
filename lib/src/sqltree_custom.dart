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
  CustomSqlNode(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength);

  @override
  CustomSqlNode createSqlNodeClone() =>
      new CustomSqlNode(type, maxChildrenLength: maxChildrenLength);

  @override
  CustomSqlNode clone() => super.clone();
}

class CustomSqlFunction extends SqlFunctionImpl {
  CustomSqlFunction(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength);

  @override
  CustomSqlFunction createSqlNodeClone() =>
      new CustomSqlFunction(type, maxChildrenLength: maxChildrenLength);

  @override
  CustomSqlFunction clone() => super.clone();
}

class CustomSqlOperator extends SqlOperatorImpl {
  CustomSqlOperator(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength);

  @override
  CustomSqlOperator createSqlNodeClone() =>
      new CustomSqlOperator(type, maxChildrenLength: maxChildrenLength);

  @override
  CustomSqlOperator clone() => super.clone();
}
