// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "package:collection/collection.dart";

import "sqltree_node.dart";
import "sqltree_node_manager.dart";
import "sqltree_util.dart";

class SqlNodeChildrenListImpl<E extends SqlAbstractNodeImpl>
    extends SqlNodeListImpl<E> {
  SqlNode _parent;

  final List<E> _backedList;

  @override
  final int maxLength;

  SqlNodeChildrenListImpl(List<E> backedList, this.maxLength)
      : this._backedList = backedList,
        super._backedList(backedList);

  @override
  void set length(int newLength) {
    _checkChildrenLocked();

    _checkNodesCount(newLength);

    _backedList.length = newLength;
  }

  @override
  void add(E value) {
    _checkChildrenLocked();

    _checkNodesCount(length + 1);

    return _backedList.add(value);
  }

  @override
  void addAll(Iterable<E> iterable) {
    _checkChildrenLocked();

    _checkNodesCount(length + iterable.length);

    return _backedList.addAll(iterable);
  }

  @override
  void insert(int index, E element) {
    _checkChildrenLocked();

    _checkNodesCount(length + 1);

    return _backedList.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    _checkChildrenLocked();

    _checkNodesCount(length + iterable.length);

    return _backedList.insertAll(index, iterable);
  }

  @override
  bool remove(Object value) {
    _checkChildrenLocked();

    return _backedList.remove(value);
  }

  @override
  E removeAt(int index) {
    _checkChildrenLocked();

    return _backedList.removeAt(index);
  }

  @override
  E removeLast() {
    _checkChildrenLocked();

    return _backedList.removeLast();
  }

  @override
  void removeWhere(bool test(E element)) {
    _checkChildrenLocked();

    return _backedList.removeWhere(test);
  }

  @override
  void retainWhere(bool test(E element)) {
    _checkChildrenLocked();

    return _backedList.retainWhere(test);
  }

  @override
  void removeRange(int start, int end) {
    _checkChildrenLocked();

    return _backedList.removeRange(start, end);
  }

  @override
  void replaceRange(int start, int end, Iterable<E> iterable) {
    _checkChildrenLocked();

    return _backedList.replaceRange(start, end, iterable);
  }

  @override
  void clear() {
    _checkChildrenLocked();

    return _backedList.clear();
  }

  void _addInternal(SqlNode node) {
    _checkNodesCount(length + 1);

    _backedList.add(node);
  }

  void _checkNodesCount(int count) {
    if (maxLength != null && count > maxLength) {
      throw new StateError("Children count out of range $count > $maxLength");
    }
  }

  void _checkChildrenLocked() {
    if (_parent is ChildrenLockedSqlNode) {
      throw new UnsupportedError("Children locked");
    }
  }
}

// TODO verificare altri costruttori e metodi di trasformazione delle liste
class SqlNodeListImpl<T extends SqlNode> extends DelegatingList<T>
    implements SqlNodeList<T> {
  SqlNodeListImpl() : super([]);

  SqlNodeListImpl.from(Iterable elements, {bool growable: true})
      : super(new List.from(elements, growable: growable));

  SqlNodeListImpl._backedList(List<T> backedList) : super(backedList);

  @override
  int get maxLength => null;

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

  SqlNodeList wrap(NodeWrapper wrapper) =>
      new SqlNodeListImpl.from(map(wrapper), growable: false);

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
  // TODO verificare named parameters
  SqlNodeImpl(String type, int maxChildrenLength)
      : super(type, maxChildrenLength);

  SqlNodeImpl.raw(expression) : super.raw(expression?.toString());

  @override
  SqlAbstractNodeImpl createSqlNodeClone() => isRawExpression
      ? new SqlNodeImpl.raw(rawExpression)
      : new SqlNodeImpl(type, children.maxLength);
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
      new SqlFunctionImpl(type, children.maxLength);

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
  bool get isUnary => children.maxLength != null && children.maxLength == 1;

  @override
  SqlOperatorImpl createSqlNodeClone() =>
      new SqlOperatorImpl(type, children.maxLength);

  @override
  SqlOperatorImpl clone() => super.clone();
}

