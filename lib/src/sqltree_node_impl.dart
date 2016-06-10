// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "package:collection/collection.dart";

import "sqltree_node.dart";
import "sqltree_node_factory.dart";

class SqlNodeListImpl<T extends SqlNode> extends DelegatingList<T>
    implements SqlNodeList<T> {
  SqlNodeListImpl() : super([]);

  SqlNodeListImpl.from(Iterable elements, {bool growable: true})
      : super(new List.from(elements, growable: growable));

  @override
  SqlNode get singleOrNull {
    if (length <= 1) {
      return isNotEmpty ? first : null;
    } else {
      throw new StateError("Not single node");
    }
  }

  @override
  void set isEnabled(bool isEnabled) {
    for (var child in this) {
      child.isEnabled = isEnabled;
    }
  }

  @override
  void set isDisabled(bool isDisabled) {
    isEnabled = !isDisabled;
  }

  @override
  void enable() {
    isEnabled = true;
  }

  @override
  void disable() {
    isEnabled = false;
  }

  SqlNode getSingleNodeByReference(String reference) =>
      getNodeListByReference(reference).singleOrNull;

  SqlNodeList getNodeListByReference(String reference) =>
      new SqlNodeListImpl.from(
          expand((child) => child.getNodeListByReference(reference)),
          growable: false);

  @override
  SqlNodeList<T> clone() {
    SqlNodeListImpl clone = new SqlNodeListImpl();
    for (var node in this) {
      clone.add(node.clone());
    }
    return clone;
  }
}

class SqlNodeImpl extends SqlAbstractNodeImpl {
  SqlNodeImpl.raw(expression) : super.raw(expression?.toString());

  SqlNodeImpl(String type, int maxChildrenLength)
      : super(type, maxChildrenLength);

  @override
  SqlAbstractNodeImpl createSqlNodeClone() => isRawExpression
      ? new SqlNodeImpl.raw(rawExpression)
      : new SqlNodeImpl(type, maxChildrenLength);
}

class SqlGroupImpl extends SqlAbstractNodeImpl implements SqlGroup {
  @override
  final String reference;

  @override
  bool isEnabled;

  SqlGroupImpl(this.reference)
      : this.isEnabled = true,
        super(BaseSqlNodeTypes.types.GROUP, 1);

  @override
  SqlGroupImpl clone() => super.clone();

  @override
  SqlGroupImpl createSqlNodeClone() => new SqlGroupImpl(reference);

  @override
  SqlGroupImpl completeClone(SqlGroupImpl targetNode) {
    SqlGroupImpl node = super.completeClone(targetNode);
    node.isEnabled = targetNode.isEnabled;
    return node;
  }
}

class SqlFunctionImpl extends SqlAbstractNodeImpl implements SqlFunction {
  SqlFunctionImpl(String type, int maxChildrenLength)
      : super(type, maxChildrenLength);

  @override
  SqlFunctionImpl createSqlNodeClone() =>
      new SqlFunctionImpl(type, maxChildrenLength);

  @override
  SqlFunctionImpl clone() => super.clone();
}

class SqlOperatorImpl extends SqlAbstractNodeImpl implements SqlOperator {
  SqlOperatorImpl(String type, int maxChildrenLength)
      : super(type, maxChildrenLength) {
    if (maxChildrenLength != null && maxChildrenLength == 0) {
      throw new ArgumentError.value(0, "maxChildrenLength");
    }
  }

  @override
  bool get isUnary => maxChildrenLength != null && maxChildrenLength == 1;

  @override
  SqlOperatorImpl createSqlNodeClone() =>
      new SqlOperatorImpl(type, maxChildrenLength);

  @override
  SqlOperatorImpl clone() => super.clone();
}

abstract class SqlAbstractNodeImpl implements RegistrableSqlNode {
  final SqlNodeList _children = new SqlNodeListImpl();

  SqlNodeFactory _nodeFactory;

  final String _type;
  final String _rawExpression;
  final int maxChildrenLength;

  SqlAbstractNodeImpl.raw(this._rawExpression)
      : this._type = BaseSqlNodeTypes.types.RAW,
        this.maxChildrenLength = 0;

  SqlAbstractNodeImpl(this._type, this.maxChildrenLength)
      : this._rawExpression = null {
    if (type == null) {
      throw new ArgumentError.notNull("type");
    }
  }

  @override
  void registerNode(SqlNodeFactory nodeFactory) {
    if (_nodeFactory != null) {
      throw new StateError("Node already registered");
    }

    _nodeFactory = nodeFactory;

    onNodeRegistered();
  }

  @override
  String get type => _type;

  @override
  String get reference => null;

  @override
  bool get isEnabled => true;

