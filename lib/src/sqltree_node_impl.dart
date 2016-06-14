// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "package:collection/collection.dart";

import "sqltree_node.dart";
import "sqltree_node_manager.dart";
import "sqltree_node_manager_impl.dart";
import "sqltree_util.dart";

class SqlNodeListImpl<T extends SqlNode> extends SqlAbstractNodeListImpl<T> {
  SqlNodeListImpl();

  SqlNodeListImpl.cloneFrom(SqlNodeListImpl target, bool freeze)
      : super.cloneFrom(target, freeze);

  SqlNodeList<T> createClone(bool freeze) =>
      new SqlNodeListImpl.cloneFrom(this, freeze);
}

abstract class SqlAbstractNodeListImpl<T extends SqlNode>
    extends UpdatableList<T> implements SqlNodeList<T> {
  final bool isFreezed;

  SqlAbstractNodeListImpl()
      : this.isFreezed = false,
        super([]);

  SqlAbstractNodeListImpl.cloneFrom(SqlAbstractNodeListImpl target, bool freeze)
      : this.isFreezed = freeze,
        super(target._backedList
            .map((node) => node.clone(freeze: freeze))
            .toList());

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

  @override
  bool containsReference(String reference) =>
      getNodeListByReference(reference).isNotEmpty;

  SqlNode getSingleNodeByReference(String reference) =>
      getNodeListByReference(reference).singleOrNull;

  SqlNodeList getNodeListByReference(String reference) => new SqlNodeListImpl()
    ..addAll(expand((child) => child.getNodeListByReference(reference)));

  SqlNodeList wrap(NodeWrapper wrapper) =>
      new SqlNodeListImpl()..addAll(map(wrapper));

  @override
  SqlNodeList<T> clone({bool freeze}) => (freeze != null && !freeze) ||
      !isFreezed ? createClone(freeze ?? isFreezed) : this;

  @override
  void _checkUpdatable() {
    _checkNotFreezed();
  }

  SqlNodeList<T> createClone(bool freeze);

  void _checkNotFreezed() {
    if (isFreezed) {
      throw new StateError("Node is freezed");
    }
  }
}

class SqlNodeImpl extends SqlAbstractNodeImpl {
  SqlNodeImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  SqlNodeImpl.raw(expression) : super.raw(expression?.toString());

  SqlNodeImpl.cloneFrom(SqlNodeImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlNode createClone(bool freeze) => new SqlNodeImpl.cloneFrom(this, freeze);
}

class SqlFunctionImpl extends SqlAbstractFunctionImpl {
  SqlFunctionImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  SqlFunctionImpl.cloneFrom(SqlFunctionImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlNode createClone(bool freeze) =>
      new SqlFunctionImpl.cloneFrom(this, freeze);
}

class SqlOperatorImpl extends SqlAbstractOperatorImpl implements SqlOperator {
  SqlOperatorImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  SqlOperatorImpl.cloneFrom(SqlOperatorImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlNode createClone(bool freeze) =>
      new SqlOperatorImpl.cloneFrom(this, freeze);
}

abstract class SqlAbstractFunctionImpl extends SqlAbstractNodeImpl
    implements SqlFunction {
  SqlAbstractFunctionImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  SqlAbstractFunctionImpl.cloneFrom(
      SqlAbstractFunctionImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);
}

abstract class SqlAbstractOperatorImpl extends SqlAbstractNodeImpl
    implements SqlOperator {
  SqlAbstractOperatorImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength) {
    if (maxChildrenLength != null && maxChildrenLength == 0) {
      throw new ArgumentError.value(0, "maxChildrenLength");
    }
  }

  SqlAbstractOperatorImpl.cloneFrom(
      SqlAbstractOperatorImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  bool get isUnary => maxChildrenLength != null && maxChildrenLength == 1;
}

abstract class SqlAbstractNodeImpl implements SqlNode, RegistrableSqlNode {
  final bool isFreezed;

  final String _type;

  final String _rawExpression;

  final _SqlNodeChildrenListImpl _children;

  SqlNodeManager _nodeManager;

  String _reference;

  bool _isEnabled;

  SqlAbstractNodeImpl(this._type, {int maxChildrenLength})
      : this._rawExpression = null,
        this.isFreezed = false,
        this._isEnabled = true,
        this._children =
            new _SqlNodeChildrenListImpl(maxLength: maxChildrenLength) {
    _children.registerParent(this);

    if (type == null) {
      throw new ArgumentError.notNull("type");
    }
  }

  SqlAbstractNodeImpl.raw(this._rawExpression)
      : this._type = BaseSqlNodeTypes.types.RAW,
        this.isFreezed = false,
        this._isEnabled = true,
        this._children = null;

  SqlAbstractNodeImpl.cloneFrom(SqlAbstractNodeImpl targetNode, bool freeze)
      : this.isFreezed = freeze,
        this._type = targetNode._type,
        this._rawExpression = targetNode._rawExpression,
        this._nodeManager = targetNode._nodeManager,
        this._reference = targetNode._reference,
        this._isEnabled = targetNode._isEnabled,
        this._children = targetNode._children?.clone(freeze: freeze);

  @override
  void registerNode(SqlNodeManager nodeManager) {
    if (_nodeManager != null) {
      throw new StateError("Node already registered");
    }

    _nodeManager = nodeManager;

    onNodeRegistered();
  }

