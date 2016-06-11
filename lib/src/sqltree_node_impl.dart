// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "package:collection/collection.dart";

import "sqltree_node.dart";
import "sqltree_node_manager.dart";
import "sqltree_util.dart";

class SqlNodeChildrenListImpl<E extends SqlAbstractNodeImpl>
    extends SqlNodeListImpl<E> {
  SqlAbstractNodeImpl _parent;

  final List<E> _backedList;

  @override
  final int maxLength;

  SqlNodeChildrenListImpl(List<E> backedList, this.maxLength)
      : this._backedList = backedList,
        super._backedList(backedList);

  @override
  void set length(int newLength) {
    _checkUpdatable();

    _checkNodesCount(newLength);

    _backedList.length = newLength;
  }

  @override
  void add(E value) {
    _checkUpdatable();

    _checkNodesCount(length + 1);

    return _backedList.add(value);
  }

  @override
  void addAll(Iterable<E> iterable) {
    _checkUpdatable();

    _checkNodesCount(length + iterable.length);

    return _backedList.addAll(iterable);
  }

  @override
  void insert(int index, E element) {
    _checkUpdatable();

    _checkNodesCount(length + 1);

    return _backedList.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    _checkUpdatable();

    _checkNodesCount(length + iterable.length);

    return _backedList.insertAll(index, iterable);
  }

  @override
  bool remove(Object value) {
    _checkUpdatable();

    return _backedList.remove(value);
  }

  @override
  E removeAt(int index) {
    _checkUpdatable();

    return _backedList.removeAt(index);
  }

  @override
  E removeLast() {
    _checkUpdatable();

    return _backedList.removeLast();
  }

  @override
  void removeWhere(bool test(E element)) {
    _checkUpdatable();

    return _backedList.removeWhere(test);
  }

  @override
  void retainWhere(bool test(E element)) {
    _checkUpdatable();

    return _backedList.retainWhere(test);
  }

  @override
  void removeRange(int start, int end) {
    _checkUpdatable();

    return _backedList.removeRange(start, end);
  }

  @override
  void replaceRange(int start, int end, Iterable<E> iterable) {
    _checkUpdatable();

    return _backedList.replaceRange(start, end, iterable);
  }

  @override
  void clear() {
    _checkUpdatable();

    return _backedList.clear();
  }

  void _addInternal(SqlNode node) {
    _parent.checkNotFreezed();

    _checkNodesCount(length + 1);

    _backedList.add(node);
  }

  void _checkUpdatable() {
    _parent.checkNotFreezed();

    _checkChildrenLocked();
  }

  void _checkChildrenLocked() {
    if (_parent is ChildrenLockedSqlNode) {
      throw new UnsupportedError("Children locked");
    }
  }

  void _checkNodesCount(int count) {
    if (maxLength != null && count > maxLength) {
      throw new StateError("Children count out of range $count > $maxLength");
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
  SqlNode get singleOrNull => isNotEmpty ? single : null;

  @override
  void setReference(String reference) {
    for (var child in this) {
      child.reference = reference;
    }
  }

  @override
  void setEnabled(bool isEnabled) {
    for (var child in this) {
      child.isEnabled = isEnabled;
    }
  }

  @override
  void setDisabled(bool isDisabled) {
    setEnabled(!isDisabled);
  }

  @override
  void enable() {
    setEnabled(true);
  }

  @override
  void disable() {
    setEnabled(false);
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
  SqlNodeList<T> clone({freeze: false}) {
    SqlNodeList clone = new SqlNodeListImpl();
    for (var node in this) {
      clone.add(node.clone(freeze: freeze));
    }
    return clone;
  }
}

class SqlNodeImpl extends SqlAbstractNodeImpl {
  SqlNodeImpl(String type, int maxChildrenLength, bool isFreezed)
      : super(type, maxChildrenLength, isFreezed);

  SqlNodeImpl.raw(expression, bool isFreezed)
      : super.raw(expression?.toString(), isFreezed);

  @override
  SqlNode createSqlNodeClone(bool isFreezed) => isRawExpression
      ? new SqlNodeImpl.raw(rawExpression, isFreezed)
      : new SqlNodeImpl(type, children.maxLength, isFreezed);
}

class SqlFunctionImpl extends SqlAbstractNodeImpl implements SqlFunction {
  SqlFunctionImpl(String type, int maxChildrenLength, bool isFreezed)
      : super(type, maxChildrenLength, isFreezed);

  @override
  SqlNode createSqlNodeClone(bool isFreezed) =>
      new SqlFunctionImpl(type, children.maxLength, isFreezed);
}

class SqlOperatorImpl extends SqlAbstractNodeImpl implements SqlOperator {
  SqlOperatorImpl(String type, int maxChildrenLength, bool isFreezed)
      : super(type, maxChildrenLength, isFreezed) {
    if (maxChildrenLength != null && maxChildrenLength == 0) {
      throw new ArgumentError.value(0, "maxChildrenLength");
    }
  }

  @override
  bool get isUnary => children.maxLength != null && children.maxLength == 1;

  @override
  SqlNode createSqlNodeClone(bool isFreezed) =>
      new SqlOperatorImpl(type, children.maxLength, isFreezed);
}

abstract class SqlAbstractNodeImpl implements RegistrableSqlNode {
  final bool isFreezed;

  String _reference;

  bool _isEnabled;

  final SqlNodeList _children;

  SqlNodeManager _nodeManager;

  final String _type;
  final String _rawExpression;

  SqlAbstractNodeImpl.raw(this._rawExpression, this.isFreezed)
      : this._type = BaseSqlNodeTypes.types.RAW,
        this._isEnabled = true,
        this._children = new SqlNodeChildrenListImpl([], 0) {
    (_children as SqlNodeChildrenListImpl)._parent = this;
  }

  SqlAbstractNodeImpl(this._type, int maxChildrenLength, this.isFreezed)
      : this._rawExpression = null,
        this._isEnabled = true,
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
  String get reference => _reference;

  void set reference(String reference) {
    checkNotFreezed();

    _reference = reference;
  }

  @override
  bool get isEnabled => _isEnabled;

  @override
  void set isEnabled(bool isEnabled) {
    checkNotFreezed();

    _isEnabled = isEnabled;
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

  @override
  SqlNode clone({freeze: false}) =>
      completeClone(createSqlNodeClone(freeze || isFreezed));

  SqlNode createSqlNodeClone(bool isFreezed) {
    throw new UnsupportedError("Clone unsupported on $runtimeType");
  }

  SqlNode completeClone(SqlAbstractNodeImpl targetNode) {
    SqlNodeChildrenListImpl children = _children;
    SqlNodeChildrenListImpl targetChildren = targetNode._children;
    targetNode._nodeManager = _nodeManager;
    targetNode._reference = _reference;
    targetNode._isEnabled = _isEnabled;
    for (var node in children._backedList) {
      targetChildren._backedList.add(node.clone(freeze: targetNode.isFreezed));
    }
    return targetNode;
  }

  registerAndAddInternal(SqlNode node) {
    SqlNodeChildrenListImpl children = _children;
    return children._addInternal(nodeManager.registerNode(node));
  }

  void checkNotFreezed() {
    if (isFreezed) {
      throw new StateError("Node is freezed");
    }
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