  @override
  void set isEnabled(bool isEnabled) {
    throw new UnsupportedError(
        "Node enabling not supported: use a group node as a wrapper.");
  }

  @override
  bool get isDisabled => !isEnabled;

  @override
  void set isDisabled(bool isDisabled) {
    isEnabled = !isDisabled;
  }

  @override
  void enable() {
    isEnabled = true;
  }

  @override
  void disable() {
    isEnabled = false;
  }

  @override
  SqlNode getSingleNodeByReference(String reference) =>
      getNodeListByReference(reference).singleOrNull;

  @override
  SqlNodeList getNodeListByReference(String reference) {
    var list = new SqlNodeListImpl();

    if (this.reference == reference) {
      list.add(this);
    }

    list.addAll(_children.getNodeListByReference(reference));

    return list;
  }

  @override
  bool get isRawExpression => _type == BaseSqlNodeTypes.types.RAW;

  @override
  bool get isComposite => !isRawExpression;

  @override
  String get rawExpression {
    if (isRawExpression) {
      return _rawExpression;
    } else {
      throw new UnsupportedError("Node is not an expression");
    }
  }

  @override
  SqlNode get child {
    _checkNodeFactory();

    _checkComposite();

    _checkNodesCount(1);

    return _children.isEmpty ? null : _children.first;
  }

  @override
  void set child(singleChild) {
    _checkChildrenLocked();

    _checkNodeFactory();

    _checkComposite();

    _checkNodesCount(1);

    var wrapper = _nodeFactory.createWrapperNodeList(singleChild).singleOrNull;

    if (_children.isEmpty) {
      _children.add(wrapper);
    } else {
      _children[0] = wrapper;
    }
  }

  @override
  SqlNodeList get children {
    _checkNodeFactory();

    _checkComposite();

    if (isComposite) {
      // è una copia (non clone)

      // TODO node.children è una copia, sarebbe bello avere una vista non modificabile più leggera

      return new SqlNodeListImpl.from(_children, growable: false);
    } else {
      throw new UnsupportedError("Node is not a composite");
    }
  }

  @override
  SqlNode getChild(int index) {
    _checkNodeFactory();

    _checkComposite();

    _checkNodesCount(index + 1);

    return _children[index];
  }

  @override
  void setChildren(int index, node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    _checkChildrenLocked();

    _checkNodeFactory();

    _checkComposite();

    var wrappers = _nodeFactory.createWrapperNodeList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);

    _checkNodesCount(index + wrappers.length);

    _children.setAll(index, wrappers);
  }

  @override
  void addChildren(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    _checkChildrenLocked();

    addInternal(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);
  }

  @override
  void insertChildren(int index, node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    _checkChildrenLocked();

    _checkNodeFactory();

    _checkComposite();

    var wrappers = _nodeFactory.createWrapperNodeList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);

    _checkNodesCount(_children.length + wrappers.length);

    _children.insertAll(index, wrappers);
  }

  @override
  void clear() {
    _checkChildrenLocked();

    _checkNodeFactory();

    _checkComposite();

    _checkNodesCount(1);

    _children.clear();
  }

  @override
  String toString() {
    if (isRawExpression) {
      return _rawExpression != null ? "\"$_rawExpression\"" : "";
    } else {
      return "$type($_children)";
    }
  }

  @override
  SqlNode clone() => completeClone(createSqlNodeClone());

  SqlNodeFactory get nodeFactory => _nodeFactory;

  void addInternal(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    _checkNodeFactory();

    _checkComposite();

    var wrappers = _nodeFactory.createWrapperNodeList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9);

    _checkNodesCount(_children.length + wrappers.length);

    _children.addAll(wrappers);
  }

  void onNodeRegistered() {}

  SqlAbstractNodeImpl createSqlNodeClone() {
    throw new UnsupportedError("Clone unsupported on $runtimeType");
  }

  SqlAbstractNodeImpl completeClone(SqlAbstractNodeImpl targetNode) {
    targetNode._nodeFactory = _nodeFactory;
    for (var node in _children) {
      targetNode.addInternal(node.clone());
    }
    return targetNode;
  }

  void _checkChildrenLocked() {
    if (this is ChildrenLockedSqlNode) {
      throw new UnsupportedError("Children locked");
    }
  }

  void _checkNodeFactory() {
    if (_nodeFactory == null) {
      throw new StateError("Node not registered");
    }
  }

  void _checkComposite() {
    if (!isComposite) {
      throw new UnsupportedError("Node is not a composite");
    }
  }

  void _checkNodesCount(int count) {
    if (maxChildrenLength != null && count > maxChildrenLength) {
      throw new StateError(
          "Children count out of range $count > $maxChildrenLength");
    }
  }
}
