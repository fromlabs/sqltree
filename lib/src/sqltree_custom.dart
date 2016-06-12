// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_node_impl.dart";

class CustomSqlNodeList<T extends SqlNode> extends SqlNodeListImpl<T> {
  CustomSqlNodeList();

  CustomSqlNodeList.cloneFrom(CustomSqlNodeList target, bool freeze)
      : super.cloneFrom(target, freeze);

  @override
  CustomSqlNodeList createClone(bool freeze) =>
      new CustomSqlNodeList.cloneFrom(this, freeze);
}

class CustomSqlNode extends SqlAbstractNodeImpl {
  CustomSqlNode(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  CustomSqlNode.cloneFrom(CustomSqlNode targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlNode createClone(bool freeze) => new CustomSqlNode.cloneFrom(this, freeze);
}

class CustomSqlFunction extends SqlFunctionImpl {
  CustomSqlFunction(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  CustomSqlFunction.cloneFrom(CustomSqlFunction targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlNode createClone(bool freeze) =>
      new CustomSqlFunction.cloneFrom(this, freeze);
}

class CustomSqlOperator extends SqlOperatorImpl {
  CustomSqlOperator(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  CustomSqlOperator.cloneFrom(CustomSqlOperator targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlNode createClone(bool freeze) =>
      new CustomSqlOperator.cloneFrom(this, freeze);
}
