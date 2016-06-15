// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_node_impl.dart";

class CustomSqlNodeList<T extends SqlNode> extends CustomSqlNodeListBase<T> {
  CustomSqlNodeList();

  CustomSqlNodeList.from(Iterable<T> nodes) : super.from(nodes);

  CustomSqlNodeList.cloneFrom(CustomSqlNodeList<T> target, bool freeze)
      : super.cloneFrom(target, freeze);

  @override
  CustomSqlNodeList<T> createClone(bool freeze) =>
      new CustomSqlNodeList.cloneFrom(this, freeze);
}

class CustomSqlNode extends CustomSqlNodeBase {
  CustomSqlNode(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  CustomSqlNode.cloneFrom(CustomSqlNode targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  CustomSqlNode createClone(bool freeze) =>
      new CustomSqlNode.cloneFrom(this, freeze);
}

class CustomSqlFunction extends CustomSqlFunctionBase {
  CustomSqlFunction(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  CustomSqlFunction.cloneFrom(CustomSqlFunction targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  CustomSqlFunction createClone(bool freeze) =>
      new CustomSqlFunction.cloneFrom(this, freeze);
}

class CustomSqlOperator extends CustomSqlOperatorBase {
  CustomSqlOperator(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  CustomSqlOperator.cloneFrom(CustomSqlOperator targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  CustomSqlOperator createClone(bool freeze) =>
      new CustomSqlOperator.cloneFrom(this, freeze);
}

abstract class CustomSqlNodeListBase<T extends SqlNode>
    extends SqlAbstractNodeListImpl<T> {
  CustomSqlNodeListBase();

  CustomSqlNodeListBase.from(Iterable<T> nodes) : super.from(nodes);

  CustomSqlNodeListBase.cloneFrom(CustomSqlNodeListBase target, bool freeze)
      : super.cloneFrom(target, freeze);
}

abstract class CustomSqlNodeBase extends SqlAbstractNodeImpl {
  CustomSqlNodeBase(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  CustomSqlNodeBase.cloneFrom(CustomSqlNodeBase targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);
}

abstract class CustomSqlFunctionBase extends SqlAbstractFunctionImpl {
  CustomSqlFunctionBase(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  CustomSqlFunctionBase.cloneFrom(CustomSqlFunctionBase targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);
}

abstract class CustomSqlOperatorBase extends SqlAbstractOperatorImpl {
  CustomSqlOperatorBase(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  CustomSqlOperatorBase.cloneFrom(CustomSqlOperatorBase targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);
}
