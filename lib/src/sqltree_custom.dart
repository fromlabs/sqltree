// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_node_impl.dart";

class CustomSqlNodeList<T extends SqlNode> extends SqlNodeListImpl<T> {
  CustomSqlNodeList() : super(false);

  // TODO rivedere il clone del custom list
}

class CustomSqlNode extends SqlNodeImpl {
  CustomSqlNode(String type, int maxChildrenLength, bool isFreezed)
      : super(type, maxChildrenLength, isFreezed);

  CustomSqlNode.cloneFrom(CustomSqlNode targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlNode createClone(bool freeze) => new SqlNodeImpl.cloneFrom(this, freeze);
}

class CustomSqlFunction extends SqlFunctionImpl {
  CustomSqlFunction(String type, int maxChildrenLength, bool isFreezed)
      : super(type, maxChildrenLength, isFreezed);

  CustomSqlFunction.cloneFrom(CustomSqlFunction targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlNode createClone(bool freeze) =>
      new CustomSqlFunction.cloneFrom(this, freeze);
}

class CustomSqlOperator extends SqlOperatorImpl {
  CustomSqlOperator(String type, int maxChildrenLength, bool isFreezed)
      : super(type, maxChildrenLength, isFreezed);

  CustomSqlOperator.cloneFrom(CustomSqlOperator targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlNode createClone(bool freeze) =>
      new CustomSqlOperator.cloneFrom(this, freeze);
}
