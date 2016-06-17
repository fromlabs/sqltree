// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:math" as math;

import "sqltree_node.dart";
import "sqltree_node_manager.dart";
import "sqltree_node_manager_impl.dart";

SqlNodeIterable<SqlNode> getNodesFromVargs(
        [arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9]) =>
    new DelegatingSqlNodeIterable([
      arg0,
      arg1,
      arg2,
      arg3,
      arg4,
      arg5,
      arg6,
      arg7,
      arg8,
      arg9
    ].where((arg) => arg != null));

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
      whereReference(reference).firstOrNull != null;

  @override
  SqlNodeIterable<SqlNode> whereReference(String reference) =>
      whereDeep((node) => node.reference == reference);

  @override
  SqlNodeIterable<SqlNode> whereDeep(bool test(SqlNode node)) =>
      new DelegatingSqlNodeIterable(_whereDeepInternal(test));

  Iterable<SqlNode> _whereDeepInternal(bool test(SqlNode node)) sync* {
    if (test(this)) {
      yield this;
    }

    if (isCompositeNode) {
      yield* children.expand((child) => child._whereDeepInternal(test));
    }
  }

  @override
  bool get isRawNode => _type == BaseSqlNodeTypes.types.RAW;

  @override
  bool get isCompositeNode => !isRawNode;

  bool get isEmptyComposite =>
      isCompositeNode && maxChildrenLength != null && maxChildrenLength == 0;

  bool get isSingleCompositeNode =>
      isCompositeNode && maxChildrenLength != null && maxChildrenLength == 1;

  bool get isMultiCompositeNode =>
      isCompositeNode && (maxChildrenLength == null || maxChildrenLength > 1);

  @override
  String get rawExpression {
    if (isRawNode) {
      return _rawExpression;
    } else {
      throw new UnsupportedError("Node is not an expression");
    }
  }

  @override
  SqlNode get child {
    _checkRegistered();

    _checkSingleComposite();

    return _children.isNotEmpty ? _children.single : null;
  }

  @override
  void set child(singleChild) {
    _checkRegistered();

    _checkSingleComposite();

    var normalized = _nodeManager.normalize(singleChild)?.single;

    if (normalized != null) {
      if (normalized is SqlNode) {
        if (_children.isEmpty) {
          _children.add(normalized);
        } else {
          _children[0] = normalized;
        }
      } else {
        throw new ArgumentError.value(normalized, "child",
            "Single composite node accepts a single node child");
      }
    }
  }

  @override
  SqlNodeList<SqlNode> get children {
    _checkRegistered();

    _checkComposite();

    return _children;
  }

  @override
  void addChildren(node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    children.addAll(getNodesFromVargs(node0, node1, node2, node3, node4, node5,
            node6, node7, node8, node9)
        .expand(_nodeManager.normalize));
  }

  @override
  void insertChildren(int index, node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    children.insertAll(
        index,
        getNodesFromVargs(node0, node1, node2, node3, node4, node5, node6,
                node7, node8, node9)
            .expand(_nodeManager.normalize));
  }

  @override
  void setChildren(int index, node0,
      [node1, node2, node3, node4, node5, node6, node7, node8, node9]) {
    children.setAll(
        index,
        getNodesFromVargs(node0, node1, node2, node3, node4, node5, node6,
                node7, node8, node9)
            .expand(_nodeManager.normalize));
  }

  @override
  String toString() {
    if (isRawNode) {
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
    if (!isSingleCompositeNode) {
      throw new UnsupportedError("Node is not a single composite");
    }
  }

  void _checkComposite() {
    if (!isCompositeNode) {
      throw new UnsupportedError("Node is not a composite");
    }
  }
}

class _SqlNodeChildrenListImpl extends DelegatingSqlNodeListBase {
  @override
  final int maxLength;

  bool isChildrenLockingEnabled;

  _SqlNodeChildrenListImpl({this.maxLength}) : super([]);