abstract class SqlAbstractNodeImpl implements RegistrableSqlNode {
  final SqlNodeList _children;

  SqlNodeManager _nodeManager;

  final String _type;
  final String _rawExpression;

  SqlAbstractNodeImpl.raw(this._rawExpression)
      : this._type = BaseSqlNodeTypes.types.RAW,
        this._children = new SqlNodeChildrenListImpl([], 0) {
    (_children as SqlNodeChildrenListImpl)._parent = this;
  }

  SqlAbstractNodeImpl(this._type, int maxChildrenLength)
      : this._rawExpression = null,
        this._children = new SqlNodeChildrenListImpl([], maxChildrenLength) {
    (_children as SqlNodeChildrenListImpl)._parent = this;

    if (type == null) {
      throw new ArgumentError.notNull("type");
    }
  }

  @override
  void registerNode(SqlNodeManager nodeManager) {
    if (_nodeManager != null) {
      throw new StateError("Node already registered");
    }

    _nodeManager = nodeManager;

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

    if (isComposite) {
      list.addAll(children.getNodeListByReference(reference));
    }

    return list;
  }

  @override
  bool get isRawExpression => _type == BaseSqlNodeTypes.types.RAW;

  @override
  bool get isComposite => !isRawExpression;

  bool get isEmptyComposite =>
      isComposite && _children.maxLength != null && _children.maxLength == 0;

  bool get isSingleComposite =>
      isComposite && _children.maxLength != null && _children.maxLength == 1;

  bool get isMultiComposite =>
      isComposite && (_children.maxLength == null || _children.maxLength > 1);

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
    _checkRegistered();

    _checkSingleComposite();

    return _children.singleOrNull;
  }

  @override
  void set child(singleChild) {
    _checkRegistered();

    _checkSingleComposite();

    var normalized = _nodeManager.normalize(singleChild).singleOrNull;

    if (_children.isEmpty) {
      _children.add(normalized);
    } else {
      _children[0] = normalized;
    }
  }

  @override
  SqlNodeList get children {
    _checkRegistered();

    _checkComposite();

    return _children;
  }

  @override
  void addChildren(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    var normalized = _nodeManager.normalize(getVargsList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

    children.addAll(normalized);
  }

  @override
  void insertChildren(int index, node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    var normalized = _nodeManager.normalize(getVargsList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

    children.insertAll(index, normalized);
  }

  @override
  void setChildren(int index, node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    var normalized = _nodeManager.normalize(getVargsList(
        node0, node1, node2, node3, node4, node5, node6, node7, node8, node9));

    children.setAll(index, normalized);
  }

  @override
  String toString() {
    if (isRawExpression) {
      return _rawExpression != null ? "\"$_rawExpression\"" : "";
    } else {
      return "$type($children)";
    }
  }

  SqlNodeManager get nodeManager => _nodeManager;

  void onNodeRegistered() {}

  // TODO rivedere le fasi del clone
  @override
  SqlNode clone() => completeClone(createSqlNodeClone());

  SqlAbstractNodeImpl createSqlNodeClone() {
    throw new UnsupportedError("Clone unsupported on $runtimeType");
  }

  SqlAbstractNodeImpl completeClone(SqlAbstractNodeImpl targetNode) {
    targetNode._nodeManager = _nodeManager;
    // TODO rivedere perchè deve essere più leggera
    for (var node in children) {
      (targetNode.children as SqlNodeChildrenListImpl)
          ._addInternal(node.clone());
    }
    return targetNode;
  }

  registerAndAddInternal(SqlNode node) {
    return (_children as SqlNodeChildrenListImpl)
        ._addInternal(nodeManager.registerNode(node));
  }

  void _checkRegistered() {
    if (_nodeManager == null) {
      throw new StateError("Node not registered");
    }
  }

  void _checkSingleComposite() {
    if (!isSingleComposite) {
      throw new UnsupportedError("Node is not a single composite");
    }
  }

  void _checkComposite() {
    if (!isComposite) {
      throw new UnsupportedError("Node is not a composite");
    }
  }
}