  @override
  bool get isRegistered => _nodeManager != null;

  @override
  String get type => _type;

  int get maxChildrenLength => _children.maxLength;

  @override
  String get reference => _reference;

  void set reference(String reference) {
    _checkRegistered();

    checkNotFreezed();

    _reference = reference;
  }

  @override
  bool get isEnabled => _isEnabled;

  @override
  void set isEnabled(bool isEnabled) {
    _checkRegistered();

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
  bool containsReference(String reference) =>
      getNodeListByReference(reference).isNotEmpty;

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
      isComposite && maxChildrenLength != null && maxChildrenLength == 0;

  bool get isSingleComposite =>
      isComposite && maxChildrenLength != null && maxChildrenLength == 1;

  bool get isMultiComposite =>
      isComposite && (maxChildrenLength == null || maxChildrenLength > 1);

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
      return "$type($_children)";
    }
  }

  SqlNodeManager get nodeManager => _nodeManager;

  void onNodeRegistered() {}

  @override
  SqlNode clone({bool freeze}) => (freeze != null && !freeze) || !isFreezed
      ? createClone(freeze ?? isFreezed)
      : this;

  SqlNode createClone(bool freeze);

  SqlNode addInternalNode(SqlNode node) {
    if (node is RegistrableSqlNode &&
        !(node as RegistrableSqlNode).isRegistered) {
      node = nodeManager.registerNode(node);
    }

    _children._addInternal(node);
    return node;
  }

  void checkNotFreezed() {
    if (isFreezed) {
      throw new StateError("Node is freezed");
    }
  }

  void _checkRegistered() {
    if (!isRegistered) {
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

class _SqlNodeChildrenListImpl extends SqlAbstractNodeListImpl {
  @override
  final int maxLength;

  bool isChildrenLockingEnabled;

  _SqlNodeChildrenListImpl({this.maxLength});

  _SqlNodeChildrenListImpl.cloneFrom(
      _SqlNodeChildrenListImpl target, bool freeze)
      : this.maxLength = target.maxLength,
        this.isChildrenLockingEnabled = target.isChildrenLockingEnabled,
        super.cloneFrom(target, freeze);

  void registerParent(SqlNode parent) {
    this.isChildrenLockingEnabled = parent is ChildrenLockingSupport;
  }

  @override
  void set length(int newLength) {
    _checkNodesCount(newLength);

    super.length = newLength;
  }

  @override
  void add(SqlNode value) {
    _checkNodesCount(length + 1);

    return super.add(value);
  }

  @override
  void addAll(Iterable<SqlNode> iterable) {
    _checkNodesCount(length + iterable.length);

    return super.addAll(iterable);
  }

  @override
  void insert(int index, SqlNode element) {
    _checkNodesCount(length + 1);

    return super.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<SqlNode> iterable) {
    _checkNodesCount(length + iterable.length);

    return super.insertAll(index, iterable);
  }

  @override
  _SqlNodeChildrenListImpl createClone(bool freeze) =>
      new _SqlNodeChildrenListImpl.cloneFrom(this, freeze);

  void _addInternal(SqlNode node) {
    // we assume that the node is already registered

    _checkNotFreezed();

    _checkNodesCount(length + 1);

    _backedList.add(node);
  }

  void _checkUpdatable() {
    super._checkUpdatable();

    _checkChildrenLocked();
  }

  void _checkChildrenLocked() {
    if (isChildrenLockingEnabled) {
      throw new UnsupportedError("Children locked");
    }
  }

  void _checkNodesCount(int count) {
    if (maxLength != null && count > maxLength) {
      throw new StateError("Children count out of range $count > $maxLength");
    }
  }
}

class UpdatableList<T> extends DelegatingList<T> {
  final List<T> _backedList;

  UpdatableList(List<T> backedList)
      : this._backedList = backedList,
        super(backedList);

  @override
  void set length(int newLength) {
    _checkUpdatable();

    _backedList.length = newLength;
  }

  @override
  void add(T value) {
    _checkUpdatable();

    return _backedList.add(value);
  }

  @override
  void addAll(Iterable<T> iterable) {
    _checkUpdatable();

    return _backedList.addAll(iterable);
  }

  @override
  void insert(int index, T element) {
    _checkUpdatable();

    return _backedList.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    _checkUpdatable();

    return _backedList.insertAll(index, iterable);
  }

  @override
  bool remove(Object value) {
    _checkUpdatable();

    return _backedList.remove(value);
  }

  @override
  T removeAt(int index) {
    _checkUpdatable();

    return _backedList.removeAt(index);
  }

  @override
  T removeLast() {
    _checkUpdatable();

    return _backedList.removeLast();
  }

  @override
  void removeWhere(bool test(T element)) {
    _checkUpdatable();

    return _backedList.removeWhere(test);
  }

  @override
  void retainWhere(bool test(T element)) {
    _checkUpdatable();

    return _backedList.retainWhere(test);
  }

  @override
  void removeRange(int start, int end) {
    _checkUpdatable();

    return _backedList.removeRange(start, end);
  }

  @override
  void replaceRange(int start, int end, Iterable<T> iterable) {
    _checkUpdatable();

    return _backedList.replaceRange(start, end, iterable);
  }

  @override
  void clear() {
    _checkUpdatable();

    return _backedList.clear();
  }

  void _checkUpdatable() {}
}