  _SqlNodeChildrenListImpl.cloneFrom(
      _SqlNodeChildrenListImpl target, bool freeze)
      : this.maxLength = target.maxLength,
        this.isChildrenLockingEnabled = target.isChildrenLockingEnabled,
        super.cloneFrom(target, freeze);

  void registerParent(SqlNode parent) {
    this.isChildrenLockingEnabled = parent is ChildrenLockingSupport;
  }

  @override
  bool isAlreadyWrappedIterable(Iterable<SqlNode> base) =>
      base is DelegatingSqlNodeIterable<SqlNode>;

  @override
  bool isAlreadyWrappedList(Iterable<SqlNode> base) =>
      base is DelegatingSqlNodeList<SqlNode>;

  SqlNodeIterable<SqlNode> createIterable(Iterable<SqlNode> base) =>
      new DelegatingSqlNodeIterable(base);

  SqlNodeList<SqlNode> createList(List<SqlNode> base) => new DelegatingSqlNodeList(base);

  @override
  _SqlNodeChildrenListImpl createClone(bool freeze) =>
      new _SqlNodeChildrenListImpl.cloneFrom(this, freeze);

  @override
  void _checkUpdatable() {
    super._checkUpdatable();

    _checkChildrenLocked();
  }

  void _addInternal(SqlNode node) {
    // we assume that the node is already registered

    _checkNotFreezed();

    _checkNodesCount(length + 1);

    _listBase.add(node);
  }

  void _checkChildrenLocked() {
    if (isChildrenLockingEnabled) {
      throw new UnsupportedError("Children locked");
    }
  }

  void _checkNodesCount(int count) {
    if (maxLength != null && count > maxLength) {
      throw new UnsupportedError("Children count out of range $count > $maxLength");
    }
  }

  /* SIAMO SICURI CHE STIAMO AGGIORNANDO TUTTO? */

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
    var list = iterable.toList(growable: false);

    _checkNodesCount(length + list.length);

    return super.addAll(list);
  }

  @override
  void insert(int index, SqlNode element) {
    _checkNodesCount(length + 1);

    return super.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<SqlNode> iterable) {
    var list = iterable.toList(growable: false);

    _checkNodesCount(length + list.length);

    return super.insertAll(index, list);
  }
}

// TODO a cosa serve il getter statico typed sui DelegatingBase?

class DelegatingSqlNodeIterable<E extends SqlNode>
    extends DelegatingSqlNodeIterableBase<E> {
  const DelegatingSqlNodeIterable(Iterable<E> base) : super(base);

  @override
  bool isAlreadyWrappedIterable(Iterable<E> base) =>
      base is DelegatingSqlNodeIterable<E>;

  @override
  bool isAlreadyWrappedList(Iterable<E> base) =>
      base is DelegatingSqlNodeList<E>;

  SqlNodeIterable<E> createIterable(Iterable<E> base) =>
      new DelegatingSqlNodeIterable(base);

  SqlNodeList<E> createList(List<E> base) => new DelegatingSqlNodeList(base);
}

class DelegatingSqlNodeList<E extends SqlNode>
    extends DelegatingSqlNodeListBase<E> {
  const DelegatingSqlNodeList(List<E> base) : super(base);

  DelegatingSqlNodeList.cloneFrom(DelegatingSqlNodeList target, bool freeze)
      : super.cloneFrom(target, freeze);

  @override
  bool isAlreadyWrappedIterable(Iterable<E> base) =>
      base is DelegatingSqlNodeIterable<E>;

  @override
  bool isAlreadyWrappedList(Iterable<E> base) =>
      base is DelegatingSqlNodeList<E>;

  SqlNodeIterable<E> createIterable(Iterable<E> base) =>
      new DelegatingSqlNodeIterable(base);

  SqlNodeList<E> createList(List<E> base) => new DelegatingSqlNodeList(base);

  @override
  DelegatingSqlNodeList createClone(bool freeze) =>
      new DelegatingSqlNodeList.cloneFrom(this, freeze);
}

