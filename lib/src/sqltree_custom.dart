// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_node_impl.dart";

abstract class CustomSqlNodeIterableBase<E extends SqlNode>
    extends DelegatingSqlNodeIterableBase<E> {
  const CustomSqlNodeIterableBase(Iterable<E> base) : super(base);
}

abstract class CustomSqlNodeListBase<E extends SqlNode>
    extends DelegatingSqlNodeListBase<E> {
  const CustomSqlNodeListBase(List<E> base) : super(base);

  CustomSqlNodeListBase.cloneFrom(CustomSqlNodeListBase target, bool freeze)
      : super.cloneFrom(target, freeze);
}

class CustomSqlNodeList<E extends SqlNode>
    extends DelegatingSqlNodeListBase<E> {
  CustomSqlNodeList() : super([]);

  CustomSqlNodeList.from(Iterable<E> nodes, {bool growable: true})
      : super(nodes.toList(growable: growable));

  CustomSqlNodeList.cloneFrom(CustomSqlNodeList target, bool freeze)
      : super.cloneFrom(target, freeze);

  @override
  bool isAlreadyWrappedIterable(Iterable<E> base) =>
      base is DelegatingSqlNodeIterable;

  @override
  bool isAlreadyWrappedList(Iterable<E> base) => base is DelegatingSqlNodeList;

  @override
  SqlNodeIterable<E> createIterable(Iterable<E> base) =>
      new DelegatingSqlNodeIterable(base);

  @override
  SqlNodeList<E> createList(List<E> base) => new DelegatingSqlNodeList(base);

  @override
  CustomSqlNodeList createClone(bool freeze) =>
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
