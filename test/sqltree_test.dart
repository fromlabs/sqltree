// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import "package:sqltree/sqltree.dart" as sql;

void main() {
  group('base', () {
    test('Test 1', () {
      sql.registerNodeType("PROVA", (node) => node is sql.SqlFunction);
      expect(() => sql.registerNode(new sql.ExtensionSqlNode("PROVA")),
          throwsStateError);
      sql
          .registerNode(new sql.ExtensionSqlFunction("PROVA"))
          .children
          .addAll(sql.node("a"));
    });
    test('Test 2', () {
      expect(sql.setReference("CIAO", sql.equal("a", "b")).single.reference,
          "CIAO");
    });
  });

  group('children locking tests', () {
    test('Test 1', () {
      expect(() => sql.select("a", "b").children.addAll(sql.node("c")),
          throwsUnsupportedError);
      expect(() => sql.select("a", "b").children.addAll(sql.node("c")),
          throwsUnsupportedError);
      expect(() => sql.select("a", "b").children.removeLast(),
          throwsUnsupportedError);
    });
  });

  group('clone and freeze tests', () {
    test('Test 1', () {
      var select = sql.select("a", "b");
      expect(select.isFreezed, false);
      select.selectClause.children.addAll(sql.node("c"));
      expect(select.selectClause.children.length, 3);
      select = select.clone();
      expect(select.isFreezed, false);
      select.selectClause.children.addAll(sql.node("d"));
      expect(select.selectClause.children.length, 4);
      select = select.clone(freeze: true);
      expect(select.isFreezed, true);
      expect(() => select.selectClause.children.addAll(sql.node("e")),
          throwsA(new isInstanceOf<StateError>()));
      expect(select.selectClause.children.length, 4);
      select = select.clone();
      expect(select.isFreezed, true);
      expect(() => select.selectClause.children.addAll(sql.node("e")),
          throwsStateError);
      expect(select.selectClause.children.length, 4);
      select = select.clone(freeze: false);
      expect(select.isFreezed, false);
      select.selectClause.children.addAll(sql.node("e"));
      expect(select.selectClause.children.length, 5);
    });

    test('Test 2', () {
      expect(sql.node(null).length, 0);
      expect(sql.node(null, null).length, 0);
      expect(sql.node("").length, 1);
      expect(sql.node("").firstOrNull.rawExpression, "");
      expect(sql.node("").singleOrNull.rawExpression, "");
      expect(sql.node("").first.rawExpression, "");
      expect(sql.node("").single.rawExpression, "");
      expect(sql.node("", "").length, 2);
      expect(sql.node("", "").firstOrNull.rawExpression, "");
      expect(
          () => sql.node("", "").singleOrNull.rawExpression, throwsStateError);
      expect(sql.node("", "").first.rawExpression, "");
      expect(() => sql.node("", "").single.rawExpression, throwsStateError);
    });
  });
}