abstract class DelegatingSqlNodeIterableBase<E extends SqlNode>
    implements SqlNodeIterable<E> {
  final Iterable<E> _base;

  const DelegatingSqlNodeIterableBase(this._base);

  bool isAlreadyWrappedIterable(Iterable<E> base);

  bool isAlreadyWrappedList(Iterable<E> base);

  SqlNodeIterable<E> createIterable(Iterable<E> base);

  SqlNodeList<E> createList(List<E> base);

  @override
  E get firstOrNull => isNotEmpty ? first : null;

  @override
  E get singleOrNull => isNotEmpty ? single : null;

  @override
  bool containsReference(String reference) =>
      whereReference(reference).firstOrNull != null;

  @override
  SqlNodeIterable<E> whereReference(String reference) =>
      whereDeep((node) => node.reference == reference);

  SqlNodeIterable<E> whereDeep(bool test(E element)) =>
      expand((node) => node.whereDeep(test));

  @override
  void disable() {
    setEnabled(false);
  }

  @override
  void enable() {
    setEnabled(true);
  }

  @override
  void setDisabled(bool isDisabled) {
    setEnabled(!isDisabled);
  }

  @override
  void setEnabled(bool isEnabled) {
    for (var node in this) {
      node.isEnabled = isEnabled;
    }
  }

  @override
  void setReference(String reference) {
    for (var node in this) {
      node.reference = reference;
    }
  }

  @override
  bool any(bool test(E element)) => _base.any(test);

  @override
  bool contains(Object element) => _base.contains(element);

  @override
  E elementAt(int index) => _base.elementAt(index);

  @override
  bool every(bool test(E element)) => _base.every(test);

  @override
  SqlNodeIterable<E> expand(Iterable f(E element)) =>
      _wrapIterable(_base.expand(f));

  @override
  E get first => _base.first;

  @override
  E firstWhere(bool test(E element), {E orElse()}) =>
      _base.firstWhere(test, orElse: orElse);

  @override
  dynamic fold(initialValue, dynamic combine(previousValue, E element)) =>
      _base.fold(initialValue, combine);

  @override
  void forEach(void f(E element)) => _base.forEach(f);

  @override
  bool get isEmpty => _base.isEmpty;

  @override
  bool get isNotEmpty => _base.isNotEmpty;

  @override
  Iterator<E> get iterator => _base.iterator;

  String join([String separator = ""]) => _base.join(separator);

  @override
  E get last => _base.last;

  @override
  E lastWhere(bool test(E element), {E orElse()}) =>
      _base.lastWhere(test, orElse: orElse);

  @override
  int get length => _base.length;

  @override
  SqlNodeIterable<E> map(f(E element)) => _wrapIterable(_base.map(f));

  @override
  E reduce(E combine(E value, E element)) => _base.reduce(combine);

  @override
  E get single => _base.single;

  @override
  E singleWhere(bool test(E element)) => _base.singleWhere(test);

  @override
  SqlNodeIterable<E> skip(int n) => _wrapIterable(_base.skip(n));

  @override
  SqlNodeIterable<E> skipWhile(bool test(E value)) =>
      _wrapIterable(_base.skipWhile(test));

  @override
  SqlNodeIterable<E> take(int n) => _wrapIterable(_base.take(n));

  @override
  SqlNodeIterable<E> takeWhile(bool test(E value)) =>
      _wrapIterable(_base.takeWhile(test));

  @override
  SqlNodeList<E> toList({bool growable: true}) =>
      _wrapList(_base.toList(growable: growable));

  @override
  Set<E> toSet() => _base.toSet();

  @override
  SqlNodeIterable<E> where(bool test(E element)) =>
      _wrapIterable(_base.where(test));

  @override
  String toString() => _base.toString();

  SqlNodeIterable<E> _wrapIterable(Iterable<E> base) =>
      isAlreadyWrappedIterable(base) ? base : createIterable(base);

  SqlNodeList<E> _wrapList(List<E> base) =>
      isAlreadyWrappedList(base) ? base : createList(base);
}

