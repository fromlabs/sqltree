// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import "package:sqltree/sqltree.dart" as sql;

void main() {
  group('children locking tests', () {
    test('Test 1', () {
      expect(
          () => sql.select("a", "b").addChildren("c"), throwsUnsupportedError);
      expect(() => sql.select("a", "b").children.addAll(sql.normalize("c")),
          throwsUnsupportedError);
      expect(() => sql.select("a", "b").children.removeLast(),
          throwsUnsupportedError);
    });
  });
  group('clone and freeze tests', () {
    test('Test 1', () {
      var select = sql.select("a", "b");
      expect(select.isFreezed, false);
      select.selectClause.addChildren("c");
      expect(select.selectClause.children.length, 3);
      select = select.clone();
      expect(select.isFreezed, false);
      select.selectClause.addChildren("d");
      expect(select.selectClause.children.length, 4);
      select = select.clone(freeze: true);
      expect(select.isFreezed, true);
      expect(() => select.selectClause.addChildren("e"),
          throwsA(new isInstanceOf<StateError>()));
      expect(select.selectClause.children.length, 4);
      select = select.clone();
      expect(select.isFreezed, true);
      expect(() => select.selectClause.addChildren("e"), throwsStateError);
      expect(select.selectClause.children.length, 4);
      select = select.clone(freeze: false);
      expect(select.isFreezed, false);
      select.selectClause.addChildren("e");
      expect(select.selectClause.children.length, 5);
    });

    test('Test 2', () {
      expect(sql.normalize().length, 0);
      expect(sql.normalize().firstOrNull, null);
      expect(sql.normalize().singleOrNull, null);
      expect(() => sql.normalize().first, throwsStateError);
      expect(() => sql.normalize().single, throwsStateError);
      expect(sql.normalize(null).length, 0);
      expect(sql.normalize(null, null).length, 0);
      expect(sql.normalize("").length, 1);
      expect(sql.normalize("").firstOrNull.rawExpression, "");
      expect(sql.normalize("").singleOrNull.rawExpression, "");
      expect(sql.normalize("").first.rawExpression, "");
      expect(sql.normalize("").single.rawExpression, "");
      expect(sql.normalize("", "").length, 2);
      expect(sql.normalize("", "").firstOrNull.rawExpression, "");
      expect(() => sql.normalize("", "").singleOrNull.rawExpression,
          throwsStateError);
      expect(sql.normalize("", "").first.rawExpression, "");
      expect(
          () => sql.normalize("", "").single.rawExpression, throwsStateError);
    });
  });
}
