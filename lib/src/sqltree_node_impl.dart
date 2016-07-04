// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "dart:math" as math;

import "package:collection/collection.dart";

import "sqltree_node.dart";
import "sqltree_node_manager.dart";
import "sqltree_node_manager_impl.dart";

class SqlNodeImpl extends SqlAbstractNodeImpl {
  SqlNodeImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  SqlNodeImpl.raw(expression) : super.raw(expression?.toString());

  SqlNodeImpl.cloneFrom(SqlNodeImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlNodeImpl createClone(bool freeze) =>
      new SqlNodeImpl.cloneFrom(this, freeze);
}

class SqlFunctionImpl extends SqlAbstractFunctionImpl {
  SqlFunctionImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  SqlFunctionImpl.cloneFrom(SqlFunctionImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlFunctionImpl createClone(bool freeze) =>
      new SqlFunctionImpl.cloneFrom(this, freeze);
}

class SqlOperatorImpl extends SqlAbstractOperatorImpl implements SqlOperator {
  SqlOperatorImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  SqlOperatorImpl.cloneFrom(SqlOperatorImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlOperatorImpl createClone(bool freeze) =>
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
  SqlNodeIterable/*<T>*/ whereDeep/*<T extends SqlNode>*/(
          bool test(/*=T*/ node)) =>
      new DelegatingSqlNodeIterable/*<T>*/(_whereDeepInternal(test));

  Iterable/*<T>*/ _whereDeepInternal/*<T extends SqlNode>*/(
      bool test(/*=T*/ node)) sync* {
    var/*=T*/ thisNode = this as dynamic/*=T*/;
    if (test(thisNode)) {
      yield thisNode;
    }

    if (isCompositeNode) {
      var nodes = children.expand((child) => (child as SqlAbstractNodeImpl)
          ._whereDeepInternal((node) => test(node as SqlNode/*=T*/)));
      yield* nodes;
    }
  }

  @override
  bool get isRawNode => _type == BaseSqlNodeTypes.types.RAW;

  @override
  bool get isCompositeNode => !isRawNode;

  @override
  bool get isEmptyComposite =>
      isCompositeNode && maxChildrenLength != null && maxChildrenLength == 0;

  @override
  bool get isSingleCompositeNode =>
      isCompositeNode && maxChildrenLength != null && maxChildrenLength == 1;

  @override
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
  SqlAbstractNodeImpl clone({bool freeze}) => (freeze != null && !freeze) ||
      !isFreezed ? createClone(freeze ?? isFreezed) : this;

  SqlAbstractNodeImpl createClone(bool freeze);

  SqlNode/*=T*/ addInternalNode/*<T extends SqlNode>*/(SqlNode/*=T*/ node) {
    if (node is RegistrableSqlNode &&
        !(node as RegistrableSqlNode).isRegistered) {
      node = nodeManager.registerNode(node) as SqlNode/*=T*/;
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

class _SqlNodeChildrenListImpl extends DelegatingSqlNodeListBase
    with DelegatingSqlNodeCollectionMixin<SqlNode> {
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

    _base.add(node);
  }

  void _checkChildrenLocked() {
    if (isChildrenLockingEnabled) {
      throw new UnsupportedError("Children locked");
    }
  }

  void _checkNodesCount(int count) {
    if (maxLength != null && count > maxLength) {
      throw new UnsupportedError(
          "Children count out of range $count > $maxLength");
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
    // serve al conteggio
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
    // serve al conteggio
    var list = iterable.toList(growable: false);

    _checkNodesCount(length + list.length);

    return super.insertAll(index, list);
  }
}

// TODO a cosa serve il getter statico typed sui DelegatingBase?

abstract class DelegatingSqlNodeCollectionMixin<E extends SqlNode>
    implements DelegatingSqlNodeIterableBase<E> {
  @override
  bool isAlreadyWrappedIterable(Iterable<E> base) =>
      base is DelegatingSqlNodeIterable<E>;

  @override
  bool isAlreadyWrappedList(Iterable<E> base) =>
      base is DelegatingSqlNodeList<E>;

  SqlNodeIterable<E> createIterable(Iterable<E> base) =>
      new DelegatingSqlNodeIterable/*<E>*/(base);

  SqlNodeList<E> createList(List<E> base) =>
      new DelegatingSqlNodeList/*<E>*/(base);
}

class DelegatingSqlNodeIterable<E extends SqlNode>
    extends DelegatingSqlNodeIterableBase<E>
    with DelegatingSqlNodeCollectionMixin<E> {
  DelegatingSqlNodeIterable(Iterable<E> base) : super(base);
}

class DelegatingSqlNodeList<E extends SqlNode>
    extends DelegatingSqlNodeListBase<E>
    with DelegatingSqlNodeCollectionMixin<E> {
  DelegatingSqlNodeList(List<E> base) : super(base);

  DelegatingSqlNodeList.cloneFrom(DelegatingSqlNodeList target, bool freeze)
      : super.cloneFrom(target, freeze);

  @override
  DelegatingSqlNodeList/*<E>*/ createClone(bool freeze) =>
      new DelegatingSqlNodeList/*<E>*/ .cloneFrom(this, freeze);
}

abstract class DelegatingSqlNodeIterableBase<E extends SqlNode>
    extends DelegatingIterable<E>
    with DelegatingSqlNodeIterableMixin<E>
    implements SqlNodeIterable<E> {
  final Iterable<E> _base;

  DelegatingSqlNodeIterableBase(Iterable<E> base)
      : this._base = base,
        super(base);

  @override
  SqlNodeIterable<E> where(bool test(E element)) => super.where(test);

  @override
  SqlNodeIterable<E> skip(int n) => super.skip(n);

  @override
  SqlNodeIterable<E> skipWhile(bool test(E value)) => super.skipWhile(test);

  @override
  SqlNodeIterable<E> take(int n) => super.take(n);

  @override
  SqlNodeIterable<E> takeWhile(bool test(E value)) => super.takeWhile(test);

  @override
  SqlNodeList<E> toList({bool growable: true}) =>
      super.toList(growable: growable);
}

abstract class DelegatingSqlNodeIterableMixin<E extends SqlNode>
    implements SqlNodeIterable<E> {
  bool isAlreadyWrappedIterable(Iterable<E> base);

  bool isAlreadyWrappedList(Iterable<E> base);

  SqlNodeIterable<E> createIterable(Iterable<E> base);

  SqlNodeList<E> createList(List<E> base);

  @override
  SqlNodeIterable<E> where(bool test(E element)) =>
      _wrapIterable(super.where(test));

  @override
  SqlNodeIterable<E> skip(int n) => _wrapIterable(super.skip(n));

  @override
  SqlNodeIterable<E> skipWhile(bool test(E value)) =>
      _wrapIterable(super.skipWhile(test));

  @override
  SqlNodeIterable<E> take(int n) => _wrapIterable(super.take(n));

  @override
  SqlNodeIterable<E> takeWhile(bool test(E value)) =>
      _wrapIterable(super.takeWhile(test));

  @override
  SqlNodeList<E> toList({bool growable: true}) =>
      _wrapList(super.toList(growable: growable));

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
      expandNodes((node) => node.whereDeep(test));

  @override
  SqlNodeIterable<E> expandNodes(Iterable<E> f(E element)) =>
      _wrapIterable(expand(f));

  @override
  SqlNodeIterable<E> mapNodes(E f(E element)) => _wrapIterable(map(f));

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

  SqlNodeIterable<E> _wrapIterable(Iterable<E> base) =>
      isAlreadyWrappedIterable(base) ? base : createIterable(base);

  SqlNodeList<E> _wrapList(List<E> base) =>
      isAlreadyWrappedList(base) ? base : createList(base);
}

abstract class DelegatingListBase<E> extends DelegatingList<E> {
  final List<E> _base;

  DelegatingListBase(List<E> base)
      : this._base = base,
        super(base);
}

abstract class DelegatingSqlNodeListBase<E extends SqlNode>
    extends DelegatingListBase<E>
    with DelegatingSqlNodeIterableMixin<E>
    implements SqlNodeList<E> {
  @override
  final bool isFreezed;

  DelegatingSqlNodeListBase(List<E> base)
      : this.isFreezed = false,
        super(base);

  DelegatingSqlNodeListBase.cloneFrom(
      DelegatingSqlNodeListBase target, bool freeze)
      : this.isFreezed = freeze,
        super(target._base.map((node) => node.clone(freeze: freeze)).toList());

  @override
  SqlNodeIterable<E> where(bool test(E element)) => super.where(test);

  @override
  SqlNodeIterable<E> skip(int n) => super.skip(n);

  @override
  SqlNodeIterable<E> skipWhile(bool test(E value)) => super.skipWhile(test);

  @override
  SqlNodeIterable<E> take(int n) => super.take(n);

  @override
  SqlNodeIterable<E> takeWhile(bool test(E value)) => super.takeWhile(test);

  @override
  SqlNodeList<E> toList({bool growable: true}) =>
      super.toList(growable: growable);

  @override
  DelegatingSqlNodeListBase<E> clone({bool freeze}) =>
      (freeze != null && !freeze) || !isFreezed
          ? createClone(freeze ?? isFreezed)
          : this;

  DelegatingSqlNodeListBase<E> createClone(bool freeze);

  void _checkUpdatable() {
    _checkNotFreezed();
  }

  void _checkNotFreezed() {
    if (isFreezed) {
      throw new StateError("Node is freezed");
    }
  }

  @override
  void operator []=(int index, E value) {
    _checkUpdatable();

    super[index] = value;
  }

  @override
  void add(E value) {
    _checkUpdatable();

    super.add(value);
  }

  @override
  void addAll(Iterable<E> iterable) {
    _checkUpdatable();

    super.addAll(iterable);
  }

  @override
  void clear() {
    _checkUpdatable();

    super.clear();
  }

  @override
  void fillRange(int start, int end, [E fillValue]) {
    _checkUpdatable();

    super.fillRange(start, end, fillValue);
  }

  @override
  SqlNodeIterable<E> getRange(int start, int end) =>
      _wrapIterable(super.getRange(start, end));

  @override
  void insert(int index, E element) {
    _checkUpdatable();

    super.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    _checkUpdatable();

    super.insertAll(index, iterable);
  }

  @override
  void set length(int newLength) {
    _checkUpdatable();

    super.length = newLength;
  }

  @override
  bool remove(Object value) {
    _checkUpdatable();

    return super.remove(value);
  }

  @override
  E removeAt(int index) {
    _checkUpdatable();

    return super.removeAt(index);
  }

  @override
  E removeLast() {
    _checkUpdatable();

    return super.removeLast();
  }

  @override
  void removeRange(int start, int end) {
    _checkUpdatable();

    super.removeRange(start, end);
  }

  @override
  void removeWhere(bool test(E element)) {
    _checkUpdatable();

    super.removeWhere(test);
  }

  @override
  void replaceRange(int start, int end, Iterable<E> iterable) {
    _checkUpdatable();

    super.replaceRange(start, end, iterable);
  }

  @override
  void retainWhere(bool test(E element)) {
    _checkUpdatable();

    super.retainWhere(test);
  }

  @override
  SqlNodeIterable<E> get reversed => _wrapIterable(super.reversed);

  @override
  void setAll(int index, Iterable<E> iterable) {
    _checkUpdatable();

    super.setAll(index, iterable);
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    _checkUpdatable();

    super.setRange(start, end, iterable, skipCount);
  }

  @override
  void shuffle([math.Random random]) {
    _checkUpdatable();

    super.shuffle(random);
  }

  @override
  void sort([int compare(E a, E b)]) {
    _checkUpdatable();

    super.sort(compare);
  }

  @override
  SqlNodeList<E> sublist(int start, [int end]) =>
      _wrapList(super.sublist(start, end));
}