abstract class DelegatingSqlNodeListBase<E extends SqlNode>
    extends DelegatingSqlNodeIterableBase<E> implements SqlNodeList<E> {
  @override
  final bool isFreezed;

  const DelegatingSqlNodeListBase(List<E> base)
      : this.isFreezed = false,
        super(base);

  DelegatingSqlNodeListBase.cloneFrom(
      DelegatingSqlNodeListBase target, bool freeze)
      : this.isFreezed = freeze,
        super(target._base.map((node) => node.clone(freeze: freeze)).toList());

  List<E> get _listBase => _base;

  @override
  SqlNodeList<E> clone({bool freeze}) => (freeze != null && !freeze) ||
      !isFreezed ? createClone(freeze ?? isFreezed) : this;

  SqlNodeList<E> createClone(bool freeze);

  void _checkUpdatable() {
    _checkNotFreezed();
  }

  void _checkNotFreezed() {
    if (isFreezed) {
      throw new StateError("Node is freezed");
    }
  }

  @override
  E operator [](int index) => _listBase[index];

  @override
  void operator []=(int index, E value) {
    _checkUpdatable();

    _listBase[index] = value;
  }

  @override
  void add(E value) {
    _checkUpdatable();

    _listBase.add(value);
  }

  @override
  void addAll(Iterable<E> iterable) {
    _checkUpdatable();

    _listBase.addAll(iterable);
  }

  @override
  Map<int, E> asMap() => _listBase.asMap();

  @override
  void clear() {
    _checkUpdatable();

    _listBase.clear();
  }

  @override
  void fillRange(int start, int end, [E fillValue]) {
    _checkUpdatable();

    _listBase.fillRange(start, end, fillValue);
  }

  @override
  SqlNodeIterable<E> getRange(int start, int end) =>
      _wrapIterable(_listBase.getRange(start, end));

  @override
  int indexOf(E element, [int start = 0]) => _listBase.indexOf(element, start);

  @override
  void insert(int index, E element) {
    _checkUpdatable();

    _listBase.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    _checkUpdatable();

    _listBase.insertAll(index, iterable);
  }

  @override
  int lastIndexOf(E element, [int start]) =>
      _listBase.lastIndexOf(element, start);

  @override
  void set length(int newLength) {
    _checkUpdatable();

    _listBase.length = newLength;
  }

  @override
  bool remove(Object value) {
    _checkUpdatable();

    return _listBase.remove(value);
  }

  @override
  E removeAt(int index) {
    _checkUpdatable();

    return _listBase.removeAt(index);
  }

  @override
  E removeLast() {
    _checkUpdatable();

    return _listBase.removeLast();
  }

  @override
  void removeRange(int start, int end) {
    _checkUpdatable();

    _listBase.removeRange(start, end);
  }

  @override
  void removeWhere(bool test(E element)) {
    _checkUpdatable();

    _listBase.removeWhere(test);
  }

  @override
  void replaceRange(int start, int end, Iterable<E> iterable) {
    _checkUpdatable();

    _listBase.replaceRange(start, end, iterable);
  }

  @override
  void retainWhere(bool test(E element)) {
    _checkUpdatable();

    _listBase.retainWhere(test);
  }

  @override
  SqlNodeIterable<E> get reversed => _wrapIterable(_listBase.reversed);

  @override
  void setAll(int index, Iterable<E> iterable) {
    _checkUpdatable();

    _listBase.setAll(index, iterable);
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    _checkUpdatable();

    _listBase.setRange(start, end, iterable, skipCount);
  }

  @override
  void shuffle([math.Random random]) {
    _checkUpdatable();

    _listBase.shuffle(random);
  }

  @override
  void sort([int compare(E a, E b)]) {
    _checkUpdatable();

    _listBase.sort(compare);
  }

  @override
  SqlNodeList<E> sublist(int start, [int end]) =>
      _wrapList(_listBase.sublist(start, end));
}
