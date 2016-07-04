// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "sqltree_node.dart";
import "sqltree_node_impl.dart";

class SqlCustomNodeImpl extends SqlAbstractNodeImpl {
  SqlCustomNodeImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  SqlCustomNodeImpl.cloneFrom(SqlCustomNodeImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlCustomNodeImpl createClone(bool freeze) =>
      new SqlCustomNodeImpl.cloneFrom(this, freeze);
}

class SqlCustomFunctionImpl extends SqlAbstractFunctionImpl {
  SqlCustomFunctionImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  SqlCustomFunctionImpl.cloneFrom(SqlCustomFunctionImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlCustomFunctionImpl createClone(bool freeze) =>
      new SqlCustomFunctionImpl.cloneFrom(this, freeze);
}

class SqlCustomOperatorImpl extends SqlAbstractOperatorImpl
    implements SqlOperator {
  SqlCustomOperatorImpl(String type, {int maxChildrenLength})
      : super(type, maxChildrenLength: maxChildrenLength);

  SqlCustomOperatorImpl.cloneFrom(SqlCustomOperatorImpl targetNode, bool freeze)
      : super.cloneFrom(targetNode, freeze);

  @override
  SqlCustomOperatorImpl createClone(bool freeze) =>
      new SqlCustomOperatorImpl.cloneFrom(this, freeze);
}
