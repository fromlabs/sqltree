// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_node_impl.dart";

abstract class ExtensionSqlNodeIterableBase<E extends SqlNode>
    extends DelegatingSqlNodeIterableBase<E> {
  const ExtensionSqlNodeIterableBase(Iterable<E> base) : super(base);
}

abstract class ExtensionSqlNodeListBase<E extends SqlNode>
    extends DelegatingSqlNodeListBase<E> {
  const ExtensionSqlNodeListBase(List<E> base) : super(base);

  ExtensionSqlNodeListBase.cloneFrom(
      ExtensionSqlNodeListBase target, bool freeze)
      : super.cloneFrom(target, freeze);
}

class ExtensionSqlNodeList<E extends SqlNode>
    extends DelegatingSqlNodeListBase<E>
    with DelegatingSqlNodeIterableMixin<E> {
  ExtensionSqlNodeList() : super([]);

  ExtensionSqlNodeList.from(Iterable<E> nodes, {bool growable: true})
      : super(nodes.toList(growable: growable));

  ExtensionSqlNodeList.cloneFrom(ExtensionSqlNodeList target, bool freeze)
      : super.cloneFrom(target, freeze);

  @override
  ExtensionSqlNodeList createClone(bool freeze) =>
      new ExtensionSqlNodeList.cloneFrom(this, freeze);
}

class ExtensionSqlNode extends ExtensionSqlNodeBase {
  ExtensionSqlNode(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  ExtensionSqlNode.cloneFrom(ExtensionSqlNode targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  ExtensionSqlNode createClone(bool freeze) =>
      new ExtensionSqlNode.cloneFrom(this, freeze);
}

class ExtensionSqlFunction extends ExtensionSqlFunctionBase {
  ExtensionSqlFunction(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  ExtensionSqlFunction.cloneFrom(ExtensionSqlFunction targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  ExtensionSqlFunction createClone(bool freeze) =>
      new ExtensionSqlFunction.cloneFrom(this, freeze);
}

class ExtensionSqlOperator extends ExtensionSqlOperatorBase {
  ExtensionSqlOperator(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  ExtensionSqlOperator.cloneFrom(ExtensionSqlOperator targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  ExtensionSqlOperator createClone(bool freeze) =>
      new ExtensionSqlOperator.cloneFrom(this, freeze);
}

abstract class ExtensionSqlNodeBase extends SqlAbstractNodeImpl {
  ExtensionSqlNodeBase(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  ExtensionSqlNodeBase.cloneFrom(ExtensionSqlNodeBase targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);
}

abstract class ExtensionSqlFunctionBase extends SqlAbstractFunctionImpl {
  ExtensionSqlFunctionBase(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  ExtensionSqlFunctionBase.cloneFrom(
      ExtensionSqlFunctionBase targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);
}

abstract class ExtensionSqlOperatorBase extends SqlAbstractOperatorImpl {
  ExtensionSqlOperatorBase(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  ExtensionSqlOperatorBase.cloneFrom(
      ExtensionSqlOperatorBase targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);
}
